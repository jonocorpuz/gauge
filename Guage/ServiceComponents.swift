//
//  ServiceComponents.swift
//  Guage
//
//  Created by Jonathan Corpuz on 2026-01-10.
//

import SwiftUI

struct ServiceHealthCard: View {
    let progress: Double
    let valueText: String
    let labelText: String
    let targetText: String
    
    var statusColor: Color {
        if progress >= 1.0 {
            return .red
        }
        
        if progress >= 0.9 {
            return .orange
        }
        
        return .menuGreenAccent
    }
    
    var statusTitle: String {
        if progress >= 1.0 {
            return "Overdue"
        }
        
        if progress >= 0.9 {
            return "Due Soon"
        }
        
        return "Healthy"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(statusTitle)
                        .font(.headline)
                        .foregroundStyle(statusColor)
                    
                    Text(valueText)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.menuBlack)
                }
                
                Spacer()
                
                Text(labelText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 6)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 16)
                    
                    Capsule()
                        .fill(statusColor)
                        .frame(width: min(geo.size.width * progress, geo.size.width), height: 16)
                        .animation(.spring, value: progress)
                }
            }
            .frame(height: 16)
            
            HStack {
                Image(systemName: "flag.checkered")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(targetText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(24)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20)
            .stroke(Color.gray.opacity(0.1), lineWidth: 1))
    }
}

struct HistoryRow: View {
    let event: MaintenanceEvent
    let title: String
    let isLast: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(Color.menuGreenAccent)
                        .frame(width: 30, height: 30)
                    
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.white)
                }
                
                if !isLast {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 1)
                        .frame(maxHeight: .infinity)
                        .padding(.vertical, 6)
                }
            }
            .frame(width: 32)
            .padding(.top, 10)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
                
                Text(event.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.menuBlack)
            }
            .padding(.top, 4)
            .padding(.bottom, 32)
            
            Spacer()

            Text("\(event.mileage) km")
                .font(.system(size: 14, design: .monospaced))
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .padding(.top, 10)
        }
        .padding(.horizontal, 24)
    }
}
