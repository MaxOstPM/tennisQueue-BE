import SwiftUI

/// Info panel displaying details of a selected celestial body (appears on tap)
struct BodyInfoSheet: View {
    let celestialBody: CelestialBody    // the selected celestial body to show info for
    @EnvironmentObject var store: AppStore

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(celestialBody.displayName)
                    .font(.title2)
                    .foregroundColor(.terminalCyan)
                    .padding(.bottom, CGFloat.spaceXS)
                Text(NSLocalizedString("Celestial Body", comment: "body info header subtitle"))
                    .font(.footnote)
                    .foregroundColor(.mutedText)
            }
            Spacer()
            Button(action: {
                store.dispatch(.select(nil))
            }) {
                Text("✕")
                    .font(.title2)
                    .foregroundColor(.terminalCyan)
                    .padding(.horizontal, 8)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text(NSLocalizedString("Close", comment: "Close info sheet")))
        }
    }

    private var facts: some View {
        VStack(alignment: .leading, spacing: CGFloat.spaceXS) {
            Text(String(format: NSLocalizedString("Orbit Radius: %.2f AU", comment: "orbit radius label"), celestialBody.orbitAU))
            Text(String(format: NSLocalizedString("Orbital Period: %.0f days", comment: "orbital period label"), celestialBody.periodDays))
        }
        .foregroundColor(.foregroundCyan)
    }

    var body: some View {
        TerminalPanel(borderColor: .terminalCyan) {
            VStack(alignment: .leading, spacing: CGFloat.spaceMD) {
                header
                Divider()
                    .background(Color.terminalCyan.opacity(0.3))
                facts
            }
        }
        .frame(maxWidth: 360)
        .padding(.spaceMD)
    }
}

// The BodyInfoSheet is presented when a body is selected. It appears as a modal TerminalPanel overlay.
// The close button (X) allows the user to dismiss the sheet.
