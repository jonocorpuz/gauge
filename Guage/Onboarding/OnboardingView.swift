import SwiftUI

/// Main container for the onboarding flow.
/// Manages the state and transition between different onboarding steps.
struct OnboardingView: View {
    var store: CarDataStore
    
    @Binding var isOnboardingComplete: Bool
    @State private var currentStepIndex: Int = 0
    
    // Enum defining the steps of the onboarding process
    private let steps: [OnboardingItem] = [
        .welcome,
        .track,
        .modifications
    ]
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    VStack(spacing: 0) {
                        // Top Area (60%)
                        Color.menuWhite
                            .frame(height: geometry.size.height * 0.60 + geometry.safeAreaInsets.top)
                            .offset(y: -geometry.safeAreaInsets.top - 20) // Pull up to cover
                        
                        // Bottom Area (40%)
                        Color.white
                            .frame(height: geometry.size.height * 0.40 + geometry.safeAreaInsets.bottom)
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                            .offset(y: -30)
                            .padding(.bottom, -30)
                    }
                    
                    VStack {
                        ZStack {
                            ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                                if index == currentStepIndex {
                                    Image(step.imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: geometry.size.width * 0.9, maxHeight: geometry.size.height * 0.9)
                                        .foregroundStyle(Color.menuBlack)
                                        .transition(.opacity.animation(.easeInOut(duration: 0.4)))
                                }
                            }
                        }
                        .frame(height: geometry.size.height * 0.60)
                        .frame(maxWidth: .infinity)
                        
                        Spacer()
                    }
                    
                    TabView(selection: $currentStepIndex) {
                        ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                            OnboardingPageContent(item: step)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    
                    VStack {
                        Spacer()
                        
                        HStack(spacing: 8) {
                            ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                                Circle()
                                    .fill(currentStepIndex == index ? Color.menuBlack : Color.gray.opacity(0.3))
                                    .frame(width: 8, height: 8)
                                    .animation(.spring(), value: currentStepIndex)
                            }
                        }
                        .padding(.bottom, 20)
                        
                        NavigationLink(destination: VehicleSelectionView(isOnboardingComplete: $isOnboardingComplete, store: store)) {
                            Text("Get Started")
                                .font(.system(size: 16, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.menuBlack)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .padding(.horizontal, 32)
                        .padding(.bottom, 60)
                    }
                }
            }
            .ignoresSafeArea()
        }
    }
}

struct OnboardingItem: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let description: String
    
    static let welcome = OnboardingItem(
        imageName: "onboarding1",
        title: "Your Digital Binder",
        description: "Keep your maintenance history and build logs in one clean, searchable place."
    )
    
    static let track = OnboardingItem(
        imageName: "onboarding2",
        title: "Smart Tracking",
        description: "Gauge calculates exactly how many kilometers remain until your next service live."
    )
    
    static let modifications = OnboardingItem(
        imageName: "onboarding3", // Placeholder for mods
        title: "Track Your Build",
        description: "Not just for oil changes. separate your essential maintenance from your performance modifications."
    )
}

#Preview {
    OnboardingView(store: CarDataStore(), isOnboardingComplete: .constant(false))
}
