import SwiftUI

struct VitalzGlassButton<Content: View>: View {
    enum Shape {
        case capsule
        case circle
        case rounded(CGFloat)
    }

    let shape: Shape
    let isProminent: Bool
    let action: () -> Void
    @ViewBuilder let content: Content

    var body: some View {
        if #available(iOS 26.0, *) {
            if isProminent {
                Button(action: action) {
                    content
                }
                .buttonStyle(.glassProminent)
            } else {
                Button(action: action) {
                    content
                }
                .buttonStyle(.glass)
            }
        } else {
            Button(action: action) {
                content
                    .background(fallbackBackground)
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private var fallbackBackground: some View {
        switch shape {
        case .capsule:
            Capsule()
                .fill(Color.vitalzControl)
                .overlay(Capsule().stroke(Color.vitalzDivider, lineWidth: 1))
        case .circle:
            Circle()
                .fill(Color.vitalzControl)
                .overlay(Circle().stroke(Color.vitalzDivider, lineWidth: 1))
        case .rounded(let radius):
            RoundedRectangle(cornerRadius: radius)
                .fill(Color.vitalzControl)
                .overlay(RoundedRectangle(cornerRadius: radius).stroke(Color.vitalzDivider, lineWidth: 1))
        }
    }
}
