import SwiftUI
import PhotosUI // 📸 Required for the photo picker

struct AddMaintenanceView: View {
    @ObservedObject var store: CarDataStore
    
    // Allows the sheet to close itself
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String = ""
    @State private var date: Date = Date()
    @State private var mileage: String = ""
    @State private var notes: String = ""
    @State private var selectedType: EntryType = .maintenance
    @State private var interval: String = ""
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: Image? = nil
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Title", text: $title)
                    
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    
                    TextField("Odometer", text: $mileage)
                        .keyboardType(.numberPad)
                }
                
                Section("Category") {
                    Picker("Type", selection: $selectedType) {
                        ForEach(EntryType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)

                    // Only ask for "Repeat Interval" if it is Maintenance
                    if selectedType == .maintenance {
                        HStack {
                            Text("Repeat every:")
                            TextField("e.g. 5000", text: $interval)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                            Text("km")
                        }
                    }
                }
                
                Section("Notes") {
                    ZStack(alignment: .topLeading) {
                        if notes.isEmpty {
                            Text("Add details, part numbers, or costs...")
                                .foregroundStyle(.gray.opacity(0.5))
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        
                        TextEditor(text: $notes)
                            .frame(height: 100)
                    }
                }
                
                Section("Photos") {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        if let selectedImage {
                            selectedImage
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .frame(maxWidth: .infinity)
                        } else {
                            HStack {
                                Image(systemName: "camera.fill")
                                Text("Add Photo")
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundStyle(.blue)
                        }
                    }
                }
            }
            .navigationTitle("New Record")
            .navigationBarTitleDisplayMode(.inline)
            
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveRecord()
                    }
                    .fontWeight(.bold)
                    .disabled(title.isEmpty)
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
    
    /// Creates new maintenance record, and dissmisses the view
    ///
    /// This function converts raw text strings into Integer values
    /// - Note: If the mileage or interval strings are non-numeric, they default to 0
    /// - Note: This function dissmisses sheet after saving object
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

#Preview {
    AddMaintenanceView(store: CarDataStore())
}
