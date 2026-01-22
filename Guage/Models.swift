//
//  Models.swift
//  Guage
//
//  Created by Jonathan Corpuz on 2025-12-11.
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
    var type: EntryType = .maintenance
    
    var history: [MaintenanceEvent] = []
    
    var lastServiceMileage: Int? {
            return history.max(by: { $0.date < $1.date })?.mileage
    }
        
    var lastServiceDate: Date? {
        return history.max(by: { $0.date < $1.date })?.date
    }
    
    var nextDueMileage: Int? {
        if let last = lastServiceMileage {
            return last + intervalMileage
        }
        
        return nil
    }
    
    // Init
    init(
        id: UUID = UUID(),
        title: String,
        intervalMileage: Int,
        type: EntryType = .maintenance,
        history: [MaintenanceEvent] = []
    ) {
        self.id = id
        self.title = title
        self.intervalMileage = intervalMileage
        self.type = type
        self.history = history
    }
}

struct PerformanceProfile: Codable {
    var horsepower: Int
    var torque: Int
    var zeroToSixty: Double
    var efficiency: Double
}

struct Car: Identifiable, Codable {
    let id: UUID
    
    var year: String
    var make: String
    var model: String
    
    var currentMileage: Int = 0;
    var maintenanceItems: [MaintenanceItem]
    var milegeHistory: [MileageEntry] = []
    
    var specs: PerformanceProfile
    
    init(id: UUID = UUID(), year: String, make: String, model: String,
         currentMileage: Int = 0, maintenanceItems: [MaintenanceItem] = [], specs: PerformanceProfile) {
        self.id = id
        self.year = year
        self.make = make
        self.model = model
        self.currentMileage = currentMileage
        self.maintenanceItems = maintenanceItems
        self.specs = specs
    }
}

struct MileageEntry: Identifiable, Codable {
    var id: UUID = UUID()
    var date: Date
    var mileage: Int
}
