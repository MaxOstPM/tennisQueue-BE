import SwiftUI

/// Slider styled to match the retro neon interface, wired directly to the global app store.
struct NeonSlider: View {
    @EnvironmentObject private var store: AppStore

    @State private var isEditing = false
    @State private var shouldResumeAutoSpin = false

    private let range: ClosedRange<Double>
    private let title: String
    private let subtitle: String?
    private let autoSpinOnRelease: Bool

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
                    get: { store.state.solarSystem.time },
                    set: { newValue in
                        store.dispatch(.solarSystem(.setTime(newValue)))
                    }
                ),
                in: range,
                onEditingChanged: handleEditingChanged
            )
            .tint(.terminalCyan)
            .shadow(color: .terminalCyanGlow, radius: 4)
        }
    }

    private func handleEditingChanged(_ editing: Bool) {
        if editing {
            isEditing = true
            shouldResumeAutoSpin = store.state.solarSystem.isAutoSpinning
            store.dispatch(.solarSystem(.stopAutoSpin))
        } else {
            isEditing = false
            store.dispatch(.solarSystem(.commitTime(store.state.solarSystem.time)))
            if autoSpinOnRelease && shouldResumeAutoSpin {
                store.dispatch(.solarSystem(.startAutoSpin))
            }
            shouldResumeAutoSpin = false
        }
    }
}
