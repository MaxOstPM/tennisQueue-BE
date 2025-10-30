import Combine
import SwiftUI

/// Slider styled to match the retro neon interface, wired directly to the global app store.
struct NeonSlider: View {
    @EnvironmentObject private var store: AppStore

    @State private var liveValue: Double = 0
    @State private var throttleCancellable: AnyCancellable?
    @State private var isEditing = false
    @State private var shouldResumeAutoSpin = false

    private let range: ClosedRange<Double>
    private let title: String
    private let subtitle: String?
    private let autoSpinOnRelease: Bool
    private let throttleSeconds: TimeInterval = 0.08

    init(range: ClosedRange<Double> = 0...1,
         title: String,
         subtitle: String? = nil,
         autoSpinOnRelease: Bool = true) {
        self.range = range
        self.title = title
        self.subtitle = subtitle
        self.autoSpinOnRelease = autoSpinOnRelease
    }

    var body: some View {
        VStack(alignment: .leading, spacing: .spaceSM) {
            VStack(alignment: .leading, spacing: .spaceXS) {
                Text(title)
                    .font(Font.ds.bodyEmphasis)
                    .foregroundColor(.foregroundCyan)
                if let subtitle {
                    Text(subtitle)
                        .font(Font.ds.caption)
                        .foregroundColor(.mutedText)
                }
            }

            Slider(
                value: Binding(
                    get: { liveValue },
                    set: { newValue in
                        liveValue = newValue
                        scheduleThrottledUpdate(for: newValue)
                    }
                ),
                in: range,
                onEditingChanged: handleEditingChanged
            )
            .tint(.terminalCyan)
            .shadow(color: .terminalCyanGlow, radius: 4)
        }
        .onAppear {
            liveValue = store.state.solarSystem.time
        }
        .onChange(of: store.state.solarSystem.time) { newValue in
            guard !isEditing else { return }
            liveValue = newValue
        }
        .onDisappear {
            throttleCancellable?.cancel()
        }
    }

    private func scheduleThrottledUpdate(for value: Double) {
        throttleCancellable?.cancel()
        throttleCancellable = Just(value)
            .delay(for: .seconds(throttleSeconds), scheduler: RunLoop.main)
            .sink { latest in
                store.dispatch(.solarSystem(.setTime(latest)))
            }
    }

    private func handleEditingChanged(_ editing: Bool) {
        if editing {
            isEditing = true
            shouldResumeAutoSpin = store.state.solarSystem.isAutoSpinning
            throttleCancellable?.cancel()
            store.dispatch(.solarSystem(.stopAutoSpin))
        } else {
            isEditing = false
            throttleCancellable?.cancel()
            store.dispatch(.solarSystem(.commitTime(liveValue)))
            if autoSpinOnRelease && shouldResumeAutoSpin {
                store.dispatch(.solarSystem(.startAutoSpin))
            }
            shouldResumeAutoSpin = false
        }
    }
}
