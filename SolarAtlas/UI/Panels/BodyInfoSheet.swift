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
        if celestial.bodyID == .sun {
            return NSLocalizedString("bodyInfo.sun.summary", comment: "Short summary describing the sun in the body info sheet")
        }

        let orbitValue = BodyInfoSheet.numberFormatter.string(from: NSNumber(value: celestial.orbitAU))
            ?? String(format: "%.2f", celestial.orbitAU)
        let periodValue = BodyInfoSheet.numberFormatter.string(from: NSNumber(value: celestial.periodDays))
            ?? String(format: "%.0f", celestial.periodDays)

        return String(
            format: NSLocalizedString("bodyInfo.orbitDetails", comment: "Format describing orbital radius and period"),
            orbitValue,
            periodValue
        )
    }

    var body: some View {
        TerminalPanel(borderColor: celestial.color) {
            VStack(alignment: .leading, spacing: .spaceMD) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: .spaceXS) {
                        Text(celestial.displayName.uppercased())
                            .font(Font.ds.titleM)
                            .foregroundColor(celestial.color)
                            .glow(color: celestial.color)
                        Text(orbitDescription)
                            .font(Font.ds.caption)
                            .foregroundColor(.mutedText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                    Button(action: { store.dispatch(.solarSystem(.select(nil))) }) {
                        Image(systemName: "xmark")
                            .font(Font.ds.iconSmall)
                            .foregroundColor(.mutedText)
                            .padding(.spaceSM)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Text(NSLocalizedString("bodyInfo.dismiss", comment: "Accessibility label for dismissing the body info sheet")))
                }

                Divider()
                    .background(Color.terminalCyanDim)

                Text(detailText(for: celestial))
                    .font(Font.ds.caption)
                    .foregroundColor(.foregroundCyan)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func detailText(for celestial: CelestialBody) -> String {
        switch celestial.bodyID {
        case .sun:
            return NSLocalizedString("bodyInfo.sun.detail", comment: "Detailed description of the sun")
        case .mercury:
            return NSLocalizedString("bodyInfo.mercury.detail", comment: "Detailed description of Mercury")
        case .venus:
            return NSLocalizedString("bodyInfo.venus.detail", comment: "Detailed description of Venus")
        case .earth:
            return NSLocalizedString("bodyInfo.earth.detail", comment: "Detailed description of Earth")
        case .mars:
            return NSLocalizedString("bodyInfo.mars.detail", comment: "Detailed description of Mars")
        case .jupiter:
            return NSLocalizedString("bodyInfo.jupiter.detail", comment: "Detailed description of Jupiter")
        case .saturn:
            return NSLocalizedString("bodyInfo.saturn.detail", comment: "Detailed description of Saturn")
        case .uranus:
            return NSLocalizedString("bodyInfo.uranus.detail", comment: "Detailed description of Uranus")
        case .neptune:
            return NSLocalizedString("bodyInfo.neptune.detail", comment: "Detailed description of Neptune")
        case .atlas:
            return NSLocalizedString("bodyInfo.atlas.detail", comment: "Detailed description of comet ATLAS")
        case .none:
            return celestial.displayName
        }
    }
}
