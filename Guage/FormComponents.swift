//
//  FormComponents.swift
//  Guage
//
//  Created by Jonathan Corpuz on 2026-01-07.
//

import SwiftUI
import PhotosUI

struct inputField: View {
    let placeholder: String
    @Binding var text: String
    var height: CGFloat = 50
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField(placeholder, text: $text, axis: .vertical)
                .padding()
                .frame(height: height, alignment: .top)
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

struct DateField: View {
    @Binding var date: Date?
    
    @State private var internalDate: Date = Date()
    
    var body: some View {
            ZStack(alignment: .leading) {
                HStack {
                    if let validDate = date {
                        // State: Date Selected
                        Text(validDate.formatted(date: .numeric, time: .omitted))
                            .foregroundStyle(Color.menuBlack)
                    } else {
                        // State: Placeholder
                        Text("Date")
                            .foregroundStyle(Color.gray.opacity(0.5))
                    }
                    Spacer()
                }
                .padding()
                .frame(height: 50)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                
                DatePicker("", selection: $internalDate, displayedComponents: .date)
                    .labelsHidden()
                    .colorMultiply(.clear)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onChange(of: internalDate) {
                        date = internalDate
                }
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

struct CustomToggle: View {
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Spacer()
            
            ZStack {
                Capsule()
                    .fill(isOn ? Color.menuBlack : Color.menuWhite)
                    .frame(width: 50, height: 30)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 26, height: 26)
                    .offset(x: isOn ? 10 : -10)
            }
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isOn.toggle()
                }
            }
        }
        .padding()
        .background(Color.white)
    }
}

