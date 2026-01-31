//
//  CarInfo.swift
//  Guage
//
//  Created by Jonathan Corpuz on 2026-01-27.
//

import Foundation

struct CarInfo: Identifiable, Codable {
    // Constant ID allows O(1) access in DynamoDB
    var id: String = "CAR_METADATA"
    
    var year: String
    var make: String
    var model: String
    var currentMileage: Int
    var lastUpdated: Date
    
    // Default Init
    init(year: String, make: String, model: String, currentMileage: Int, lastUpdated: Date = Date()) {
        self.year = year
        self.make = make
        self.model = model
        self.currentMileage = currentMileage
        self.lastUpdated = lastUpdated
    }
}
