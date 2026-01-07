import SwiftUI
import PhotosUI // 📸 Required for the photo picker

struct AddMaintenanceView: View {
    @ObservedObject var store: CarDataStore
    @Environment(\.dismiss) var dismiss
    
    // 1. RE-ADD THE MISSING STATE VARIABLES (The Scratchpad)
    @State private var title: String = ""
    @State private var mileage: String = ""
    @State private var interval: String = ""
    @State private var notes: String = ""
    @State private var date: Date = Date()
    @State private var selectedType: EntryType = .maintenance // Make sure EntryType is public in Models

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    HStack{
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 30))
                                .foregroundStyle(Color.menuBlack)
                        }
                        
                        Spacer()
                    }
                    
                    Text("New Item")
                        .font(.system(size: 32, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(Color.menuBlack)
                        .padding(.top, 20)
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(Color.menuBlack)
                    
                    VStack(spacing: 16) {
                        Text("Details")
                            .font(.system(size: 16))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(Color.menuBlack)
                            .padding(.top, 12)
                        
                        inputField(
                            title: "Title",
                            text: $title
                        )
                        
                        inputField(
                            title: "Odometer",
                            text: $mileage,
                            keyboardType: .numberPad
                        )
                        
                        inputField(
                            title: "Date",
                            text: $interval,
                            keyboardType: .numberPad
                        )
                    }
                    
                    // Save Button
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
    
    // 3. NOW THIS FUNCTION WORKS AGAIN
    func saveRecord() {
        let mileageInt = Int(mileage) ?? 0
        let intervalInt = Int(interval) ?? 0
        let dateInt = Int(date.timeIntervalSince1970)

        let newItem = MaintenanceItem(
            title: title,
            notes: notes,
            intervalMileage: intervalInt,
            lastServiceMileage: mileageInt,
            lastServiceDate: dateInt
        )
        
        store.car.maintenanceItems.append(newItem)
        dismiss()
    }
}

struct inputField: View {
    let title: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField(title, text: $text)
                .padding()
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.menuWhite,lineWidth: 1))
                .keyboardType(keyboardType)
                
        }
    }
}

#Preview {
    AddMaintenanceView(store: CarDataStore())
}
