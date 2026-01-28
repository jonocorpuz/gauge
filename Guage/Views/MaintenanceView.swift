//
//  MaintenanceView.swift
//  Guage
//
//  Created by Jonathan Corpuz on 2025-12-13.
//

import SwiftUI

struct MaintenanceView: View {
    @ObservedObject var store: CarDataStore
    
    @State private var showAddSheet = false
    @State private var selectedItem: MaintenanceItem?
    
    var body: some View {
        ZStack() {
            Color.menuWhite
                .ignoresSafeArea()
            
            VStack(spacing: -45) {
                VStack(spacing: 40) {
                    VStack(spacing: 6) {
                        Text("Mods & Maintenance")
                            .font(.system(size: 32, weight: .bold, design: .default))
                            .foregroundStyle(Color.menuBlack)
                        
                        Text("Log your service history, repairs, and new modifications here!")
                            .font(.system(size: 14, design: .default))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                    }
                    
                    Button(action: {
                        showAddSheet = true
                    }) {
                        HStack {
                            Text("Record Item")
                                .fontWeight(.bold)
                        }
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .padding(20)
                        .background(Color.menuBlack)
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .padding(.top, 120)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(store.car.maintenanceItems) { item in
                            Button(action: {
                                selectedItem = item
                            }) {
                                MaintenanceCard(
                                    title: item.title,
                                    kilometers: item.lastServiceMileage ?? 0,
                                    status: item.type == .modification ? "Modifications" : "Maintenance"
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            
            .sheet(isPresented: $showAddSheet) {
                AddItemView(store: store)
            }
            
            .sheet(item: $selectedItem) { item in
                CardDetailView(item: item, store: store)
                    .presentationDetents([.large])
            }
        }
    }
}

#Preview {
    MaintenanceView(store: CarDataStore())
}
