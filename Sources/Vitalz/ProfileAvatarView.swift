import SwiftUI
import UIKit

struct ProfileAvatarView: View {
    let imageData: Data?
    var size: CGFloat = 50

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.vitalzControl)

            if let imageData,
               let image = UIImage(data: imageData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "person.fill")
                    .font(.system(size: size * 0.38, weight: .medium))
                    .foregroundColor(.vitalzSecondaryText)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}
