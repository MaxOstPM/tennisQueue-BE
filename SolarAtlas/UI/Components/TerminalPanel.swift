import SwiftUI

/// CRT-inspired terminal panel with neon border and monospaced typography.
struct TerminalPanel<Content: View>: View {
    private let borderColor: Color
    private let content: Content

    init(borderColor: Color = .terminalCyan, @ViewBuilder content: () -> Content) {
        self.borderColor = borderColor
        self.content = content()
    }

    var body: some View {
        content
            .padding(.spaceLG)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.cardBackground.opacity(0.95))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(borderColor, lineWidth: 2)
            )
            .shadow(color: borderColor.opacity(0.35), radius: 12, x: 0, y: 0)
            .font(.system(.body, design: .monospaced))
    }
}
