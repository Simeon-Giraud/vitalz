import SwiftUI

public struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @AppStorage("appTheme") private var appTheme: Int = 0 // 0: System, 1: Light, 2: Dark
    
    // Visibility Toggles
    @AppStorage("showSecondsAlive") private var showSecondsAlive: Bool = true
    @AppStorage("showHeartbeats") private var showHeartbeats: Bool = true
    @AppStorage("showBreathsTaken") private var showBreathsTaken: Bool = true
    @AppStorage("showTimesBlinked") private var showTimesBlinked: Bool = true
    @AppStorage("showHairGrowth") private var showHairGrowth: Bool = true
    @AppStorage("showSpaceTraveler") private var showSpaceTraveler: Bool = true
    
    @State private var selectedTab: Int = 1 // 0: Appearance, 1: Dashboard
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.vitalzBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Settings")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.vitalzText)
                    
                    Spacer()
                    
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.vitalzSecondaryText)
                            .padding(10)
                            .background(Color.vitalzControl)
                            .clipShape(Circle())
                    }
                }
                .padding(24)
                
                // Segmented Control
                HStack(spacing: 8) {
                    TabButton(title: "Appearance", isSelected: selectedTab == 0) { selectedTab = 0 }
                    TabButton(title: "Dashboard", isSelected: selectedTab == 1) { selectedTab = 1 }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        if selectedTab == 0 {
                            appearanceSection
                        } else {
                            dashboardSection
                        }
                    }
                    .padding(24)
                    .padding(.bottom, 40)
                }
            }
        }
        .presentationDetents([.large])
    }
    
    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Picker("Theme", selection: $appTheme) {
                Text("System").tag(0)
                Text("Light").tag(1)
                Text("Dark").tag(2)
            }
            .pickerStyle(.segmented)
            .padding(16)
            .background(Color.vitalzCard)
            .cornerRadius(16)
        }
    }
    
    private var dashboardSection: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Manage Visibility")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.vitalzSecondaryText)
                
                VStack(spacing: 0) {
                    ToggleRow(title: "Seconds Alive", isOn: $showSecondsAlive, isTop: true)
                    Divider().background(Color.vitalzDivider).padding(.leading, 56)
                    ToggleRow(title: "Heartbeats", isOn: $showHeartbeats)
                    Divider().background(Color.vitalzDivider).padding(.leading, 56)
                    ToggleRow(title: "Breaths Taken", isOn: $showBreathsTaken)
                    Divider().background(Color.vitalzDivider).padding(.leading, 56)
                    ToggleRow(title: "Times Blinked", isOn: $showTimesBlinked)
                    Divider().background(Color.vitalzDivider).padding(.leading, 56)
                    ToggleRow(title: "Hair Growth", isOn: $showHairGrowth)
                    Divider().background(Color.vitalzDivider).padding(.leading, 56)
                    ToggleRow(title: "Space Traveler", isOn: $showSpaceTraveler, isBottom: true)
                }
                .background(Color.vitalzCard)
                .cornerRadius(16)
            }
            
            Spacer().frame(height: 32)
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.8)) {
                    hasCompletedOnboarding = false
                }
            }) {
                Text("Reset Identity")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.vitalzCard)
                    .cornerRadius(16)
            }
        }
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .vitalzSecondaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isSelected ? Color.vitalzBlue : Color.vitalzControl)
                .cornerRadius(20)
        }
    }
}

struct ToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    var isTop: Bool = false
    var isBottom: Bool = false
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "eye")
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.vitalzText)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.blue)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

#Preview {
    SettingsView()
}
