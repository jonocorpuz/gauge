//
//  UpdateMileageView.swift
//  Guage
//
//  Created by Jonathan Corpuz on 2026-01-07.
//

import SwiftUI
import PhotosUI

struct AddItemView: View {
    @ObservedObject var store: CarDataStore
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var selectedImage: Image? = nil
    
    @State private var title: String = ""
    @State private var mileage: String = ""
    @State private var interval: String = ""
    @State private var date: Date? = nil
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
                        
                        InputField(
                            placeholder: "Title",
                            text: $title
                        )
                        .onChange(of: title) {
                            if let existing = store.maintenanceItems.first(where: { $0.title.lowercased() == title.lowercased() }) {
                                interval = "\(existing.intervalMileage)"
                                selectedType = existing.type
                            }
                        }
                        
                        HStack {
                            InputField(
                                placeholder: "Odometer",
                                text: $mileage,
                                keyboardType: .numberPad
                            )
                            
                            DateField(date: $date)
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
                            InputField(
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
        .onAppear {
            mileage = "\(store.carInfo.currentMileage)"
            date = Date()
        }
    }
    
    func saveRecord() {
        let intervalInt = (selectedType == .maintenance) ? (Int(interval) ?? 0) : 0
        let mileageInt = Int(mileage) ?? 0
        let entryDate = date ?? Date()

        store.addOrUpdateMaintenanceItem(
            title: title,
            date: entryDate,
            mileage: mileageInt,
            interval: intervalInt,
            type: selectedType
        )
        
        dismiss()
    }
}

#Preview {
    AddItemView(store: CarDataStore())
}
