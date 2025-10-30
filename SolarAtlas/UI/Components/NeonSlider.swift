import SwiftUI

/// Slider styled to match the retro neon interface.
struct NeonSlider: View {
    @Binding var value: Double
    var range: ClosedRange<Double>
    var title: String
    var subtitle: String?
    var onEditingChanged: (Bool) -> Void
    var onValueChanged: (Double) -> Void

    init(value: Binding<Double>,
         range: ClosedRange<Double> = 0...1,
         title: String,
         subtitle: String? = nil,
         onEditingChanged: @escaping (Bool) -> Void = { _ in },
         onValueChanged: @escaping (Double) -> Void = { _ in }) {
        self._value = value
        self.range = range
        self.title = title
        self.subtitle = subtitle
        self.onEditingChanged = onEditingChanged
        self.onValueChanged = onValueChanged
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

            Slider(value: $value, in: range, onEditingChanged: onEditingChanged)
                .onChange(of: value, perform: onValueChanged)
                .accentColor(.terminalCyan)
                .shadow(color: .terminalCyan.opacity(0.6), radius: 4)
        }
    }
}
