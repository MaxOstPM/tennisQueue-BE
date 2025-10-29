import SwiftUI

/// Container that mimics a retro terminal panel with glowing border and scanline overlay.
struct TerminalPanel<Content: View>: View {
    var borderColor: Color
    var backgroundColor: Color
    private let content: Content

    init(borderColor: Color = .terminalCyan,
         backgroundColor: Color = .cardBackground,
         @ViewBuilder content: () -> Content) {
        self.borderColor = borderColor
        self.backgroundColor = backgroundColor
        self.content = content()
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(backgroundColor.opacity(0.92))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(borderColor.opacity(0.8), lineWidth: 2)
                        .glow(color: borderColor)
                )
                .overlay(
                    ScanlineOverlay()
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                )

            content
                .padding(CGFloat.spaceLG)
        }
    }
}
