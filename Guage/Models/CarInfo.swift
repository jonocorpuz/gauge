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
    
    var mileageHistory: [MileageEntry] = []
}

struct MileageEntry: Identifiable, Codable {
    var id: UUID = UUID()
    var date: Date
    var mileage: Int
}
