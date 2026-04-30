import SwiftUI

public struct OnboardingView: View {
    // Use AppStorage to save data locally. Since Date isn't natively supported, we store the Unix timestamp.
    @AppStorage("userDOBTimestamp") private var userDOBTimestamp: Double = 0
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    // Default the date picker to roughly 25 years in the past for user convenience
    @State private var selectedDate: Date = Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date()
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Ultra-minimal Pure Black background
            Color.vitalzBackground
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // The requested tagline
                Text("Every second of your life\ndeserves to be noticed.")
                    .font(.system(size: 26, weight: .regular, design: .serif))
                    .foregroundColor(.vitalzText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
                    .padding(.horizontal, 32)
                
                Spacer()
                
                VStack(spacing: 32) {
                    // Date Entry Section
                    VStack(alignment: .center, spacing: 12) {
                        Text("SELECT DATE OF BIRTH")
                            .font(.system(size: 12, weight: .semibold, design: .default))
                            .foregroundColor(.gray)
                            .kerning(1.2)
                        
                        DatePicker(
                            "Date of Birth",
                            selection: $selectedDate,
                            in: ...Date(), // Prevent user from selecting future dates
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .environment(\.colorScheme, .dark)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.vitalzCard)
                        .cornerRadius(16)
                    }
                    .padding(.horizontal, 40)
                    
                    // Begin Button
                    Button(action: finishOnboarding) {
                        Text("Begin")
                            .font(.system(size: 20, weight: .semibold, design: .serif))
                            // Dark text on gold background
                            .foregroundColor(.vitalzBackground)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.vitalzGold)
                            .cornerRadius(16)
                            // Very subtle shadow to pop the button a bit
                            .shadow(color: Color.vitalzGold.opacity(0.15), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 60)
                }
            }
        }
        // Ensuring the DatePicker's pop-up calendar respects the app's aesthetic
        .preferredColorScheme(.dark)
        .tint(.vitalzGold)
    }
    
    private func finishOnboarding() {
        // Save the date as a Unix Timestamp locally
        userDOBTimestamp = selectedDate.timeIntervalSince1970
        
        // Trigger a smooth transition to the main app state
        withAnimation(.easeInOut(duration: 1.0)) {
            hasCompletedOnboarding = true
        }
    }
}

#Preview {
    OnboardingView()
}
