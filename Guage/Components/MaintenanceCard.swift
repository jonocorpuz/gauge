//
//  MaintenanceCard.swift
//  Guage
//
//  Created by Jonathan Corpuz on 2025-12-13.
//

import SwiftUI

/// Summary card representing a single maintenance item / modification
struct MaintenanceCard: View {
    let item: MaintenanceItem
    let currentOdometer: Int
    
    /// Calculates exact kilometers left
    ///
    /// - Note: Result is negative if overdue
    private var remainingKilometers: Int {
        return item.getRemainingMiles(currentOdometer: currentOdometer)
    }
    
    /// Determine color of status light
    ///
    /// Expected cases:
    ///     .modification: blue
    ///     .maintenance: green (more than 20% remaining), red (less than 20% remaining)
    private var statusColor: Color {
        if item.type == .modification {
            return .blue
        }

        let interval = Double(item.intervalMileage)
        let remaining = Double(remainingKilometers)
        
        if remaining <= interval * 0.20 {
            return .red // Less than or equal to 20% left (Due Soon)
        }
        
        else {
            return .menuGreenAccent
        }
    }

    /// Generate text label to go nex to status light
    private var statusText: String {
        switch item.type {
            case .modification:
                return "Modification"
            case .maintenance:
                if Double(remainingKilometers) < (Double(item.intervalMileage) * 0.20) {
                    return "Maintenance Due Soon"
                }
            
                else {
                    return "Maintenance Status Good"
                }
            }
    }
    
    var body: some View {
        ZStack() {
            Color.menuWhite
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 15) {
                // Header Area
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.title)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(Color.menuBlack)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    
                    /// Expected outputs:
                    ///     .maintenance: Shows remaining kms until next service
                    ///     .modification: "Part Installed"
                    Text(item.type == .modification ? "Part Installed" : "\(remainingKilometers)km until next service")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .foregroundStyle(Color.menuBlack)
                }
                .padding(20)
                
                Divider()
                    .background(Color.menuWhite)
                
                // Footer area
                HStack(spacing: 12) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 10, height: 10)
                    
                    Text(statusText)
                        .font(.system(size: 13))
                        .fontWeight(.bold)
                        .foregroundStyle(Color.menuBlack)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.menuBlack)
                }
                .padding(.top, 6)
                .padding(.bottom, 18)
                .padding(.horizontal, 20)
            }
            .frame(maxWidth: .infinity, maxHeight: 180)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

#Preview {
    // Mock preview data; adjust to match your real MaintenanceItem initializer
    let previewItem = MaintenanceItem(title: "Oil Change", intervalMileage: 10000, type: .maintenance)
    MaintenanceCard(item: previewItem, currentOdometer: 19000)
}
