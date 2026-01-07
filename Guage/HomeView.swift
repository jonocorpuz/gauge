//
//  ContentView.swift
//  Guage
//
//  Created by Jonathan Corpuz on 2025-12-11.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @ObservedObject var store: CarDataStore
    
    @State private var showAddSheet = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
                // Top navigation bar
                Button(action: {
                    print("Settings Tapped")
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.title2)
                        .foregroundStyle(Color.menuBlack)
                        .padding()
                }
                .padding(.trailing, 20) // Fine-tune position from edge
                
                VStack(spacing: 0) {
                    
                    Spacer(minLength: 100)
                    
                    VStack(spacing: 1) {
                        Text("\(store.car.make) \(store.car.model)")
                            .font(.system(size: 42, weight: .bold, design: .default))
                            .foregroundStyle(Color.menuBlack)
                        
                        Text("\(store.car.currentMileage)km")
                            .font(.system(size: 14, design: .default))
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }

                    Spacer()
                    
                    Image("iteshome")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(30)
                        .frame(maxWidth: 700, maxHeight: 700)
                    
                    Spacer()
                    
                    HStack(spacing: 20) {
                        Button(action: { print("Update kms")}) {
                            Image(systemName: "speedometer")
                        }
                        
                        Button(action: {
                            showAddSheet = true
                        }) {
                            Image(systemName: "plus.app.fill")
                        }
                        
                        Button(action: { print("Status")}) {
                            Image(systemName: "checkmark.shield.fill")
                        }
                        
                    }
                    .buttonStyle(DashboardButtonStyle())
                    .padding(.bottom, 100)
                }
            }
            
            .sheet(isPresented: $showAddSheet) {
                AddMaintenanceView(store: CarDataStore())
            }
        }
    }
}

struct DashboardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 24, weight: .medium))
            .foregroundStyle(configuration.isPressed ? .white : Color.menuBlack)
            .frame(width: 70, height: 70)
            .background(configuration.isPressed ? Color.menuBlack : Color.menuWhite)
            .clipShape(Circle())
            .animation(.easeInOut(duration: 0.3), value: configuration.isPressed)
    }
}

#Preview {
    ContentView()
}
