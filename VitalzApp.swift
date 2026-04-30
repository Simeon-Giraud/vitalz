import SwiftUI

@main
struct VitalzApp: App {
    // Top-level listener for onboarding state
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                Color.vitalzBackground.ignoresSafeArea()
                
                if hasCompletedOnboarding {
                    // Start in the Main Tab View once Onboarding completes
                    MainTabView()
                        .transition(.opacity)
                } else {
                    OnboardingView()
                        .transition(.opacity)
                }
            }
            .preferredColorScheme(.dark)
            // Force animation on state change
            .animation(.easeInOut(duration: 0.8), value: hasCompletedOnboarding)
        }
    }
}
