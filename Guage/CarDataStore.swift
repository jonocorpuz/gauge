//
//  CarDataStore.swift
//  Guage
//
//  Created by Jonathan Corpuz on 2025-12-11.
//

import SwiftUI
import Combine

class CarDataStore: ObservableObject {
    @Published var car: Car // Reload the UI when the variable changes
    
    init() {
        self.car = Car(
            year: "2023",
            make: "Integra",
            model: "Type S",
            currentMileage: 12570,
            maintenanceItems: [
                MaintenanceItem(
                    title: "Oil Change",
                    notes: "Use 5w-30 Synthetic",
                    intervalMileage: 7500,
                    lastServiceMileage: 8600
                ),
                
                MaintenanceItem(
                    title: "Brake Replacement",
                    notes: "Pads and Rotors",
                    intervalMileage: 60000,
                    lastServiceMileage: nil
                )
            ]
        )
    }
}

