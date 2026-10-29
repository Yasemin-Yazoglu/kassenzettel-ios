import SwiftUI

struct AvatarView: View {
    let url: URL?
    let fallbackText: String

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image.resizable().scaledToFill()
            default:
                initials
            }
        }
        .frame(width: 64, height: 64)
        .clipShape(Circle())
        .accessibilityHidden(true)
    }

    private var initials: some View {
        ZStack {
            Circle().fill(.tint.opacity(0.2))
            Text(String(fallbackText.prefix(1)).uppercased())
                .font(.title2)
                .bold()
        }
    }
}
