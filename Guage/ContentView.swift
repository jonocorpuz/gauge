//
//  ContentView.swift
//  Guage
//
//  Created by Jonathan Corpuz on 2025-12-11.
//

import SwiftUI

struct ContentView: View {
    // 1. Create the Data Store ONCE here at the root level
    @StateObject var store = CarDataStore()
    @State var selectedTab: Int = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView(store: store)
                    .tag(0)
                
                MaintenanceView(store: store)
                    .tag(1)
            }
            .toolbar(.hidden, for: .tabBar)
            
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack {
            TabBarButton(icon: "steeringwheel", isActive: selectedTab == 0) {
                selectedTab = 0
            }
            
            TabBarButton(icon: "wrench.and.screwdriver.fill", isActive: selectedTab == 1) {
                selectedTab = 1
            }
        }
        .padding(.top, 20)
        .padding(.bottom, 20)
        .padding(.horizontal, 40)
        .frame(maxWidth: .infinity)
        .background(Color.black)
        .ignoresSafeArea()
    }
}

struct TabBarButton: View {
    let icon: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
            }
            .foregroundStyle(isActive ? .white: .gray)
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    ContentView()
}
