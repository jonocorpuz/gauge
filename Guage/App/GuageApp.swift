//
//  GuageApp.swift
//  Guage
//
//  Created by Jonathan Corpuz on 2025-12-11.
//

import SwiftUI
import SwiftData

@main
struct GuageApp: App {
    init() {
            _ = AWSManager.shared
        }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
