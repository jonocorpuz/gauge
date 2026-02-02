import SwiftUI
import PhotosUI

struct UpdateMileageView: View {
    @ObservedObject var store: CarDataStore
    @Environment(\.dismiss) var dismiss
    
    @State private var mileage: String = ""
    @State private var date: Date? = nil

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    ZStack {
                        Text("Update Kms")
                            .font(.system(size: 32, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundStyle(Color.menuBlack)
                        
                        HStack {
                            Button(action: { dismiss() }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 30))
                                    .foregroundStyle(Color.menuBlack)
                            }
                            
                            Spacer()
                        }
                    }
                    
                    Text("Average Usage")
                        .font(.system(size: 16, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(Color.menuBlack)
                    
                    AverageMileageCard(context: store.mileageContext)
                    
                    VStack(spacing: 16) {
                        Text("Details")
                            .font(.system(size: 16, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(Color.menuBlack)
                        
                        InputField(
                            placeholder: "Odometer",
                            text: $mileage
                        )
                    
                    
                        DateField(date: $date)
                    }
                    
                    Button(action: saveRecord) {
                        Text("Save Entry")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(Color.menuBlack)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.top, 20)
                }
                .padding(24)
            }
        }
    }
    
    func saveRecord() {
        let newMileage = Int(mileage) ?? store.carInfo.currentMileage
        let entryDate = date ?? Date()
        
        store.updateMileage(
            date: entryDate,
            miles: newMileage
        )
        
        dismiss()
    }
}

// Custom Graphic for Average Km
// Custom Graphic for Average Km
struct AverageMileageCard: View {
    let context: CarDataStore.MileageContext
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text("Based on last 90 days")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text(String(format: "%.1f km", context.rate))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.menuBlack)
                }
                
                Spacer()
                
                Text("/ day")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 6)
            }
            
            // Meter Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.menuWhite)
                        .frame(height: 16)
                    
                    Capsule()
                        .fill(Color.menuGreenAccent)
                        .frame(width: max(0, min(geo.size.width * progress, geo.size.width)), height: 16)
                        .animation(.spring, value: progress)
                }
            }
            .frame(height: 16)
            
            if let start = context.start {
                VStack(alignment: .leading, spacing: 0) {
                    // Start Point
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color.menuWhite)
                            .frame(width: 8, height: 8)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "speedometer")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            
                            Text("\(formatKm(start.kilometers)) on \(formatDate(start.date))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    if let end = context.end {
                        // Connecting Line
                        Rectangle()
                            .fill(Color.menuWhite)
                            .frame(width: 1, height: 12)
                            .padding(.leading, 3.5) // Center of 8px circle (4) - half line (0.5) = 3.5
                        
                        // End Point
                        HStack(spacing: 12) {
                            Circle()
                                .fill(Color.menuWhite)
                                .frame(width: 8, height: 8)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "speedometer")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                
                                Text("\(formatKm(end.kilometers)) on \(formatDate(end.date))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .padding(24)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20)
            .stroke(Color.menuWhite, lineWidth: 1))
    }
    
    private func formatKm(_ km: Int) -> String {
        return "\(km)km"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
    
    var progress: Double {
        let minRate = 10.0
        let maxRate = 100.0
        let clamped = min(max(context.rate, minRate), maxRate)
        return (clamped - minRate) / (maxRate - minRate)
    }
}

#Preview {
    UpdateMileageView(store: CarDataStore())
}
