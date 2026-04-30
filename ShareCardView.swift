import SwiftUI
import UIKit

/// An Instagram Story-sized (1080x1920) SwiftUI View designed specifically for off-screen rendering
public struct ShareCardView: View {
    let milestoneTitle: String
    let subtitle: String
    let statValue: String
    
    public init(milestoneTitle: String, subtitle: String, statValue: String) {
        self.milestoneTitle = milestoneTitle
        self.subtitle = subtitle
        self.statValue = statValue
    }
    
    public var body: some View {
        ZStack {
            // Dark Grey background defined in Theme.swift
            Color.vitalzCard
                .ignoresSafeArea()
            
            VStack {
                // Top Branding Area
                HStack {
                    Text("V I T A L Z")
                        .font(.system(size: 48, weight: .bold, design: .serif))
                        .foregroundColor(.vitalzGold)
                        .kerning(16)
                }
                .padding(.top, 160)
                
                Spacer()
                
                // Highlighted Stat
                VStack(spacing: 50) {
                    Text(subtitle.uppercased())
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundColor(.gray)
                        .kerning(4)
                    
                    Text(statValue)
                        .font(.system(size: 200, weight: .bold, design: .serif))
                        .foregroundColor(.vitalzGold)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .shadow(color: Color.vitalzGold.opacity(0.3), radius: 30, x: 0, y: 15)
                        .padding(.horizontal, 40)
                    
                    Text(milestoneTitle)
                        .font(.system(size: 56, weight: .medium, design: .serif))
                        .foregroundColor(.vitalzText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 80)
                }
                
                Spacer()
                
                // Bottom Footer
                VStack(spacing: 16) {
                    Text("Every second deserves to be noticed.")
                        .font(.system(size: 36, weight: .light, design: .serif))
                        .foregroundColor(.gray)
                        .italic()
                }
                .padding(.bottom, 120)
            }
        }
        // Force the fixed resolution for IG Stories
        .frame(width: 1080, height: 1920)
    }
}

// MARK: - Sharing Helper

@MainActor
public struct ShareHelper {
    
    /// Renders the SwiftUI 1080x1920 view to a UIImage and presents a UIActivityViewController
    public static func shareMilestone(title: String, subtitle: String, statValue: String) {
        // Construct the view exactly as we want it rendered off-screen
        let viewToRender = ShareCardView(milestoneTitle: title, subtitle: subtitle, statValue: statValue)
        
        // Use iOS 16's ImageRenderer
        let renderer = ImageRenderer(content: viewToRender)
        // Scale 1.0 means 1 point = 1 pixel. Since our frame is 1080x1920 points, the output is 1080x1920 pixels.
        renderer.scale = 1.0
        
        if let uiImage = renderer.uiImage {
            presentShareSheet(items: [uiImage])
        } else {
            print("Vitalz Warning: Failed to render the ImageRenderer to UIImage.")
        }
    }
    
    /// Programmatically finds the top view controller and presents the native iOS share sheet
    private static func presentShareSheet(items: [Any]) {
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            return
        }
        
        var topVC = rootVC
        while let presentedVC = topVC.presentedViewController {
            topVC = presentedVC
        }
        
        // Setup popover for iPad reliability
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = topVC.view
            popover.sourceRect = CGRect(x: topVC.view.bounds.midX, y: topVC.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        topVC.present(activityVC, animated: true, completion: nil)
    }
}
