import SwiftUI

/// A labeled toggle switch with neon styling (monospaced label and glow)
struct ToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    var accent: Color = .terminalGreen  // default accent color for toggle (can be overridden)
    
    var body: some View {
        HStack {
            Toggle(isOn: $isOn) {
                Text(title)
                    .font(.system(size: 14, weight: .regular, design: .monospaced))
                    .foregroundColor(Color.foregroundCyan)
            }
            .toggleStyle(SwitchToggleStyle(tint: accent))
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .glow(color: accent)  // Glow effect around the toggle and label
    }
}

// The `accent` parameter allows using terminalGreen for general toggles, or other colors if needed.
// Example usage:
// ToggleRow(title: NSLocalizedString("Show Orbits", comment: ""), 
//           isOn: Binding(get: { store.state.showOrbits }, set: { store.dispatch(.toggleOrbits($0)) }),
//           accent: .terminalGreen)
