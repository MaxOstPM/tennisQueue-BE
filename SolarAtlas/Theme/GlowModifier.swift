import SwiftUI

/// ViewModifier for neon glow effect (applied to text/panels)
struct GlowModifier: ViewModifier {
    var color: Color = .terminalCyan

    func body(content: Content) -> some View {
        content
            // Layered shadows to produce a diffuse glow
            .shadow(color: color.opacity(0.7), radius: 10, x: 0, y: 0)
            .shadow(color: color.opacity(0.5), radius: 20, x: 0, y: 0)
            .shadow(color: color.opacity(0.3), radius: 30, x: 0, y: 0)
    }
}

extension View {
    /// Convenience method to apply neon glow
    func glow(color: Color = .terminalCyan) -> some View {
        modifier(GlowModifier(color: color))
    }
}
