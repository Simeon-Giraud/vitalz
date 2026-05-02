import SwiftUI
import UIKit
import Photos

// MARK: - Exported Card View (1080×1920, Pure White Minimalist)

/// A premium 9:16 card rendered off-screen at 1080×1920 pixels.
/// Pure white background, dark typography, heavy negative space, editorial print aesthetic.
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
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 360)

                // Subtitle label
                Text(subtitle.uppercased())
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(Color(hex: "#999999"))
                    .kerning(6)

                Spacer()
                    .frame(height: 80)

                // Hero stat value
                Text(statValue)
                    .font(.system(size: 180, weight: .bold, design: .default))
                    .foregroundColor(Color(hex: "#1A1A1A"))
                    .minimumScaleFactor(0.4)
                    .lineLimit(1)
                    .padding(.horizontal, 80)

                Spacer()
                    .frame(height: 60)

                // Milestone title
                Text(milestoneTitle)
                    .font(.system(size: 48, weight: .regular, design: .serif))
                    .foregroundColor(Color(hex: "#1A1A1A"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
                    .padding(.horizontal, 120)

                Spacer()

                // Watermark
                Text("made with Vitalz")
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(Color(hex: "#CCCCCC"))
                    .kerning(2)
                    .padding(.bottom, 80)
            }
        }
        .frame(width: 1080, height: 1920)
    }
}

// MARK: - Image Renderer

@MainActor
public enum CardRenderer {

    /// Renders the share card to a high-resolution 1080×1920 UIImage.
    public static func renderImage(
        title: String,
        subtitle: String,
        statValue: String
    ) -> UIImage? {
        let card = ShareCardView(
            milestoneTitle: title,
            subtitle: subtitle,
            statValue: statValue
        )
        let renderer = ImageRenderer(content: card)
        // 1 point = 1 pixel → 1080×1920 output
        renderer.scale = 1.0
        return renderer.uiImage
    }
}

// MARK: - Share Action Sheet

/// A SwiftUI sheet that presents three explicit sharing options:
/// Save to Photos, Share to Instagram Stories, and the native share sheet.
public struct ShareActionSheet: View {
    let milestoneTitle: String
    let subtitle: String
    let statValue: String

    @Environment(\.dismiss) private var dismiss
    @State private var feedbackMessage: String?
    @State private var showFeedback = false

    public init(milestoneTitle: String, subtitle: String, statValue: String) {
        self.milestoneTitle = milestoneTitle
        self.subtitle = subtitle
        self.statValue = statValue
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Drag handle
            Capsule()
                .fill(Color.vitalzSecondaryText.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 12)

            // Preview thumbnail
            cardPreview
                .padding(.top, 24)
                .padding(.bottom, 28)

            // Action buttons
            VStack(spacing: 12) {
                shareButton(
                    icon: "photo.on.rectangle.angled",
                    label: "Save to Photos",
                    action: saveToPhotos
                )

                shareButton(
                    icon: "camera.fill",
                    label: "Share to Instagram Stories",
                    action: shareToInstagram
                )

                shareButton(
                    icon: "square.and.arrow.up",
                    label: "Share...",
                    action: openNativeShareSheet
                )
            }
            .padding(.horizontal, 24)

            // Feedback toast
            if showFeedback, let message = feedbackMessage {
                Text(message)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.vitalzSecondaryText)
                    .padding(.top, 16)
                    .transition(.opacity)
            }

            Spacer()
        }
        .background(Color.vitalzBackground.ignoresSafeArea())
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
    }

    // MARK: - Subviews

    private var cardPreview: some View {
        ShareCardView(
            milestoneTitle: milestoneTitle,
            subtitle: subtitle,
            statValue: statValue
        )
        .frame(width: 1080, height: 1920)
        .scaleEffect(0.14)
        .frame(width: 1080 * 0.14, height: 1920 * 0.14)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
    }

    private func shareButton(
        icon: String,
        label: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .frame(width: 24)
                Text(label)
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.vitalzSecondaryText)
            }
            .foregroundColor(.vitalzText)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.vitalzCard)
            )
        }
    }

    // MARK: - Actions

    private func saveToPhotos() {
        guard let image = CardRenderer.renderImage(
            title: milestoneTitle,
            subtitle: subtitle,
            statValue: statValue
        ) else {
            showToast("Failed to render image")
            return
        }

        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            DispatchQueue.main.async {
                guard status == .authorized || status == .limited else {
                    showToast("Photo library access denied")
                    return
                }
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                showToast("Saved to Photos ✓")
            }
        }
    }

    private func shareToInstagram() {
        guard let image = CardRenderer.renderImage(
            title: milestoneTitle,
            subtitle: subtitle,
            statValue: statValue
        ) else {
            showToast("Failed to render image")
            return
        }

        guard let pngData = image.pngData() else {
            showToast("Failed to encode image")
            return
        }

        // Write image data to the pasteboard for Instagram
        let pasteboardItems: [[String: Any]] = [
            ["com.instagram.sharedSticker.backgroundImage": pngData]
        ]
        let pasteboardOptions: [UIPasteboard.OptionsKey: Any] = [
            .expirationDate: Date().addingTimeInterval(60 * 5)
        ]
        UIPasteboard.general.setItems(pasteboardItems, options: pasteboardOptions)

        guard let instagramURL = URL(string: "instagram-stories://share?source_application=com.simeon.vitalz") else {
            showToast("Could not create Instagram URL")
            return
        }

        if UIApplication.shared.canOpenURL(instagramURL) {
            UIApplication.shared.open(instagramURL)
            dismiss()
        } else {
            showToast("Instagram is not installed")
        }
    }

    private func openNativeShareSheet() {
        guard let image = CardRenderer.renderImage(
            title: milestoneTitle,
            subtitle: subtitle,
            statValue: statValue
        ) else {
            showToast("Failed to render image")
            return
        }

        let activityVC = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )

        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let rootVC = windowScene.windows
            .first(where: { $0.isKeyWindow })?.rootViewController
        else { return }

        var topVC = rootVC
        while let presented = topVC.presentedViewController {
            topVC = presented
        }

        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = topVC.view
            popover.sourceRect = CGRect(
                x: topVC.view.bounds.midX,
                y: topVC.view.bounds.midY,
                width: 0, height: 0
            )
            popover.permittedArrowDirections = []
        }

        topVC.present(activityVC, animated: true)
    }

    private func showToast(_ message: String) {
        feedbackMessage = message
        withAnimation(.easeInOut(duration: 0.25)) {
            showFeedback = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeInOut(duration: 0.25)) {
                showFeedback = false
            }
        }
    }
}
