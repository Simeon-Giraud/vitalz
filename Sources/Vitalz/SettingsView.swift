import SwiftUI
import PhotosUI

public struct SettingsView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @AppStorage("userDOBTimestamp") private var userDOBTimestamp: Double = 0
    @AppStorage("appTheme") private var appTheme: Int = 0
    @AppStorage("userName") private var userName: String = "John Doe"
    
    @State private var showResetConfirmation = false
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var profileImage: Image? = nil
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.vitalzBackground.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 40) {
                    // Header
                    HStack {
                        Text("S E T T I N G S")
                            .font(.system(size: 14, weight: .bold, design: .default))
                            .foregroundColor(.vitalzBlue)
                            .kerning(8)
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    
                    // Profile/Account Data Block
                    VStack(alignment: .leading, spacing: 16) {
                        Text("PROFILE")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.gray)
                            .kerning(1.5)
                            .padding(.horizontal, 24)
                        
                        VStack(spacing: 24) {
                            HStack(spacing: 20) {
                                PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                                    ZStack {
                                        if let profileImage = profileImage {
                                            profileImage
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 80, height: 80)
                                                .clipShape(Circle())
                                        } else {
                                            Circle()
                                                .fill(Color.vitalzBackground)
                                                .frame(width: 80, height: 80)
                                            Image(systemName: "person.crop.circle.fill")
                                                .resizable()
                                                .foregroundColor(.vitalzBlue)
                                                .frame(width: 80, height: 80)
                                        }
                                        
                                        Image(systemName: "camera.circle.fill")
                                            .foregroundColor(.white)
                                            .background(Color.vitalzBlue)
                                            .clipShape(Circle())
                                            .offset(x: 28, y: 28)
                                    }
                                }
                                .onChange(of: selectedItem) { newItem in
                                    Task {
                                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                                           let uiImage = UIImage(data: data) {
                                            profileImage = Image(uiImage: uiImage)
                                        }
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    TextField("Your Name", text: $userName)
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(.vitalzText)
                                    
                                    Text("Health Profile")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                            }
                            
                            Divider()
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Date of Birth")
                                        .font(.system(size: 16, weight: .medium, design: .default))
                                        .foregroundColor(.vitalzText)
                                    
                                    Text(formatDetailedDate(Date(timeIntervalSince1970: userDOBTimestamp)))
                                        .font(.system(size: 15, weight: .regular))
                                        .foregroundColor(.vitalzBlue)
                                }
                                Spacer()
                            }
                        }
                        .padding(24)
                        .background(Color.vitalzCard)
                        .cornerRadius(24)
                        .padding(.horizontal, 24)
                    }
                    
                    // Actions
                    VStack(alignment: .leading, spacing: 16) {
                        Text("PREFERENCES")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.gray)
                            .kerning(1.5)
                            .padding(.horizontal, 24)
                        
                        // Theme Picker
                        VStack(spacing: 0) {
                            Picker("App Theme", selection: $appTheme) {
                                Text("System").tag(0)
                                Text("Light").tag(1)
                                Text("Dark").tag(2)
                            }
                            .pickerStyle(.segmented)
                            .padding(24)
                        }
                        .background(Color.vitalzCard)
                        .cornerRadius(24)
                        .padding(.horizontal, 24)
                        
                        Button(action: {
                            showResetConfirmation = true
                        }) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                    .foregroundColor(.red.opacity(0.8))
                                Text("Reset Identity")
                                    .font(.system(size: 16, weight: .medium, design: .default))
                                    .foregroundColor(.vitalzText)
                                Spacer()
                            }
                            .padding(24)
                            .background(Color.vitalzCard)
                            .cornerRadius(24)
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    // App Footer
                    VStack(spacing: 8) {
                        Text("V I T A L Z")
                            .font(.system(size: 12, weight: .medium, design: .default))
                            .foregroundColor(.vitalzBlue.opacity(0.5))
                            .kerning(4)
                        Text("Version 1.0.0")
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 60)
                }
            }
        }
        .confirmationDialog(
            "Reset Identity",
            isPresented: $showResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("Reset Identity", role: .destructive) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    hasCompletedOnboarding = false
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to reset your Date of Birth? This will take you back to the onboarding screen.")
        }
    }
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    private func formatDetailedDate(_ date: Date) -> String {
        return Self.dateFormatter.string(from: date)
    }
}

#Preview {
    SettingsView()
}
