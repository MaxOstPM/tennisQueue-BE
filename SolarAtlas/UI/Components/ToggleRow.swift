import SwiftUI

/// Standardized toggle row with terminal styling.
struct ToggleRow: View {
    var title: String
    @Binding var isOn: Bool
    var accent: Color = .terminalGreen

    init(title: String, isOn: Binding<Bool>, accent: Color = .terminalGreen) {
        self.title = title
        self._isOn = isOn
        self.accent = accent
    }

    var body: some View {
        Toggle(isOn: $isOn) {
            Text(title)
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundColor(.foregroundCyan)
        }
        .toggleStyle(SwitchToggleStyle(tint: accent))
    }
}
