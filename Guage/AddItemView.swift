import SwiftUI
import PhotosUI

struct AddMaintenanceView: View {
    @ObservedObject var store: CarDataStore
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var selectedImage: Image? = nil
    
    @State private var title: String = ""
    @State private var mileage: String = ""
    @State private var interval: String = ""
    @State private var notes: String = ""
    @State private var date: Date = Date()
    @State private var selectedType: EntryType = .maintenance

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    ZStack {
                        Text("New Item")
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
                            placeholder: "Title",
                            text: $title
                        )
                        
                        HStack {
                            inputField(
                                placeholder: "Odometer",
                                text: $mileage,
                                keyboardType: .numberPad
                            )
                            
                            VStack(alignment: .leading, spacing: 8) {
                                DatePicker("", selection: $date, displayedComponents: .date)
                                    .labelsHidden()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.menuWhite, lineWidth: 1)
                                    )
                            }
                            .frame(height: 50)
                        }
                    }
                    
                    VStack(spacing: 16) {
                        Text("Type")
                            .font(.system(size: 16, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(Color.menuBlack)
                            .padding(.top, 12)
                        
                        HStack(spacing: 12) {
                            TypeButton(
                                title: "Maintenance",
                                isSelected: selectedType == .maintenance,
                                action: {
                                    withAnimation { selectedType = .maintenance }
                                }
                            )
                            
                            TypeButton(
                                title: "Modification",
                                isSelected: selectedType == .modification,
                                action: {
                                    withAnimation { selectedType = .modification }
                                }
                            )
                        }
                        
                        if selectedType == .maintenance {
                            inputField(
                                placeholder: "Service Interval",
                                text: $interval,
                                keyboardType: .numberPad
                            )
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }
                    
                    VStack(spacing: 16) {
                        Text("Photos")
                            .font(.system(size: 16, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(Color.menuBlack)
                            .padding(.top, 12)
                        
                            PhotoInputBox(
                                selectedItem: $selectedPhotoItem,
                                selectedImage: $selectedImage
                            )
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
        let mileageInt = Int(mileage) ?? 0
        let dateInt = Int(date.timeIntervalSince1970)
        
        // Logic: Force interval to 0 if it's a Modification
        let intervalInt = (selectedType == .maintenance) ? (Int(interval) ?? 0) : 0

        let newItem = MaintenanceItem(
            title: title,
            notes: notes,
            type: selectedType,
            intervalMileage: intervalInt,
            lastServiceMileage: mileageInt,
            lastServiceDate: dateInt
        )
        
        store.car.maintenanceItems.append(newItem)
        dismiss()
    }
}

struct inputField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField(placeholder, text: $text)
                .padding()
                .frame(height: 50)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.menuWhite, lineWidth: 1)
                )
                .keyboardType(keyboardType)
        }
    }
}

struct TypeButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(isSelected ? Color.menuBlack : Color.white)
                .foregroundStyle(isSelected ? .white : Color.menuBlack)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.menuWhite, lineWidth: isSelected ? 0 : 1)
                )
        }
    }
}

struct PhotoInputBox: View {
    @Binding var selectedItem: PhotosPickerItem?
    @Binding var selectedImage: Image?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            PhotosPicker(selection: $selectedItem, matching: .images) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .frame(height: 150)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.menuWhite, lineWidth: 1)
                        )
                    
                    if let selectedImage {
                        selectedImage
                            .resizable()
                            .scaledToFill()
                            .frame(height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    else {
                        VStack(spacing: 8) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 30))
                                .foregroundStyle(Color.menuBlack)
                            
                            Text("Tap to add photo")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.gray)
                        }
                    }
                }
            }
            .onChange(of: selectedItem) {
                Task {
                    if let data = try? await selectedItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        selectedImage = Image(uiImage: uiImage)
                    }
                }
            }
        }
    }
}

#Preview {
    AddMaintenanceView(store: CarDataStore())
}
