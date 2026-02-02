import SwiftUI
import Combine

/// Primary data source for application
///
/// This class manages the state of the user's 'CarInfo' and its 'MaintenanceItems'
/// It conforms to ObservableObject so that views can reactively update when data changes
///
/// - This store is meant to be injected into the view heirachy at the root then passed down via '@ObservableObject'
class CarDataStore: ObservableObject {
    @Published var carInfo: CarInfo // Metadata
    @Published var maintenanceItems: [MaintenanceItem] = [] // Items
    
    private var mileageHistory: [KilometerReading] = []
    
    struct KilometerReading: Codable {
        let date: Date
        let kilometers: Int
    }
    
    @Published var connectionStatus: String = "Connecting to AWS..."
    
    init() {
        self.carInfo = CarInfo(
            year: "",
            make: "",
            model: "",
            currentMileage: 0
        )
        
        // Load local history
        if let data = UserDefaults.standard.data(forKey: "local_kilometer_history"),
           let history = try? JSONDecoder().decode([KilometerReading].self, from: data) {
            self.mileageHistory = history
        }
        
        // Test AWS Connection & Fetch Data on Launch
        Task {
            @MainActor in
            do {
                self.connectionStatus = "Fetching items..."
                
                // 2. Fetch Items
                let (fetchedCar, fetchedItems) = try await AWSManager.shared.fetchAll()
                
                if let fetchedCar = fetchedCar {
                    self.carInfo = fetchedCar
                }
                
                NotificationManager.shared.rescheduleAllNotifications(
                    items: fetchedItems,
                    currentMileage: self.carInfo.currentMileage,
                    dailyRate: self.calculateDailyRate()
                )
                
                self.maintenanceItems = fetchedItems
                self.connectionStatus = "✅ Loaded \(fetchedItems.count) items"
                try? await Task.sleep(nanoseconds: 3 * 1_000_000_000)
                self.connectionStatus = "✅ AWS Connected"
            }
            
            catch {
                print("AWS Init Failed: \(error)")
                self.connectionStatus = "❌ Error: \(error)"
            }
        }
    }
    
    func fetchData() async {
        do {
            let (fetchedCar, fetchedItems) = try await AWSManager.shared.fetchAll()
            
            if let fetchedCar = fetchedCar {
                self.carInfo = fetchedCar
            }
            
            self.maintenanceItems = fetchedItems
        }
        
        catch {
            print("ERROR: Loading failed");
        }
    }
    
    func updateMileage(date: Date, miles: Int) {
        carInfo.currentMileage = miles
        carInfo.lastUpdated = date
        
        // Add to history
        let reading = KilometerReading(date: date, kilometers: miles)
        mileageHistory.append(reading)
        mileageHistory.sort(by: { $0.date < $1.date }) // Oldest first
        
        if let data = try? JSONEncoder().encode(mileageHistory) {
            UserDefaults.standard.set(data, forKey: "local_kilometer_history")
        }
        
        saveCarToAWS()
        
        NotificationManager.shared.rescheduleAllNotifications(
            items: self.maintenanceItems,
            currentMileage: miles,
            dailyRate: calculateDailyRate()
        )
    }
    
    func addOrUpdateMaintenanceItem(title: String, date: Date, mileage: Int, interval: Int, type: EntryType) {
        if let index = maintenanceItems.firstIndex(where: { $0.title.lowercased() == title.lowercased() }) {
            var item = maintenanceItems[index]
            
            let event = MaintenanceEvent(date: date, mileage: mileage)
            item.history.append(event)
            item.history.sort(by: { $0.date > $1.date }) // Keep sorted newest first
            
            if type == .maintenance {
                item.intervalMileage = interval
            }
            
            maintenanceItems[index] = item
        }
        
        else {
            let initialEvent = MaintenanceEvent(date: date, mileage: mileage)
            
            let newItem = MaintenanceItem(
                title: title,
                intervalMileage: interval,
                type: type,
                history: [initialEvent]
            )
            
            maintenanceItems.append(newItem)
        }
        
        if let savedItem = (maintenanceItems.first { $0.title.lowercased() == title.lowercased() }) {
            Task {
                @MainActor in
                self.connectionStatus = "Saving \(savedItem.title)..."
                do {
                    try await AWSManager.shared.saveItem(savedItem)
                    self.connectionStatus = "✅ Saved \(savedItem.title)"
                    
                    NotificationManager.shared.rescheduleAllNotifications(
                        items: self.maintenanceItems,
                        currentMileage: self.carInfo.currentMileage,
                        dailyRate: self.calculateDailyRate()
                    )
                    
                    // Reset after 3 seconds
                    try? await Task.sleep(nanoseconds: 3 * 1_000_000_000)
                    self.connectionStatus = "✅ AWS Connected"
                } catch {
                    self.connectionStatus = "❌ Error: \(error)"
                }
            }
        }
    }
    
    func resetAllData() {
        Task {
            @MainActor in
            self.connectionStatus = "⚠️ Nuking all data..."
            do {
                print("DEBUG: Calling AWSManager.nukeUserData")
                try await AWSManager.shared.nukeUserData()
                
                // Clear local memory
                print("DEBUG: Clearing local memory")
                self.maintenanceItems.removeAll()
                self.mileageHistory.removeAll()
                UserDefaults.standard.removeObject(forKey: "local_kilometer_history")
                
                // Reset car info to blank
                self.carInfo = CarInfo(year: "", make: "", model: "", currentMileage: 0)
                
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                
                self.connectionStatus = "✅ Data Wiped"
                try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
                self.connectionStatus = "✅ AWS Connected"
            } catch {
                print("DEBUG: Reset failed with error: \(error)")
                self.connectionStatus = "❌ Reset Failed: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Vehicle Management
    
    /// Updates the car metadata
    func updateCarDetails(year: String, make: String, model: String, mileage: Int) {
        self.carInfo.year = year
        self.carInfo.make = make
        self.carInfo.model = model
        
        // Use existing logic for mileage to ensure it's logged as an entry
        updateMileage(date: Date(), miles: mileage)
    }
    
    private func saveCarToAWS() {
        Task {
            @MainActor in
            do {
                try await AWSManager.shared.saveCar(self.carInfo)
                print("✅ Car info saved to AWS")
            } catch {
                print("❌ Failed to save car info: \(error)")
            }
        }
    }
    
    struct MileageContext {
        let rate: Double
        let start: KilometerReading?
        let end: KilometerReading?
    }
    
    var mileageContext: MileageContext {
        calculateDailyRateContext()
    }
    
    var averageDailyKm: Double {
        calculateDailyRateContext().rate
    }
    
    private func calculateDailyRate() -> Double {
        calculateDailyRateContext().rate
    }

    private func calculateDailyRateContext() -> MileageContext {
        guard mileageHistory.count >= 2 else {
             return MileageContext(rate: 50.0, start: nil, end: nil)
        }
        
        let now = Date()
        let targetDate = Calendar.current.date(byAdding: .day, value: -90, to: now) ?? now
        
        guard let latest = mileageHistory.last else {
             return MileageContext(rate: 50.0, start: nil, end: nil)
        }
        
        let candidates = mileageHistory.dropLast()
        
        if let firstInWindow = candidates.first(where: { $0.date >= targetDate }) {
             let rate = calculateRate(from: firstInWindow, to: latest)
             return MileageContext(rate: rate, start: firstInWindow, end: latest)
        }
        
        if let oldest = candidates.first {
            let rate = calculateRate(from: oldest, to: latest)
            return MileageContext(rate: rate, start: oldest, end: latest)
        }
        
        return MileageContext(rate: 50.0, start: nil, end: nil)
    }
    
    private func calculateDailyRateWrapper(from start: KilometerReading, to end: KilometerReading) -> Double {
         let daysDiff = end.date.timeIntervalSince(start.date) / 86400
         let kmDiff = Double(end.kilometers - start.kilometers)
         
         if daysDiff < 1 || kmDiff < 0 { return 50.0 }
         return kmDiff / daysDiff
    }
    
    private func calculateRate(from start: KilometerReading, to end: KilometerReading) -> Double {
         let daysDiff = end.date.timeIntervalSince(start.date) / 86400
         let kmDiff = Double(end.kilometers - start.kilometers)
         
         // Sanity checks
         if daysDiff < 0.1 { return 0 } // Avoid division by near-zero
         if kmDiff < 0 { return 0 } // Negative distance?
         
         return kmDiff / daysDiff
    }

    /// Static image to use for all vehicles for now
    var staticVehicleImage: String {
        "car_volkswagen_golf"
    }
}
