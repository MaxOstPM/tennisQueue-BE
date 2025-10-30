import SwiftUI

/// The main view for the Solar System tab: renders orbits, planets, and controls with info overlays.
struct SolarSystemView: View {
    @EnvironmentObject private var store: AppStore
    @State private var timelineSliderValue: Double = 0
    @State private var isInteractingWithTimeline = false
    @State private var pendingSampleValue: Double?
    @State private var sliderSampleWorkItem: DispatchWorkItem?
    @State private var lastSampleDate: Date = .distantPast

    private let timelineSampleInterval: TimeInterval = 0.08

    private var selectedBody: CelestialBody? {
        guard let id = store.state.solarSystem.selected else { return nil }
        return solarSystemBodies.first { $0.id == id }
    }

    private var timelineDate: Date {
        let range = store.state.solarSystem.dateRange
        let clamped = min(max(store.state.solarSystem.time, 0), 1)
        let interval = range.upperBound.timeIntervalSince(range.lowerBound)
        return range.lowerBound.addingTimeInterval(interval * clamped)
    }

    private var timelineSubtitle: String {
        SolarSystemView.dateFormatter.string(from: timelineDate)
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    private var solarSystem: SolarSystemState {
        store.state.solarSystem
    }

    @ViewBuilder
    private var toggleRows: some View {
        ToggleRow(
            title: NSLocalizedString("Show ATLAS Path", comment: "Toggle ATLAS path"),
            isOn: Binding(
                get: { store.state.solarSystem.showAtlasPath },
                set: { store.dispatch(.solarSystem(.toggleAtlas($0))) }
            )
        )
        ToggleRow(
            title: NSLocalizedString("Show Orbits", comment: "Toggle orbits"),
            isOn: Binding(
                get: { store.state.solarSystem.showOrbits },
                set: { store.dispatch(.solarSystem(.toggleOrbits($0))) }
            )
        )
        ToggleRow(
            title: NSLocalizedString("Show Labels", comment: "Toggle labels"),
            isOn: Binding(
                get: { store.state.solarSystem.showLabels },
                set: { store.dispatch(.solarSystem(.toggleLabels($0))) }
            )
        )
    }

    var body: some View {
        ZStack {
            Color.spaceBlack
                .ignoresSafeArea()

            StarfieldBackground()
                .ignoresSafeArea()

            SolarCanvas()
                .ignoresSafeArea()

            VStack {
                Spacer()

                TerminalPanel(borderColor: .terminalCyan) {
                    VStack(alignment: .leading, spacing: .spaceMD) {
                        NeonSlider(
                            value: $timelineSliderValue,
                            title: NSLocalizedString("Mission Timeline", comment: "Timeline slider title"),
                            subtitle: timelineSubtitle,
                            onEditingChanged: handleTimelineEditingChanged,
                            onValueChanged: handleTimelineValueChanged
                        )

                        Divider()
                            .background(Color.terminalCyanDim)

                        ViewThatFits(in: .vertical) {
                            HStack(alignment: .top, spacing: .spaceXL) {
                                toggleRows
                            }

                            VStack(alignment: .leading, spacing: .spaceSM) {
                                toggleRows
                            }
                        }
                    }
                }
                .padding(.horizontal, .space2XL)
                .padding(.bottom, .space2XL)
            }

            if let body = selectedBody {
                VStack {
                    Spacer()
                    BodyInfoSheet(celestial: body)
                        .padding(.horizontal, .space2XL)
                        .padding(.bottom, .space6XL)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .animation(.easeInOut(duration: 0.25), value: body.id)
            }
        }
        .onAppear {
            timelineSliderValue = store.state.solarSystem.time
        }
        .onDisappear {
            cancelPendingTimelineSample()
        }
        .onChange(of: store.state.solarSystem.time) { newValue in
            guard !isInteractingWithTimeline else { return }
            timelineSliderValue = newValue
        }
    }
}

// MARK: - Decorative background

private struct StarfieldBackground: View {
    @State private var stars: [CGPoint]

    init(count: Int = 90) {
        _stars = State(initialValue: StarfieldBackground.generateStars(count: count))
    }

    var body: some View {
        GeometryReader { _ in
            Canvas { context, size in
                for point in stars {
                    let starRect = CGRect(
                        x: point.x * size.width,
                        y: point.y * size.height,
                        width: 2,
                        height: 2
                    )
                    let starPath = Path(ellipseIn: starRect)
                    context.fill(starPath, with: .color(.starfieldParticle))
                }
            }
        }
        .allowsHitTesting(false)
        .opacity(0.35)
        .blur(radius: 0.2)
    }

    private static func generateStars(count: Int) -> [CGPoint] {
        (0..<count).map { _ in
            CGPoint(x: Double.random(in: 0...1), y: Double.random(in: 0...1))
        }
    }
}

// MARK: - Timeline interactions

private extension SolarSystemView {
    func handleTimelineEditingChanged(_ isEditing: Bool) {
        if isEditing {
            isInteractingWithTimeline = true
            cancelPendingTimelineSample()
            lastSampleDate = .distantPast
        } else {
            isInteractingWithTimeline = false
            let committedValue = timelineSliderValue
            cancelPendingTimelineSample()
            lastSampleDate = Date()
            store.dispatch(.solarSystem(.setTime(committedValue)))
        }
    }

    func handleTimelineValueChanged(_ newValue: Double) {
        guard isInteractingWithTimeline else { return }

        let now = Date()
        let elapsed: TimeInterval
        if lastSampleDate == .distantPast {
            elapsed = timelineSampleInterval
        } else {
            elapsed = now.timeIntervalSince(lastSampleDate)
        }

        if elapsed >= timelineSampleInterval {
            lastSampleDate = now
            store.dispatch(.solarSystem(.setTime(newValue)))
            pendingSampleValue = nil
        } else {
            pendingSampleValue = newValue
            if sliderSampleWorkItem == nil {
                let delay = max(timelineSampleInterval - elapsed, 0)
                let workItem = DispatchWorkItem {
                    lastSampleDate = Date()
                    if let pending = pendingSampleValue {
                        store.dispatch(.solarSystem(.setTime(pending)))
                        pendingSampleValue = nil
                    }
                    sliderSampleWorkItem = nil
                }
                sliderSampleWorkItem = workItem
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
            }
        }
    }

    func cancelPendingTimelineSample() {
        sliderSampleWorkItem?.cancel()
        sliderSampleWorkItem = nil
        pendingSampleValue = nil
    }
}
