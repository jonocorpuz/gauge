//
//  CarDataStore.swift
//  Guage
//
//  Created by Jonathan Corpuz on 2025-12-11.
//

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
    
    @Published var connectionStatus: String = "Connecting to AWS..."
    
    init() {
        self.carInfo = CarInfo(
            year: "",
            make: "",
            model: "",
            currentMileage: 0
        )
        
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
                
                self.maintenanceItems = fetchedItems
                
                self.connectionStatus = "✅ Loaded \(fetchedItems.count) items"
                
                // Reset status after a delay
                try? await Task.sleep(nanoseconds: 3 * 1_000_000_000)
                self.connectionStatus = "✅ AWS Connected"
            } catch {
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
        
        saveCarToAWS()
    }
    
    func addOrUpdateMaintenanceItem(title: String, date: Date, mileage: Int, interval: Int, type: EntryType) {
        // Case insensitive match
        if let index = maintenanceItems.firstIndex(where: { $0.title.lowercased() == title.lowercased() }) {
            // Update existing
            var item = maintenanceItems[index]
            
            // Add history event
            let event = MaintenanceEvent(date: date, mileage: mileage)
            item.history.append(event)
            item.history.sort(by: { $0.date > $1.date }) // Keep sorted newest first
            
            // Update interval if provided (and it's maintenance)
            if type == .maintenance {
                item.intervalMileage = interval
            }
            
            // Save back
            maintenanceItems[index] = item
        } else {
            // Create new
            let initialEvent = MaintenanceEvent(date: date, mileage: mileage)
            
            let newItem = MaintenanceItem(
                title: title,
                intervalMileage: interval,
                type: type,
                history: [initialEvent]
            )
            
            maintenanceItems.append(newItem)
        }
        
        // Synced to AWS
        if let savedItem = (maintenanceItems.first { $0.title.lowercased() == title.lowercased() }) {
            Task {
                @MainActor in
                self.connectionStatus = "Saving \(savedItem.title)..."
                do {
                    try await AWSManager.shared.saveItem(savedItem)
                    self.connectionStatus = "✅ Saved \(savedItem.title)"
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
                
                // Reset car info to blank
                self.carInfo = CarInfo(year: "", make: "", model: "", currentMileage: 0)
                
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
        self.carInfo.currentMileage = mileage
        self.carInfo.lastUpdated = Date()
        
        saveCarToAWS()
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
    
    /// Static image to use for all vehicles for now
    var staticVehicleImage: String {
        "car_volkswagen_golf"
    }
}
