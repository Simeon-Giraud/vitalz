import SwiftUI
import PhotosUI

public struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @AppStorage("userDOBTimestamp") private var userDOBTimestamp: Double = 0
    @AppStorage("userName") private var userName: String = "Me"
    @AppStorage("appTheme") private var appTheme: Int = 0 // 0: System, 1: Light, 2: Dark
    @AppStorage("useMetricUnits") private var useMetricUnits: Bool = true
    
    // Visibility Toggles
    @AppStorage("showSecondsAlive") private var showSecondsAlive: Bool = true
    @AppStorage("showHeartbeats") private var showHeartbeats: Bool = true
    @AppStorage("showBreathsTaken") private var showBreathsTaken: Bool = true
    @AppStorage("showTimesBlinked") private var showTimesBlinked: Bool = true
    @AppStorage("showHairGrowth") private var showHairGrowth: Bool = true
    @AppStorage("showSpaceTraveler") private var showSpaceTraveler: Bool = true
    
    @State private var selectedTab: Int = 1 // 0: Appearance, 1: Dashboard, 2: Profiles
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var profileImage: Image?
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color(white: 0.1).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Settings")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.gray)
                            .padding(10)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding(24)
                
                // Segmented Control
                HStack(spacing: 8) {
                    TabButton(title: "Appearance", isSelected: selectedTab == 0) { selectedTab = 0 }
                    TabButton(title: "Dashboard", isSelected: selectedTab == 1) { selectedTab = 1 }
                    TabButton(title: "Profiles", isSelected: selectedTab == 2) { selectedTab = 2 }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        if selectedTab == 0 {
                            appearanceSection
                        } else if selectedTab == 1 {
                            dashboardSection
                        } else {
                            profilesSection
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
            .background(Color(white: 0.15))
            .cornerRadius(16)
        }
    }
    
    private var dashboardSection: some View {
        VStack(alignment: .leading, spacing: 32) {
            // Units
            HStack(spacing: 12) {
                Button(action: { useMetricUnits = true }) {
                    Text("km, kg, ml")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(useMetricUnits ? .white : .gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(useMetricUnits ? Color.blue.opacity(0.2) : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(useMetricUnits ? Color.blue : Color(white: 0.3), lineWidth: 1.5)
                        )
                }
                
                Button(action: { useMetricUnits = false }) {
                    Text("mi, lbs, oz")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(!useMetricUnits ? .white : .gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(!useMetricUnits ? Color.blue.opacity(0.2) : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(!useMetricUnits ? Color.blue : Color(white: 0.3), lineWidth: 1.5)
                        )
                }
            }
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Manage Visibility")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.gray)
                
                VStack(spacing: 0) {
                    ToggleRow(title: "Seconds Alive", isOn: $showSecondsAlive, isTop: true)
                    Divider().background(Color.white.opacity(0.1)).padding(.leading, 56)
                    ToggleRow(title: "Heartbeats", isOn: $showHeartbeats)
                    Divider().background(Color.white.opacity(0.1)).padding(.leading, 56)
                    ToggleRow(title: "Breaths Taken", isOn: $showBreathsTaken)
                    Divider().background(Color.white.opacity(0.1)).padding(.leading, 56)
                    ToggleRow(title: "Times Blinked", isOn: $showTimesBlinked)
                    Divider().background(Color.white.opacity(0.1)).padding(.leading, 56)
                    ToggleRow(title: "Hair Growth", isOn: $showHairGrowth)
                    Divider().background(Color.white.opacity(0.1)).padding(.leading, 56)
                    ToggleRow(title: "Space Traveler", isOn: $showSpaceTraveler, isBottom: true)
                }
                .background(Color(white: 0.15))
                .cornerRadius(16)
            }
        }
    }
    
    private var profilesSection: some View {
        VStack(spacing: 16) {
            // Main Profile
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color(white: 0.1))
                        .frame(width: 50, height: 50)
                    
                    if let profileImage = profileImage {
                        profileImage
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(userName)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        Image(systemName: "pencil")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                    }
                    
                    Text("Born \(formatDetailedDate(Date(timeIntervalSince1970: userDOBTimestamp)))")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
                    .font(.system(size: 16, weight: .medium))
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.blue.opacity(0.8), lineWidth: 1.5)
            )
            .cornerRadius(16)
            
            // Add Profile Button
            Button(action: { /* Add Profile logic */ }) {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.15))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "plus")
                            .foregroundColor(.blue)
                            .font(.system(size: 20, weight: .medium))
                    }
                    
                    Text("Add Profile")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color(white: 0.15))
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
                    .background(Color(white: 0.15))
                    .cornerRadius(16)
            }
        }
    }
    
    private func formatDetailedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
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
                .foregroundColor(isSelected ? .white : .gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isSelected ? Color.blue : Color(white: 0.2))
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
                .foregroundColor(.white)
            
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
