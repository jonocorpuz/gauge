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

