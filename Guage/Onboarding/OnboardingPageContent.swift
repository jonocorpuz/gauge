import SwiftUI

/// Represents the dynamic content (Image + Text) for a single onboarding page.
/// Designed to overlay a static background frame defined in the parent view.
struct OnboardingPageContent: View {
    let item: OnboardingItem
    
    var body: some View {
        VStack {
            Spacer()
                .frame(maxHeight: .infinity)
            
            VStack(spacing: 16) {
                Text(item.title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(Color.menuBlack)
                    .multilineTextAlignment(.center)
                
                Text(item.description)
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
                
                Spacer()
            }
            .frame(height: 300) // Approximate height for the bottom content area, or let it grow naturally
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    ZStack {
        Color.menuWhite.ignoresSafeArea()
        
        OnboardingPageContent(item: OnboardingItem.welcome)
    }
}
