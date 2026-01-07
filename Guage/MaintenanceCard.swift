//
//  MaintenanceCard.swift
//  Guage
//
//  Created by Jonathan Corpuz on 2025-12-13.
//

import SwiftUI

struct MaintenanceCard: View {
    let title: String
    let kilometers: Int
    
    /// Display status of the item
    ///
    /// Expected values are: "Overdue Maintenance", "Upcoming Maintenance", or "Modifications"
    /// any other string defaults to '.menuBlack'
    let status: String
    
    var statusColor: Color {
        switch status {
        case "Overdue Maintenance":
            return .red
            
        case "Upcoming Maintenance":
            return .yellow
            
        case "Modifications":
            return .blue
            
        default:
            return .menuBlack
        }
    }
    
    var body: some View {
        ZStack() {
            Color.menuWhite
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 15) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(Color.menuBlack)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    
                    Text("\(kilometers)km")
                        .font(.system(size:14))
                        .foregroundStyle(Color.menuBlack)
                }
                .padding(20)
                
                Divider()
                    .background(Color.menuWhite)
                
                HStack(spacing: 12) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 10, height: 10)
                    
                    Text(status)
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
    MaintenanceCard(title: "Oil Change", kilometers: 19000, status: "Upcoming Maintenance")
}
