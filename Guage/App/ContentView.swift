import SwiftUI

/// Root container for application navigation
///
/// Manages top level switching between home view and the
/// maintenance view.
///
/// Uses custom navigation bar.
struct ContentView: View {
    /// Data soruce for vehicle and maintenance logs
    ///
    /// - Note: Initialzed as '@StateObject' to ensure data persists as app is running
    @StateObject var store = CarDataStore()
    
    /// Currently active navigation tab
    ///
    /// - Note: Defaults to '.home' (HomeView.swift)
    @State var selectedTab: Tab = .home
    
    enum Tab {
        case home, maintenance
    }
    
    var body: some View {
        ZStack {
            switch selectedTab {
                case .home: HomeView(store: store)
                case .maintenance: MaintenanceView(store: store)
            }
        }
        .safeAreaInset(edge: .bottom) {
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
    }
}

/// Custom navigation bar
struct CustomTabBar: View {
    @Binding var selectedTab: ContentView.Tab
    
    var body: some View {
        HStack {
            TabBarButton(icon: "steeringwheel", isActive: selectedTab == .home) {
                selectedTab = .home
            }
            
            TabBarButton(icon: "wrench.and.screwdriver.fill", isActive: selectedTab == .maintenance) {
                selectedTab = .maintenance
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

/// Single interactive button within the custom navigation bar
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
