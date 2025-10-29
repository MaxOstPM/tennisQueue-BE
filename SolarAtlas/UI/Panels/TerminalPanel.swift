import SwiftUI

/// A container view that applies the CRT terminal panel styling (glowing border, translucent background).
///
/// The panel provides consistent spacing, background, border, glow, and typography so any nested
/// content automatically inherits the retro terminal look.
struct TerminalPanel<Content: View>: View {
    /// Border color for the panel's neon stroke/glow.
    let borderColor: Color

    /// Content rendered inside the panel.
    let content: Content

    init(borderColor: Color = .terminalCyan, @ViewBuilder content: () -> Content) {
        self.borderColor = borderColor
        self.content = content()
    }

    var body: some View {
        content
            .padding(CGFloat.spaceMD)
            .background(Color.cardBackground.opacity(0.85))
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .stroke(borderColor, lineWidth: 2)
            )
            .modifier(GlowModifier(color: borderColor))
            .font(.system(size: 14, weight: .regular, design: .monospaced))
            .foregroundColor(.foregroundCyan)
    }
}

// Example usage:
// TerminalPanel {
//     VStack(alignment: .leading, spacing: CGFloat.spaceSM) {
//         Text("INCOMING TRANSMISSION")
//             .font(.system(size: 16, weight: .semibold, design: .monospaced))
//         Text("Solar flare activity detected. Recommend shelter protocols.")
//     }
// }
//
// TerminalPanel(borderColor: .terminalAmber) {
//     Text("Update required")
// }
