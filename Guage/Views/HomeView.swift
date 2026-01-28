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
    @State private var showUpdateKmSheet = false
    @State private var showDynoSheet = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
                HStack {
                    NavigationLink {
                        SettingsView(store: CarDataStore())
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Color.menuBlack)
                    }
                }
                .padding(.trailing, 40)
                .padding(.top, 20)
                
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
                    
                    Image("m340i")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(30)
                        .frame(maxWidth: 700, maxHeight: 700)
                    
                    Spacer()
                    
                    HStack(spacing: 20) {
                        Button(action: {
                            showUpdateKmSheet = true
                        }) {
                            Image(systemName: "speedometer")
                        }
                        
                        Button(action: {
                            showAddSheet = true
                        }) {
                            Image(systemName: "plus.app.fill")
                        }
                        
                        Button(action: {
                            showDynoSheet = true
                        }) {
                            Image(systemName: "checkmark.shield.fill")
                        }
                        
                    }
                    .buttonStyle(DashboardButtonStyle())
                    .padding(.bottom, 100)
                }
                
                Text(store.connectionStatus)
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .padding(.bottom, 20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            .sheet(isPresented: $showAddSheet) {
                AddItemView(store: store)
            }
            
            .sheet(isPresented: $showUpdateKmSheet) {
                UpdateMileageView(store: store)
            }
        }
    }
}

/// Standardized circular button style for main dashboard
///
/// This style applies a circular clip shape with dimension 70x70, and a "press" animation
/// that inverts the circle colour and icon colour when tapped by the user
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
