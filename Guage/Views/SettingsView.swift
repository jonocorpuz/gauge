import SwiftUI

struct SettingsView: View {
    @ObservedObject var store: CarDataStore
    @Environment(\.dismiss) var dismiss
    
    @State private var year: String = ""
    @State private var make: String = ""
    @State private var model: String = ""
    
    @AppStorage("useMiles") private var useMiles: Bool = false
    @State private var showResetConfirmation = false

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 16) {
                    // --- HEADER ---
                    ZStack {
                        Text("Settings")
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
                        Text("Units")
                            .font(.system(size: 16, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(Color.menuBlack)
                            .padding(.top, 12)
                        HStack(spacing: 12) {
                            TypeButton(
                                title: "Metric (km)",
                                isSelected: !useMiles,
                                action: { withAnimation { useMiles = false } }
                            )
                            TypeButton(
                                title: "Imperial (mi)",
                                isSelected: useMiles,
                                action: { withAnimation { useMiles = true } }
                            )
                        }
                    }

                    VStack(spacing: 16) {
                        Text("Vehicle")
                            .font(.system(size: 16, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(Color.menuBlack)
                            .padding(.top, 12)
                        VStack(spacing: 12) {
                            InputField(placeholder: "Year", text: $year)
                            InputField(placeholder: "Make", text: $make)
                            InputField(placeholder: "Model", text: $model)
                        }
                    }

                    VStack(spacing: 16) {
                        Text("About")
                            .font(.system(size: 16, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(Color.menuBlack)
                            .padding(.top, 12)
                        VStack(spacing: 0) {
                            Text("Version 1.01")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(Color.menuBlack)
                                .padding(12)
                            Text("Build 01.12.2026")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(Color.menuBlack)
                                .padding(12)
                        }
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.menuWhite, lineWidth: 1)
                        )
                    }

                    VStack(spacing: 16) {
                        Button(action: { print("Test") }) {
                            Text("Export Data")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
                                .background(Color.menuBlack)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        Button(action: { showResetConfirmation = true }) {
                            Text("Reset")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
                                .background(Color.menuRedAccent)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .alert("Reset Data", isPresented: $showResetConfirmation) {
                            Button("Cancel", role: .cancel) { }
                            Button("Delete", role: .destructive) {
                                store.resetAllData()
                                dismiss()
                            }
                        } message: {
                            Text("Are you sure? This will delete ALL maintenance history from AWS. This cannot be undone.")
                        }
                    }
                    .padding(.top, 24)
                }
                .padding(24)
            }
        }
        .onAppear {
            year = store.carInfo.year
            make = store.carInfo.make
            model = store.carInfo.model
        }
    }
}

#Preview {
    SettingsView(store: CarDataStore())
}
