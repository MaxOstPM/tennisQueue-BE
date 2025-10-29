import SwiftUI

/// Full-screen, non-dismissible overlay that prompts the user to update the app.
struct UpdatePromptView: View {
    @Environment(\.openURL) private var openURL

    private let updateURL = URL(string: "https://apps.apple.com")

    var body: some View {
        Color.terminalAmber.opacity(0.96)
            .ignoresSafeArea()
            .overlay(
                VStack(spacing: .spaceXL) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 58))
                        .foregroundColor(.spaceBlack)

                    VStack(spacing: .spaceSM) {
                        Text("Update Required")
                            .font(.system(size: 26, weight: .heavy, design: .monospaced))
                            .foregroundColor(.spaceBlack)

                        Text("A newer build of Solar Atlas is available. Update now to continue receiving live telemetry and system access.")
                            .font(.system(size: 14, weight: .regular, design: .monospaced))
                            .foregroundColor(.spaceBlack.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, .spaceXL)
                    }

                    Button(action: openUpdateLink) {
                        Text("Update Solar Atlas")
                            .font(.system(size: 15, weight: .semibold, design: .monospaced))
                            .padding(.horizontal, .space2XL)
                            .padding(.vertical, .spaceMD)
                            .background(Color.spaceBlack)
                            .foregroundColor(.terminalAmber)
                            .clipShape(Capsule())
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
