import SwiftUI

struct LoadingView: View {
    @Binding var isOnboardingComplete: Bool
    @State private var currentIndex = 0
    @State private var timer: Timer?
    
    private let images = ["car_volkswagen_golf", "car_new_lexus_is", "car_bmw_m3"]
    private let texts = ["Setting up your garage...", "Fetching vehicle compatibility...", "Finalizing your profile..."]
    
    var body: some View {
        VStack {
            Spacer()
            
            if currentIndex < images.count {
                Image(images[currentIndex])
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .transition(.opacity.animation(.easeInOut(duration: 0.5)))
                    .id(currentIndex)
            }
            
            Spacer().frame(height: 40)
            
            // Loading Text
            if currentIndex < texts.count {
                Text(texts[currentIndex])
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.gray)
                    .transition(.opacity)
                    .id(currentIndex)
            } else {
                Text("Ready!")
                   .font(.system(size: 16, weight: .medium))
                   .foregroundStyle(Color.gray)
            }
            
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            startSlideshow()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func startSlideshow() {
        // Total duration 6 seconds. 3 slides. 2.0s per slide.
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            if currentIndex < images.count - 1 {
                withAnimation {
                    currentIndex += 1
                }
            } else {
                timer?.invalidate()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        isOnboardingComplete = true
                    }
                }
            }
        }
    }
}

#Preview {
    LoadingView(isOnboardingComplete: .constant(false))
}
