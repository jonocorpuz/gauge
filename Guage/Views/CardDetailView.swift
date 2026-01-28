import SwiftUI

struct CardDetailView: View {
    let item: MaintenanceItem
    @ObservedObject var store: CarDataStore
    @Environment(\.dismiss) var dismiss
    
    private func computeProgress() -> (progress: Double, label: String, value: String, targetText: String) {
        let current = Double(store.carInfo.currentMileage)
        let last = Double(item.lastServiceMileage ?? 0)
        let interval = Double(item.intervalMileage)
        let target = last + interval
        
        let progress = max(0, (current - last) / max(1, interval))
        let remaining = target - current
        
        let label = remaining > 0 ? "Remaining" : "Overdue"
        let value = "\(Int(max(0, abs(remaining)))) km"
        let targetText = "Target: \(Int(target)) km"
        
        return (progress, label, value, targetText)
    }
    
    var body: some View {
        ZStack {
            Color.menuWhite.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    ZStack {
                        Text(item.title)
                            .font(.system(size: 18, weight: .semibold))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundStyle(Color.menuBlack)
                            .padding(.horizontal, 40)
                        
                        HStack {
                            Button(action: { dismiss() }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 24))
                                    .foregroundStyle(Color.menuBlack)
                            }
                            Spacer()
                        }
                    }
                    
                    let result = computeProgress()
                    ServiceHealthCard(
                        progress: result.progress,
                        valueText: result.value,
                        labelText: result.label,
                        targetText: result.targetText
                    )
                    .transition(.scale.combined(with: .opacity))

                    if !item.history.isEmpty {
                        VStack(alignment: .leading, spacing: 0) {
                            
                            Text("History")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.menuBlack)
                                .padding(.horizontal, 24) // Match row padding
                                .padding(.top, 24)
                                .padding(.bottom, 16)
                            
                            // 1. Sort history
                            let sortedHistory = item.history.sorted(by: { $0.date > $1.date })
                            
                            // 2. Iterate with index to find the last item
                            ForEach(Array(sortedHistory.enumerated()), id: \.element.id) { index, event in
                                HistoryRow(
                                    event: event,
                                    title: item.title,
                                    isLast: index == sortedHistory.count - 1 // Pass this flag
                                )
                            }
                        }
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
                .padding(24)
            }
        }
    }
}

#Preview {
    CardDetailView(
        item: MaintenanceItem(
            title: "Oil Change",
            intervalMileage: 5000,
            history: [
                MaintenanceEvent(date: Date(), mileage: 125000),
                MaintenanceEvent(date: Date().addingTimeInterval(-86400 * 90), mileage: 120000),
                MaintenanceEvent(date: Date().addingTimeInterval(-86400 * 180), mileage: 115000)
            ]
        ),
        store: CarDataStore()
    )
}
