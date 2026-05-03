import SwiftUI
import AVFoundation

// MARK: - Signature Scanner View

/// A minimalist camera-based QR scanner that decodes a friend's VitalzSignature
/// and presents an actionable preview before saving anything to the store.
public struct SignatureScannerView: View {
    @EnvironmentObject private var profileStore: ProfileStore
    @Environment(\.dismiss) private var dismiss

    @State private var scannedSignature: VitalzSignature?
    @State private var cameraPermissionDenied = false

    public init() {}

    public var body: some View {
        ZStack {
            // Camera layer
            CameraScannerRepresentable(
                onCodeScanned: handleScannedCode,
                onPermissionDenied: { cameraPermissionDenied = true }
            )
            .ignoresSafeArea()

            // Overlay chrome
            VStack {
                // Top bar
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white.opacity(0.85))
                            .symbolRenderingMode(.hierarchical)
                    }

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                Spacer()

                // Viewfinder guide
                RoundedRectangle(cornerRadius: 24)
                    .strokeBorder(Color.white.opacity(0.5), lineWidth: 2)
                    .frame(width: 260, height: 260)

                Spacer()

                // Bottom label
                VStack(spacing: 6) {
                    Text("SCAN A SIGNATURE")
                        .font(.system(size: 11, weight: .bold))
                        .kerning(3)
                        .foregroundColor(.white.opacity(0.6))

                    Text("Point at a friend's Vitalz QR code")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                }
                .padding(.bottom, 50)
            }

            // Permission denied state
            if cameraPermissionDenied {
                VStack(spacing: 16) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 36))
                        .foregroundColor(Color(white: 0.5))

                    Text("Camera Access Required")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)

                    Text("Enable camera access in Settings to scan QR codes.")
                        .font(.system(size: 14))
                        .foregroundColor(Color(white: 0.6))
                        .multilineTextAlignment(.center)

                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 12)
                    .background(Color(white: 0.25))
                    .cornerRadius(12)
                }
                .padding(40)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.ignoresSafeArea())
            }
        }
        .sheet(item: $scannedSignature) { sig in
            SignaturePreviewSheet(signature: sig) {
                addToOrbit(sig)
                scannedSignature = nil
                dismiss()
            }
            .environmentObject(profileStore)
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }

    private func handleScannedCode(_ code: String) {
        // Prevent re-triggering while a sheet is showing
        guard scannedSignature == nil else { return }

        // Try decoding from deep link first, then raw base64
        if let url = URL(string: code), let sig = VitalzSignature.decode(from: url) {
            scannedSignature = sig
        } else if let sig = VitalzSignature.decode(from: code) {
            scannedSignature = sig
        }
    }

    private func addToOrbit(_ signature: VitalzSignature) {
        var profile = profileStore.selectedProfile

        // Add as a tracked person
        let person = TrackedPerson(
            name: signature.name,
            metTimestamp: Date().timeIntervalSince1970,
            dateOfBirthTimestamp: signature.dateOfBirthTimestamp,
            relationship: "Friend"
        )
        profile.trackedPeople.append(person)

        // Import their shared hobbies as the user's own (disabled by default so they don't pollute Era Share)
        for sharedHobby in signature.hobbies {
            var hobby = sharedHobby.toHobby()
            hobby = Hobby(
                title: hobby.title,
                startTimestamp: hobby.startTimestamp,
                hoursPerWeek: hobby.hoursPerWeek,
                isEnabled: false,
                icon: hobby.icon
            )
            // Only add if not already tracking this hobby title
            if !profile.hobbies.contains(where: { $0.title.lowercased() == hobby.title.lowercased() }) {
                profile.hobbies.append(hobby)
            }
        }

        profileStore.saveProfile(profile)
    }
}

// MARK: - Signature Preview Sheet

/// The dark grey half-sheet showing the decoded friend data before committing.
private struct SignaturePreviewSheet: View {
    let signature: VitalzSignature
    let onAdd: () -> Void

    @Environment(\.dismiss) private var dismiss

    private var dateOfBirth: Date {
        Date(timeIntervalSince1970: signature.dateOfBirthTimestamp)
    }

    private var formattedDOB: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: dateOfBirth)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                // Avatar placeholder
                ZStack {
                    Circle()
                        .fill(Color(white: 0.25))
                        .frame(width: 72, height: 72)

                    Text(String(signature.name.prefix(1)))
                        .textCase(.uppercase)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                }

                VStack(spacing: 4) {
                    Text(signature.name)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)

                    Text("Born \(formattedDOB)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(white: 0.55))
                }
            }
            .padding(.top, 28)
            .padding(.bottom, 24)

            // Shared hobbies list
            if !signature.hobbies.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    Text("SHARING \(signature.hobbies.count) HOBB\(signature.hobbies.count == 1 ? "Y" : "IES")")
                        .font(.system(size: 10, weight: .bold))
                        .kerning(2)
                        .foregroundColor(Color(white: 0.45))
                        .padding(.horizontal, 24)
                        .padding(.bottom, 12)

                    VStack(spacing: 0) {
                        ForEach(signature.hobbies) { hobby in
                            HStack(spacing: 12) {
                                Image(systemName: hobby.icon)
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.7))
                                    .frame(width: 28, height: 28)
                                    .background(Color(white: 0.25))
                                    .clipShape(Circle())

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(hobby.title)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.white)

                                    Text("\(Int(hobby.hoursPerWeek))h / week")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color(white: 0.5))
                                }

                                Spacer()
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)

                            if hobby.id != signature.hobbies.last?.id {
                                Divider()
                                    .background(Color(white: 0.25))
                                    .padding(.leading, 64)
                            }
                        }
                    }
                }
            }

            Spacer()

            // Actions
            VStack(spacing: 12) {
                Button(action: onAdd) {
                    HStack(spacing: 10) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 15, weight: .semibold))
                        Text("Add to Orbit")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(Color(white: 0.12))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .cornerRadius(14)
                }

                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color(white: 0.5))
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(white: 0.12).ignoresSafeArea())
    }
}

// MARK: - Identifiable conformance for sheet binding

extension VitalzSignature: Identifiable {
    public var id: String { name + String(dateOfBirthTimestamp) }
}

// MARK: - AVFoundation Camera Scanner

private struct CameraScannerRepresentable: UIViewControllerRepresentable {
    let onCodeScanned: (String) -> Void
    let onPermissionDenied: () -> Void

    func makeUIViewController(context: Context) -> CameraScannerViewController {
        let vc = CameraScannerViewController()
        vc.onCodeScanned = onCodeScanned
        vc.onPermissionDenied = onPermissionDenied
        return vc
    }

    func updateUIViewController(_ uiViewController: CameraScannerViewController, context: Context) {}
}

private final class CameraScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var onCodeScanned: ((String) -> Void)?
    var onPermissionDenied: (() -> Void)?

    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var hasScanned = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        checkPermissionAndSetup()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession.startRunning()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }

    private func checkPermissionAndSetup() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.setupCamera()
                    } else {
                        self?.onPermissionDenied?()
                    }
                }
            }
        default:
            DispatchQueue.main.async { [weak self] in
                self?.onPermissionDenied?()
            }
        }
    }

    private func setupCamera() {
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else { return }

        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }

        let output = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
            output.setMetadataObjectsDelegate(self, queue: .main)
            output.metadataObjectTypes = [.qr]
        }

        let layer = AVCaptureVideoPreviewLayer(session: captureSession)
        layer.videoGravity = .resizeAspectFill
        layer.frame = view.bounds
        view.layer.addSublayer(layer)
        previewLayer = layer

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }

    // MARK: - AVCaptureMetadataOutputObjectsDelegate

    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard !hasScanned,
              let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              object.type == .qr,
              let value = object.stringValue
        else { return }

        hasScanned = true

        HapticEngine.playSuccess()

        onCodeScanned?(value)

        // Allow re-scanning after a brief delay (e.g., if sheet is dismissed)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.hasScanned = false
        }
    }
}
