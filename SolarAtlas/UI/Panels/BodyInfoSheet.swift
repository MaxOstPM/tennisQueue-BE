import SwiftUI

/// Information overlay for a selected celestial body.
struct BodyInfoSheet: View {
    let celestial: CelestialBody
    @EnvironmentObject private var store: AppStore

    private static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    private var orbitDescription: String {
        if celestial.id == .sun {
            return NSLocalizedString("Central star of the Solar System.", comment: "Sun description")
        }

        let orbitValue = BodyInfoSheet.numberFormatter.string(from: NSNumber(value: Double(celestial.orbitAU)))
            ?? String(format: "%.2f", Double(celestial.orbitAU))
        let periodValue = BodyInfoSheet.numberFormatter.string(from: NSNumber(value: celestial.periodDays))
            ?? String(format: "%.0f", celestial.periodDays)

        return String(
            format: NSLocalizedString("Orbit radius: %@ AU\nOrbital period: %@ days", comment: "Body orbit details"),
            orbitValue,
            periodValue
        )
    }

    var body: some View {
        TerminalPanel(borderColor: celestial.color) {
            VStack(alignment: .leading, spacing: CGFloat.spaceMD) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: CGFloat.spaceXS) {
                        Text(celestial.displayName.uppercased())
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(celestial.color)
                            .glow(color: celestial.color)
                        Text(orbitDescription)
                            .font(.system(size: 12, weight: .regular, design: .monospaced))
                            .foregroundColor(.mutedText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                    Button(action: { store.dispatch(.solarSystem(.select(nil))) }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.mutedText)
                            .padding(CGFloat.spaceSM)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Text(NSLocalizedString("Dismiss", comment: "Dismiss sheet")))
                }

                Divider()
                    .background(Color.terminalCyan)
                    .opacity(0.4)

                Text(detailText(for: celestial))
                    .font(.system(size: 12, weight: .regular, design: .monospaced))
                    .foregroundColor(.foregroundCyan)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func detailText(for celestial: CelestialBody) -> String {
        switch celestial.id {
        case .sun:
            return NSLocalizedString("A G-type main-sequence star that provides the gravitational anchor and energy for the entire system.", comment: "Sun details")
        case .mercury:
            return NSLocalizedString("The smallest planet, with a fast 88-day orbit close to the sun.", comment: "Mercury details")
        case .venus:
            return NSLocalizedString("Venus has a dense atmosphere and rotates slowly in the opposite direction of most planets.", comment: "Venus details")
        case .earth:
            return NSLocalizedString("Our home world with abundant water and a single natural satellite, the Moon.", comment: "Earth details")
        case .mars:
            return NSLocalizedString("The red planet, known for its iron oxide soil and the tallest volcano in the solar system.", comment: "Mars details")
        case .jupiter:
            return NSLocalizedString("A gas giant with a massive magnetic field and dozens of moons, including Ganymede and Europa.", comment: "Jupiter details")
        case .saturn:
            return NSLocalizedString("Famous for its spectacular ring system made of ice and rock particles.", comment: "Saturn details")
        case .uranus:
            return NSLocalizedString("An ice giant that rotates on its side, likely due to an ancient collision.", comment: "Uranus details")
        case .neptune:
            return NSLocalizedString("The most distant known planet, with supersonic winds and a deep blue hue.", comment: "Neptune details")
        case .atlas:
            return NSLocalizedString("Comet ATLAS (C/2019 Y4) follows a highly elongated trajectory that brings it from the outer solar system toward the inner planets.", comment: "Atlas details")
        }
    }
}
