import SwiftUI

/// Slider styled to match the retro neon interface.
struct NeonSlider: View {
    @Binding var value: Double
    var range: ClosedRange<Double>
    var title: String
    var subtitle: String?

    init(value: Binding<Double>,
         range: ClosedRange<Double> = 0...1,
         title: String,
         subtitle: String? = nil) {
        self._value = value
        self.range = range
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        VStack(alignment: .leading, spacing: CGFloat.spaceSM) {
            VStack(alignment: .leading, spacing: CGFloat.spaceXS) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundColor(.foregroundCyan)
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 12, weight: .regular, design: .monospaced))
                        .foregroundColor(.mutedText)
                }
            }

            Slider(value: $value, in: range)
                .accentColor(.terminalCyan)
                .shadow(color: .terminalCyan.opacity(0.6), radius: 4)
        }
    }
}
