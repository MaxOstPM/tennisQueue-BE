import SwiftUI

/// Main solar system screen showing the canvas and simulation controls.
struct SolarSystemView: View {
    @EnvironmentObject private var solarStore: SolarSystemStore

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    private let orbitFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    private let periodFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    var body: some View {
        ZStack {
            Color.spaceBlack.ignoresSafeArea()

            SolarCanvas()
                .padding(.bottom, 220)
                .padding(.horizontal, .spaceLG)

            VStack(spacing: .spaceXL) {
                header
                Spacer()
                controlPanel
            }
            .padding(.space2XL)
        }
        .overlay(ScanlineOverlay())
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: .spaceSM) {
            Text("Solar Atlas")
                .font(.system(size: 30, weight: .heavy, design: .monospaced))
                .foregroundColor(.foregroundCyan)
                .glow()

            Text(dateFormatter.string(from: currentDate))
                .font(.system(size: 15, weight: .medium, design: .monospaced))
                .foregroundColor(.mutedText)

            if let selectedBody = selectedBody {
                VStack(alignment: .leading, spacing: .spaceXS) {
                    Text("Tracking: \(selectedBody.displayName)")
                        .font(.system(size: 14, weight: .semibold, design: .monospaced))
                        .foregroundColor(.terminalAmber)

                    if let orbitText = orbitFormatter.string(from: NSNumber(value: Double(selectedBody.orbitAU))) {
                        Text("Orbit radius: \(orbitText) AU")
                            .font(.system(size: 12, weight: .regular, design: .monospaced))
                            .foregroundColor(.mutedText)
                    }

                    if let periodText = periodFormatter.string(from: NSNumber(value: selectedBody.periodDays)) {
                        Text("Orbital period: \(periodText) days")
                            .font(.system(size: 12, weight: .regular, design: .monospaced))
                            .foregroundColor(.mutedText)
                    }
                }
                .transition(.opacity)
            } else {
                Text("Tap a body to inspect its orbit and telemetry.")
                    .font(.system(size: 12, weight: .regular, design: .monospaced))
                    .foregroundColor(.mutedText)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var controlPanel: some View {
        VStack(alignment: .leading, spacing: .spaceXL) {
            VStack(alignment: .leading, spacing: .spaceSM) {
                Text("Simulation Time")
                    .font(.system(size: 16, weight: .semibold, design: .monospaced))
                    .foregroundColor(.foregroundCyan)

                Slider(value: timeBinding, in: 0...1)
                    .tint(.terminalCyan)

                Text("Current date: \(dateFormatter.string(from: currentDate))")
                    .font(.system(size: 12, weight: .regular, design: .monospaced))
                    .foregroundColor(.mutedText)
            }

            VStack(alignment: .leading, spacing: .spaceMD) {
                toggleRow(
                    title: "Show ATLAS trajectory",
                    isOn: Binding(
                        get: { solarStore.state.showAtlasPath },
                        set: { solarStore.dispatch(.toggleAtlas($0)) }
                    )
                )

                toggleRow(
                    title: "Show planetary orbits",
                    isOn: Binding(
                        get: { solarStore.state.showOrbits },
                        set: { solarStore.dispatch(.toggleOrbits($0)) }
                    )
                )

                toggleRow(
                    title: "Show labels",
                    isOn: Binding(
                        get: { solarStore.state.showLabels },
                        set: { solarStore.dispatch(.toggleLabels($0)) }
                    )
                )
            }
        }
        .padding(.spaceXL)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.cardBackground.opacity(0.92))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.terminalCyan.opacity(0.45), lineWidth: 1)
        )
        .glow(color: .terminalCyan.opacity(0.5))
    }

    private func toggleRow(title: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundColor(.foregroundCyan)
        }
        .toggleStyle(SwitchToggleStyle(tint: .terminalCyan))
    }

    private var selectedBody: CelestialBody? {
        guard let bodyID = solarStore.state.selected else { return nil }
        return solarSystemBodies.first { $0.id == bodyID }
    }

    private var currentDate: Date {
        let state = solarStore.state
        let range = state.dateRange
        let total = range.upperBound.timeIntervalSince(range.lowerBound)
        guard total > 0 else { return range.lowerBound }
        return range.lowerBound.addingTimeInterval(total * state.time)
    }

    private var timeBinding: Binding<Double> {
        Binding(
            get: { solarStore.state.time },
            set: { solarStore.dispatch(.setTime($0)) }
        )
    }
}
