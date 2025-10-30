import SwiftUI

/// Main solar system screen showing the canvas and simulation controls.
struct SolarSystemView: View {
    @EnvironmentObject private var store: AppStore
    @State private var lastTimelineLogDate: Date?

    private let analytics = AnalyticsTracker.shared
    private let timelineLogThrottle: TimeInterval = 2.0

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
                .font(Font.ds.titleL)
                .foregroundColor(.foregroundCyan)
                .glow()

            Text(dateFormatter.string(from: currentDate))
                .font(Font.ds.label)
                .foregroundColor(.mutedText)

            if let selectedBody = selectedBody {
                VStack(alignment: .leading, spacing: .spaceXS) {
                    Text("Tracking: \(selectedBody.displayName)")
                        .font(Font.ds.labelEmphasis)
                        .foregroundColor(.terminalAmber)

                    if let orbitText = orbitFormatter.string(from: NSNumber(value: Double(selectedBody.orbitAU))) {
                        Text("Orbit radius: \(orbitText) AU")
                            .font(Font.ds.caption)
                            .foregroundColor(.mutedText)
                    }

                    if let periodText = periodFormatter.string(from: NSNumber(value: selectedBody.periodDays)) {
                        Text("Orbital period: \(periodText) days")
                            .font(Font.ds.caption)
                            .foregroundColor(.mutedText)
                    }
                }
                .transition(.opacity)
            } else {
                Text("Tap a body to inspect its orbit and telemetry.")
                    .font(Font.ds.caption)
                    .foregroundColor(.mutedText)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var controlPanel: some View {
        TerminalPanel(borderColor: .terminalCyan) {
            VStack(alignment: .leading, spacing: .spaceXL) {
                VStack(alignment: .leading, spacing: .spaceSM) {
                    Text("Simulation Time")
                        .font(Font.ds.titleS)
                        .foregroundColor(.foregroundCyan)

                    Slider(value: timeBinding, in: 0...1, onEditingChanged: handleTimelineEditingChanged)
                        .tint(.terminalCyan)

                    Text("Current date: \(dateFormatter.string(from: currentDate))")
                        .font(Font.ds.caption)
                        .foregroundColor(.mutedText)
                }

                VStack(alignment: .leading, spacing: .spaceMD) {
                    toggleRow(
                        title: "Show ATLAS trajectory",
                        isOn: Binding(
                            get: { solarSystem.showAtlasPath },
                            set: { store.dispatch(.solarSystem(.toggleAtlas($0))) }
                        )
                    )

                    toggleRow(
                        title: "Show planetary orbits",
                        isOn: Binding(
                            get: { solarSystem.showOrbits },
                            set: { store.dispatch(.solarSystem(.toggleOrbits($0))) }
                        )
                    )

                    toggleRow(
                        title: "Show labels",
                        isOn: Binding(
                            get: { solarSystem.showLabels },
                            set: { store.dispatch(.solarSystem(.toggleLabels($0))) }
                        )
                    )
                }
            }
        }
    }

    private func toggleRow(title: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            Text(title)
                .font(Font.ds.label)
                .foregroundColor(.foregroundCyan)
        }
        .toggleStyle(SwitchToggleStyle(tint: .terminalCyan))
    }

    private var selectedBody: CelestialBody? {
        guard let bodyID = solarSystem.selected else { return nil }
        return solarSystemBodies.first { $0.id == bodyID }
    }

    private var currentDate: Date {
        let state = solarSystem
        let range = state.dateRange
        let total = range.upperBound.timeIntervalSince(range.lowerBound)
        guard total > 0 else { return range.lowerBound }
        return range.lowerBound.addingTimeInterval(total * state.time)
    }

    private var timeBinding: Binding<Double> {
        Binding(
            get: { solarSystem.time },
            set: { store.dispatch(.solarSystem(.setTime($0))) }
        )
    }

    private var solarSystem: SolarSystemState {
        store.state.solarSystem
    }

    private func handleTimelineEditingChanged(_ isEditing: Bool) {
        guard !isEditing else { return }

        let now = Date()
        if let lastTimelineLogDate, now.timeIntervalSince(lastTimelineLogDate) < timelineLogThrottle {
            return
        }

        lastTimelineLogDate = now
        analytics.logTimelineChanged(value: solarSystem.time, date: currentDate)
    }
}
