import SwiftUI

struct DynoView: View {
    @ObservedObject var store: CarDataStore
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    ZStack {
                        Text("Dyno View")
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
                    
                    SpecCard(
                        title: "Horsepower",
                        value: "\(store.car.specs.horsepower)",
                        unit: "hp",
                        maxValue: 500
                    )
                    
                    SpecCard(
                        title: "Torque",
                        value: "\(store.car.specs.torque)",
                        unit: "ft-lbs",
                        maxValue: 500
                    )
                    
                    SpecCard(
                        title: "0-60mph",
                        value: "\(store.car.specs.zeroToSixty)",
                        unit: "s",
                        maxValue: 15
                    )
                    
                    SpecCard(
                        title: "Efficiency",
                        value: "\(store.car.specs.efficiency)",
                        unit: "L/100km",
                        maxValue: 20
                    )
                }
                .padding(24)
            }
        }
    }
}

struct SpecCard: View {
    let title: String
    let value: String
    let unit: String
    let maxValue: Double
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(value)\(unit)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.menuBlack)
                }
            }
            
            Spacer()
            
            ZStack {
                Circle()
                    .stroke(Color.white, lineWidth: 8)
                
                Circle()
                    .trim(from: 0, to: calculateProgress())
                    .stroke(Color.menuBlack, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.spring, value: value)
            }
            .frame(width: 60, height: 60)
            .padding(.trailing, 8)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.menuWhite)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    func calculateProgress() -> Double {
        let current = Double(value) ?? 0
        return current / maxValue
    }
}

#Preview {
    DynoView(store: CarDataStore())
}

