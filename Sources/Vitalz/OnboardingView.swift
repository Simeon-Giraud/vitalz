import SwiftUI

public struct OnboardingView: View {
    @EnvironmentObject private var profileStore: ProfileStore
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    @State private var step: Int = 0
    @State private var selectedDate: Date = Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date()
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.vitalzBackground.ignoresSafeArea()
            
            Group {
                if step == 0 {
                    welcomeScreen
                } else if step == 1 {
                    sloganScreen
                } else {
                    datePickerScreen
                }
            }
            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
        }
        .tint(.vitalzBlue)
    }
    
    private var welcomeScreen: some View {
        VStack {
            Spacer()
            Text("Welcome to Vitalz").font(.system(size: 34, weight: .bold, design: .serif)).foregroundColor(.vitalzText)
            Spacer()
            glassButton("Continue") { withAnimation { step = 1 } }
        }
    }
    
    private var sloganScreen: some View {
        VStack {
            Spacer()
            Text("Every second of your life\ndeserves to be noticed.")
                .font(.system(size: 26, weight: .regular, design: .serif))
                .foregroundColor(.vitalzText)
                .multilineTextAlignment(.center)
            Spacer()
            glassButton("Next") { withAnimation { step = 2 } }
        }
    }
    
    private var datePickerScreen: some View {
        VStack {
            Text("Select Date of Birth").foregroundColor(.vitalzSecondaryText)
            DatePicker("", selection: $selectedDate, in: ...Date(), displayedComponents: [.date])
                .datePickerStyle(.graphical)
                .padding()
            glassButton("Begin", action: finishOnboarding)
        }
    }
    
    @ViewBuilder
    private func glassButton(_ title: String, action: @escaping () -> Void) -> some View {
        if #available(iOS 26.0, *) {
            Button(action: action) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color.vitalzBackground)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.glassProminent)
            .tint(.vitalzText)
            .padding(.horizontal, 40)
        } else {
            Button(action: action) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.vitalzBackground)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.vitalzText)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.vitalzDivider, lineWidth: 1))
                    )
                    .padding(.horizontal, 40)
            }
        }
    }
    
    private func finishOnboarding() {
        profileStore.updateProfile(
            id: profileStore.selectedProfile.id,
            name: profileStore.selectedProfile.name,
            dateOfBirth: selectedDate,
            imageData: profileStore.selectedProfile.imageData
        )
        
        // Trigger a smooth transition to the main app state
        withAnimation(.easeInOut(duration: 1.0)) {
            hasCompletedOnboarding = true
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(ProfileStore())
}
