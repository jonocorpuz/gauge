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
                    
                    VStack(spacing: 16) {
                        Text("Details")
                            .font(.system(size: 16, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(Color.menuBlack)
                        
                        inputField(
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
        let newMileage = Int(mileage) ?? store.car.currentMileage
        let entryDate = date ?? Date()
        
        store.addMileageEntry(
            date: entryDate,
            miles: newMileage
        )
        
        dismiss()
    }
}

#Preview {
    UpdateMileageView(store: CarDataStore())
}
