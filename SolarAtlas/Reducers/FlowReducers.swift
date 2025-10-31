import Foundation
import ReSwift

/// Reducer that mutates the `SolarSystemState` slice of the app state.
let solarSystemReducer: Reducer<SolarSystemState> = { action, currentState in
    var state = currentState ?? SolarSystemState()

    func applySetTime(_ value: Double) {
        state.time = clamp01(value)
    }

    func applyCommitTime(_ value: Double) {
        state.time = clamp01(value)
    }

    func applyStartAutoSpin() {
        state.isAutoSpinning = true
    }

    func applyStopAutoSpin() {
        state.isAutoSpinning = false
    }

    func applyAutoSpinTick(_ delta: TimeInterval) {
        guard state.isAutoSpinning else { return }
        let revPerSec = min(state.playbackSpeed.rawValue, 0.1)
        state.time = wrap01(state.time + delta * revPerSec)
    }

    guard let appAction = action as? AppAction else {
        return state
    }

    switch appAction {
    case .solarSystem(let solarAction):
        switch solarAction {
        case .setTime(let value):
            applySetTime(value)
        case .commitTime(let value):
            applyCommitTime(value)
        case .startAutoSpin:
            applyStartAutoSpin()
        case .stopAutoSpin:
            applyStopAutoSpin()
        case .autoSpinTick(let delta):
            applyAutoSpinTick(delta)
        case .toggleAtlas(let flag):
            state.showAtlasPath = flag
        case .toggleOrbits(let flag):
            state.showOrbits = flag
        case .toggleLabels(let flag):
            state.showLabels = flag
        case .selectBody(let bodyID):
            state.selectedBody = bodyID
        }
    case .setCelestialBodies(let bodies):
        state.bodies = bodies
    default:
        break
    }

    return state
}

/// Reducer that mutates the `NewsFeedState` slice of the app state.
let newsFeedReducer: Reducer<NewsFeedState> = { action, currentState in
    var state = currentState ?? NewsFeedState()

    guard let appAction = action as? AppAction,
          case let .news(newsAction) = appAction else {
        return state
    }

    switch newsAction {
    case .loadNews(let items):
        state.newsFeed = items
        if !items.isEmpty {
            state.error = nil
        }
    case .setError(let error):
        state.error = error
    }

    return state
}

/// Reducer that mutates the `NavigationState` slice of the app state.
let navigationReducer: Reducer<NavigationState> = { action, currentState in
    var state = currentState ?? NavigationState()

    guard let appAction = action as? AppAction,
          case let .navigation(navigationAction) = appAction else {
        return state
    }

    switch navigationAction {
    case .setTab(let tab):
        state.activeTab = tab
    case .openRoute(let route):
        state.activeTab = route.tab
    }

    return state
}

/// Reducer that mutates the `UpdateState` slice of the app state.
let updateReducer: Reducer<UpdateState> = { action, currentState in
    var state = currentState ?? UpdateState()

    guard let appAction = action as? AppAction,
          case let .update(updateAction) = appAction else {
        return state
    }

    switch updateAction {
    case .requireUpdate(let flag):
        state.isUpdateRequired = flag
    }

    return state
}

/// Reducer that mutates the `AdState` slice of the app state.
let adReducer: Reducer<AdState> = { action, currentState in
    var state = currentState ?? AdState()

    guard let appAction = action as? AppAction,
          case let .ads(adAction) = appAction else {
        return state
    }

    switch adAction {
    case .setInterstitialReady(let isReady):
        state.interstitialReady = isReady
    case .setConsentStatus(let status):
        state.consentStatus = status
        if case .error(let error) = status {
            state.lastError = error
        } else if state.lastError != nil {
            state.lastError = nil
        }
    case .setPersonalization(let personalization):
        state.personalization = personalization
    case .setError(let error):
        state.lastError = error
    }

    return state
}

@inline(__always)
private func clamp01(_ value: Double) -> Double {
    max(0, min(1, value))
}

@inline(__always)
private func wrap01(_ value: Double) -> Double {
    let wrapped = value - floor(value)
    return wrapped < 0 ? wrapped + 1 : wrapped
}
