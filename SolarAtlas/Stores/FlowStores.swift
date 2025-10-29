import Foundation
import Combine

/// Observable store for SolarSystemState
final class SolarSystemStore: ObservableObject {
    @Published private(set) var state: SolarSystemState

    init(initial: SolarSystemState = SolarSystemStore.makeDefaultState()) {
        self.state = initial
    }

    func dispatch(_ action: SolarSystemAction) {
        DispatchQueue.main.async {
            solarSystemReducer(state: &self.state, action: action)
        }
    }

    private static func makeDefaultState() -> SolarSystemState {
        let calendar = Calendar(identifier: .gregorian)
        let now = Date()
        let start = calendar.date(byAdding: .day, value: -365, to: now) ?? now
        let end = calendar.date(byAdding: .day, value: 365, to: now) ?? now
        return SolarSystemState(dateRange: start...end)
    }
}

/// Observable store for NewsFeedState
final class NewsFeedStore: ObservableObject {
    @Published private(set) var state: NewsFeedState

    init(initial: NewsFeedState) {
        self.state = initial
    }

    func dispatch(_ action: NewsFeedAction) {
        DispatchQueue.main.async {
            newsFeedReducer(state: &self.state, action: action)
        }
    }
}

/// Observable store for NavigationState
final class NavigationStore: ObservableObject {
    @Published private(set) var state: NavigationState

    init(initial: NavigationState) {
        self.state = initial
    }

    func dispatch(_ action: NavigationAction) {
        DispatchQueue.main.async {
            navigationReducer(state: &self.state, action: action)
        }
    }
}

/// Observable store for UpdateState
final class UpdateStore: ObservableObject {
    @Published private(set) var state: UpdateState

    init(initial: UpdateState) {
        self.state = initial
    }

    func dispatch(_ action: UpdateAction) {
        DispatchQueue.main.async {
            updateReducer(state: &self.state, action: action)
        }
    }
}

/// Observable store for AdState
final class AdStore: ObservableObject {
    @Published private(set) var state: AdState

    init(initial: AdState) {
        self.state = initial
    }

    func dispatch(_ action: AdAction) {
        DispatchQueue.main.async {
            adReducer(state: &self.state, action: action)
        }
    }
}
