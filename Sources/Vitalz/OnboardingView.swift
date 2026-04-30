import SwiftUI

public struct OnboardingView: View {
    @AppStorage("userDOBTimestamp") private var userDOBTimestamp: Double = 0
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    @State private var step: Int = 0
    @State private var selectedDate: Date = Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date()
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
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
        .tint(.white)
    }
    
    private var welcomeScreen: some View {
        VStack {
            Spacer()
            Text("Welcome to Vitalz").font(.system(size: 34, weight: .bold, design: .serif)).foregroundColor(.white)
            Spacer()
            glassButton("Continue") { withAnimation { step = 1 } }
        }
    }
    
    private var sloganScreen: some View {
        VStack {
            Spacer()
            Text("Every second of your life\ndeserves to be noticed.")
                .font(.system(size: 26, weight: .regular, design: .serif))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            Spacer()
            glassButton("Next") { withAnimation { step = 2 } }
        }
    }
    
    private var datePickerScreen: some View {
        VStack {
            Text("Select Date of Birth").foregroundColor(.gray)
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
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.glassProminent)
            .padding(.horizontal, 40)
        } else {
            Button(action: action) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.1))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.2), lineWidth: 1))
                    )
                    .padding(.horizontal, 40)
            }
        }
    }
    
    private func finishOnboarding() {
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
