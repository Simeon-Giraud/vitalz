import SwiftUI

@main
struct VitalzApp: App {
    // Top-level listener for onboarding state
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    // Theme preference: 0 = System, 1 = Light, 2 = Dark
    @AppStorage("appTheme") private var appTheme: Int = 0
    
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
            .preferredColorScheme(selectedColorScheme)
            // Force animation on state change
            .animation(.easeInOut(duration: 0.8), value: hasCompletedOnboarding)
        }
    }
    
    private var selectedColorScheme: ColorScheme? {
        switch appTheme {
        case 1: return .light
        case 2: return .dark
        default: return nil // System
        }
    }
}
