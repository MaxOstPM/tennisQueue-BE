import ReSwift

/// Top-level reducer that routes actions to feature reducers.
func appReducer(action: Action, state: AppState?) -> AppState {
    var state = state ?? AppState()

    guard let appAction = action as? AppAction else {
        return state
    }

    switch appAction {
    case .solarSystem(let solarAction):
        solarSystemReducer(state: &state.solarSystem, action: solarAction)

    case .news(let newsAction):
        newsFeedReducer(state: &state.newsFeed, action: newsAction)

    case .navigation(let navigationAction):
        navigationReducer(state: &state.navigation, action: navigationAction)

    case .update(let updateAction):
        updateReducer(state: &state.update, action: updateAction)

    case .ads(let adAction):
        adReducer(state: &state.ads, action: adAction)

    case .fetchNewsRequested,
         .checkForUpdate,
         .startAdTimer,
         .showInterstitialIfReady:
        // Side-effect-only actions are handled in middleware; reducers keep state unchanged.
        break
    }

    return state
}
