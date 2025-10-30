import SwiftUI

/// Full-screen, non-dismissible overlay that prompts the user to update the app.
struct UpdatePromptView: View {
    @Environment(\.openURL) private var openURL

    private let updateURL = URL(string: "https://apps.apple.com")

    var body: some View {
        Color.terminalAmberSurface
            .ignoresSafeArea()
            .overlay(
                VStack(spacing: .spaceXL) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(Font.ds.iconXL)
                        .foregroundColor(.spaceBlack)

                    VStack(spacing: .spaceSM) {
                        Text(NSLocalizedString("updatePrompt.title", comment: "Title explaining an update is required"))
                            .font(Font.ds.titleL)
                            .foregroundColor(.spaceBlack)

                        Text(NSLocalizedString("updatePrompt.subtitle", comment: "Body copy describing why the update is required"))
                            .font(Font.ds.body)
                            .foregroundColor(.spaceBlackSubdued)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, .spaceXL)
                    }

                    Button(action: openUpdateLink) {
                        Text(NSLocalizedString("updatePrompt.cta", comment: "Call-to-action button for updating the app"))
                            .font(Font.ds.labelEmphasis)
                            .padding(.horizontal, .space3XL)
                            .padding(.vertical, .spaceSM)
                            .background(
                                ZStack {
                                    Color.spaceBlack
                                    ScanlineOverlay()
                                }
                            )
                            .foregroundColor(.terminalAmber)
                            .overlay(
                                Rectangle()
                                    .stroke(Color.spaceBlack, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.space2XL)
            )
    }

    private func openUpdateLink() {
        guard let url = updateURL else { return }
        openURL(url)
    }
}
