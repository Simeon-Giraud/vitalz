import SwiftUI
import SwiftData

@main
struct VitalzApp: App {
    // Top-level listener for onboarding state
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    // Theme preference: 0 = System, 1 = Light, 2 = Dark
    @AppStorage("appTheme") private var appTheme: Int = 0

    @StateObject private var profileStore = ProfileStore()
    
    /// Signature decoded from an incoming `vitalz://` deep link.
    @State private var incomingSignature: VitalzSignature?
    
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
            .environmentObject(profileStore)
            .preferredColorScheme(selectedColorScheme)
            // Force animation on state change
            .animation(.easeInOut(duration: 0.8), value: hasCompletedOnboarding)
            .onOpenURL { url in
                guard let signature = VitalzSignature.decode(from: url)?.validated() else { return }
                incomingSignature = signature
            }
            .sheet(item: $incomingSignature) { sig in
                DeepLinkImportView(signature: sig)
                    .environmentObject(profileStore)
            }
        }
        .modelContainer(for: MilestoneVaultEntry.self)
    }
    
    private var selectedColorScheme: ColorScheme? {
        switch appTheme {
        case 1: return .light
        case 2: return .dark
        default: return nil // System
        }
    }
}
