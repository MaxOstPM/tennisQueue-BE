import SwiftUI

/// A styled slider for controlling time, featuring the neon amber accent used across the timeline UI.
struct NeonSlider: View {
    /// Binding to the normalized timeline value (0.0 - 1.0 by default).
    @Binding var value: Double

    /// Range for the slider (defaults to 0...1 so the control can be reused for other ranges if necessary).
    var range: ClosedRange<Double> = 0.0...1.0

    var body: some View {
        Slider(value: $value, in: range)
            .padding(.horizontal, .spaceXL)
            .padding(.vertical, .spaceSM)
            .applyTint()
            .glow(color: .terminalAmber)
    }
}

private extension View {
    /// Applies the appropriate accent/tint color modifier depending on the available iOS version.
    @ViewBuilder
    func applyTint() -> some View {
        if #available(iOS 15.0, *) {
            self.tint(.terminalAmber)
        } else {
            self.accentColor(.terminalAmber)
        }
    }
}

// Usage (in parent view):
// NeonSlider(value: Binding(
//     get: { store.state.time },
//     set: { newValue in store.dispatch(.setTime(newValue)) }
// ))
// This binding ensures slider movements dispatch actions to update the global state.
