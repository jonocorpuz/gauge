//
//  MaintenanceItem.swift
//  Guage
//
//  Created by Jonathan Corpuz on 2026-01-27.
//

import Foundation

enum EntryType: String, CaseIterable, Codable {
    case modification = "Modification"
    case maintenance = "Maintenance"
}

struct MaintenanceEvent: Identifiable, Codable {
    var id: UUID = UUID()
    let date: Date
    let mileage: Int
}

struct MaintenanceItem: Identifiable, Codable {
    let id: UUID
    var title: String
    var intervalMileage: Int
    var type: EntryType
    var history: [MaintenanceEvent]
    
    var lastServiceMileage: Int {
        // Use the event with the latest date
        return history.max(by: { $0.date < $1.date })?.mileage ?? 0
    }
    
    var lastServiceDate: Date? {
        return history.max(by: { $0.date < $1.date })?.date
    }
    
    func getRemainingMiles(currentOdometer: Int) -> Int {
        let nextDue = lastServiceMileage + intervalMileage
        return nextDue - currentOdometer
    }
    
    func isOverdue(currentOdometer: Int) -> Bool {
        return getRemainingMiles(currentOdometer: currentOdometer) < 0
    }
    
    init(id: UUID = UUID(),
         title: String,
         intervalMileage: Int,
         type: EntryType = .maintenance,
         history: [MaintenanceEvent] = []) {
        
        self.id = id
        self.title = title
        self.intervalMileage = intervalMileage
        self.type = type
        
        self.history = history.sorted(by: { $0.date > $1.date })
    }
}
