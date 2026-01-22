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
/// This class manages the state of the user's 'Car' and its 'MaintenanceItems'
/// It conforms to ObservableObject so that views can reactively update when data changes
///
/// - This store is meant to be injected into the view heirachy at the root then passed down via '@ObservableObject'
class CarDataStore: ObservableObject {
    @Published var car: Car // Reload the UI when the variable changes
    @Published var connectionStatus: String = "Connecting to AWS..."
    
    init() {
        let mySpecs = PerformanceProfile(
            horsepower: 438,
            torque: 385,
            zeroToSixty: 5.5,
            efficiency: 11.2
        )
        
        self.car = Car(
            year: "2008",
            make: "Lexus",
            model: "LS600h",
            currentMileage: 121570,
            maintenanceItems: [], // Start empty, load from AWS
            specs: mySpecs
        )
        
        // Test AWS Connection & Fetch Data on Launch
        Task {
            @MainActor in
            do {
                self.connectionStatus = "Fetching items..."
                
                // 2. Fetch Items
                let items = try await AWSManager.shared.fetchAll()
                self.car.maintenanceItems = items
                
                self.connectionStatus = "✅ Loaded \(items.count) items from AWS"
                
                // Reset status after a delay
                 try? await Task.sleep(nanoseconds: 3 * 1_000_000_000)
                 self.connectionStatus = "✅ AWS Connected"
            } catch {
                print("AWS Init Failed: \(error)")
                self.connectionStatus = "❌ Error: \(error)"
            }
        }
    }
    
    func addMileageEntry(date: Date, miles: Int) {
        let newEntry = MileageEntry(date: date, mileage: miles)
        
        car.milegeHistory.append(newEntry)
        
        car.currentMileage = miles
    }
    
    func addOrUpdateMaintenanceItem(title: String, date: Date, mileage: Int, interval: Int, type: EntryType) {
        // Case insensitive match
        if let index = car.maintenanceItems.firstIndex(where: { $0.title.lowercased() == title.lowercased() }) {
            // Update existing
            var item = car.maintenanceItems[index]
            
            // Add history event
            let event = MaintenanceEvent(date: date, mileage: mileage)
            item.history.append(event)
            
            // Update interval if provided (and it's maintenance)
            if type == .maintenance {
                item.intervalMileage = interval
            }
            
            // Save back
            car.maintenanceItems[index] = item
        } else {
            // Create new
            let initialEvent = MaintenanceEvent(date: date, mileage: mileage)
            
            let newItem = MaintenanceItem(
                title: title,
                intervalMileage: interval,
                type: type,
                history: [initialEvent]
            )
            
            car.maintenanceItems.append(newItem)
        }
        
        // Synced to AWS
        if let savedItem = (car.maintenanceItems.first { $0.title.lowercased() == title.lowercased() }) {
             Task {
                 @MainActor in
                 self.connectionStatus = "Saving \(savedItem.title) to AWS..."
                 do {
                     try await AWSManager.shared.save(savedItem)
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
}

