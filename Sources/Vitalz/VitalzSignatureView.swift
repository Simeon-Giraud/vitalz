import SwiftUI
import CoreImage.CIFilterBuiltins

// MARK: - Vitalz Signature View

/// A minimalist white-on-dark privacy-first view that lets the user curate
/// exactly which hobbies to include in their shareable QR code / deep link.
public struct VitalzSignatureView: View {
    @EnvironmentObject private var profileStore: ProfileStore
    @Environment(\.dismiss) private var dismiss

    @State private var selectedHobbyIDs: Set<String> = []
    @State private var showShareSheet = false

    public init() {}

    // MARK: - Computed

    private var profile: VitalzProfile {
        profileStore.selectedProfile
    }

    private var signature: VitalzSignature {
        VitalzSignature(profile: profile, selectedHobbyIDs: selectedHobbyIDs)
    }

    private var encodedPayload: String {
        signature.encode() ?? ""
    }

    // MARK: - Body

    public var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // ── Header ──────────────────────────────────
                    VStack(spacing: 8) {
                        Text("YOUR SIGNATURE")
                            .font(.system(size: 12, weight: .bold))
                            .kerning(4)
                            .foregroundColor(Color(white: 0.45))

                        Text(profile.name)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color(white: 0.1))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 32)
                    .padding(.bottom, 24)

                    // ── Privacy Filter ──────────────────────────
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Image(systemName: "eye.slash")
                                .font(.system(size: 13))
                                .foregroundColor(Color(white: 0.45))
                            Text("CHOOSE WHAT TO SHARE")
                                .font(.system(size: 11, weight: .bold))
                                .kerning(2)
                                .foregroundColor(Color(white: 0.45))
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)

                        if profile.hobbies.isEmpty {
                            HStack {
                                Spacer()
                                VStack(spacing: 8) {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 24))
                                        .foregroundColor(Color(white: 0.7))
                                    Text("No hobbies yet")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(Color(white: 0.5))
                                    Text("Add hobbies in Settings to share them.")
                                        .font(.system(size: 13))
                                        .foregroundColor(Color(white: 0.65))
                                }
                                Spacer()
                            }
                            .padding(.vertical, 32)
                        } else {
                            VStack(spacing: 0) {
                                ForEach(profile.hobbies) { hobby in
                                    HobbyToggleRow(
                                        hobby: hobby,
                                        isSelected: selectedHobbyIDs.contains(hobby.id),
                                        toggle: {
                                            HapticEngine.playMechanicalClick()
                                            if selectedHobbyIDs.contains(hobby.id) {
                                                selectedHobbyIDs.remove(hobby.id)
                                            } else {
                                                selectedHobbyIDs.insert(hobby.id)
                                            }
                                        }
                                    )

                                    if hobby.id != profile.hobbies.last?.id {
                                        Divider()
                                            .background(Color(white: 0.9))
                                            .padding(.leading, 60)
                                    }
                                }
                            }
                            .background(Color(white: 0.97))
                            .cornerRadius(16)
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, 32)

                    // ── QR Code ─────────────────────────────────
                    if !selectedHobbyIDs.isEmpty {
                        VStack(spacing: 16) {
                            Text("SCAN TO CONNECT")
                                .font(.system(size: 11, weight: .bold))
                                .kerning(2)
                                .foregroundColor(Color(white: 0.45))

                            QRCodeView(payload: encodedPayload)
                                .frame(width: 220, height: 220)
                                .padding(20)
                                .background(Color.white)
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.06), radius: 20, y: 8)

                            Text("\(selectedHobbyIDs.count) hobb\(selectedHobbyIDs.count == 1 ? "y" : "ies") included")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color(white: 0.55))
                        }
                        .padding(.bottom, 32)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        .animation(.easeInOut(duration: 0.25), value: selectedHobbyIDs)

                        // ── Share Link Button ──────────────────
                        Button {
                            showShareSheet = true
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 15, weight: .semibold))
                                Text("Share Link")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(white: 0.12))
                            .cornerRadius(14)
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 40)
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "qrcode")
                                .font(.system(size: 40))
                                .foregroundColor(Color(white: 0.82))
                            Text("Toggle at least one hobby to generate your QR code.")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(white: 0.55))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, 40)
                        .padding(.horizontal, 40)
                    }
                }
            }
            .background(Color.white.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(Color(white: 0.75))
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let url = signature.deepLink() {
                    ShareSheet(items: [url])
                }
            }
            .onAppear {
                // Default: select all hobbies
                selectedHobbyIDs = Set(profile.hobbies.map(\.id))
            }
        }
    }
}

// MARK: - Hobby Toggle Row

private struct HobbyToggleRow: View {
    let hobby: Hobby
    let isSelected: Bool
    let toggle: () -> Void

    var body: some View {
        Button(action: toggle) {
            HStack(spacing: 14) {
                Image(systemName: hobby.icon)
                    .font(.system(size: 16))
                    .foregroundColor(isSelected ? Color(white: 0.1) : Color(white: 0.7))
                    .frame(width: 28, height: 28)
                    .background(isSelected ? Color(white: 0.9) : Color(white: 0.94))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(hobby.title.isEmpty ? "Untitled" : hobby.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(isSelected ? Color(white: 0.1) : Color(white: 0.6))

                    Text("\(Int(hobby.hoursPerWeek))h / week")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(white: 0.55))
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? Color(white: 0.1) : Color(white: 0.78))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - QR Code Generator (CoreImage)

private struct QRCodeView: View {
    let payload: String

    var body: some View {
        if let image = generateQRCode(from: payload) {
            Image(uiImage: image)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
        } else {
            Image(systemName: "qrcode")
                .font(.system(size: 60))
                .foregroundColor(Color(white: 0.8))
        }
    }

    private func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"

        guard let outputImage = filter.outputImage else { return nil }

        // Scale up for crisp rendering
        let scale = 10.0
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        let scaledImage = outputImage.transformed(by: transform)

        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}

// MARK: - UIKit Share Sheet Bridge

private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    VitalzSignatureView()
        .environmentObject(ProfileStore())
}
