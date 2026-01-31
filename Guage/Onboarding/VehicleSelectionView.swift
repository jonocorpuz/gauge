import SwiftUI

struct VehicleSelectionView: View {
    @Binding var isOnboardingComplete: Bool
    @ObservedObject var store: CarDataStore
    
    @State private var year: String = ""
    @State private var make: String = ""
    @State private var model: String = ""
    @State private var mileage: String = ""
    @State private var showLoading: Bool = false
    
    var isFormValid: Bool {
        !year.isEmpty && !make.isEmpty && !model.isEmpty && !mileage.isEmpty
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(spacing: 24) {
                Image("onboarding1")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 200, maxHeight: 200)
                
                Text("Tell us more...")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(Color.menuBlack)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("We'll customize the experience for your specific vehicle.")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(spacing: 16) {
                    InputField(placeholder: "Year", text: $year, keyboardType: .numberPad)
                    InputField(placeholder: "Make", text: $make)
                    InputField(placeholder: "Model", text: $model)
                    InputField(placeholder: "Mileage", text: $mileage, keyboardType: .numberPad)
                }
                .padding(.top, 20)
                
                Spacer()
                
                Button(action: {
                    completeSelection()
                }) {
                    Text("Enter")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(isFormValid ? Color.menuBlack : Color.gray.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(!isFormValid)
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 32)
        }
        .ignoresSafeArea(.keyboard) // Prevent layout shift on keyboard
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $showLoading) {
            LoadingView(isOnboardingComplete: $isOnboardingComplete)
        }
    }
    
    private func completeSelection() {
        store.updateCarDetails(year: year, make: make, model: model, mileage: Int(mileage) ?? 0)
        showLoading = true // Init loading screen
    }
}

#Preview {
    VehicleSelectionView(
        isOnboardingComplete: .constant(false),
        store: CarDataStore()
    )
}
