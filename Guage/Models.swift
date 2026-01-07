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

struct MaintenanceItem: Identifiable, Codable {
    let id: UUID
    
    var title: String               // item name
    var notes: String?              // item notes
    var type: EntryType = .maintenance
    var isCompleted: Bool = false;
    
    // Tracked items
    var intervalMileage: Int        // interval of item
    var lastServiceMileage: Int?    // last service mileage of item
    var lastServiceDate: Int?        // last service date of item
    var nextDueMileage: Int? {      // next service mileage of item
        if let last = lastServiceMileage {
            return last + intervalMileage
        }
        
        return nil
    }
    
    // Initializer
    init (id: UUID = UUID(), title: String, notes: String, isCompleted: Bool = false,
          intervalMileage: Int, lastServiceMileage: Int? = nil, lastServiceDate: Int? = nil) {
        self.id = id
        self.title = title
        self.notes = notes
        self.isCompleted = isCompleted
        self.intervalMileage = intervalMileage
        self.lastServiceMileage = lastServiceMileage
        self.lastServiceDate = lastServiceDate
    }
}

struct Car: Identifiable, Codable {
    let id: UUID
    
    var year: String
    var make: String
    var model: String
    
    // Tracked items
    var currentMileage: Int = 0;
    var maintenanceItems: [MaintenanceItem]
    
    init(id: UUID = UUID(), year: String, make: String, model: String,
         currentMileage: Int = 0, maintenanceItems: [MaintenanceItem] = []) {
        self.id = id;
        self.year = year;
        self.make = make;
        self.model = model;
        self.currentMileage = currentMileage;
        self.maintenanceItems = maintenanceItems;
    }
}
