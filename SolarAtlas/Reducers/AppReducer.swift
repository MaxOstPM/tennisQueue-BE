import ReSwift

/// Combined reducer that updates each feature slice of `AppState` while keeping a single source of truth.
let appReducer: Reducer<AppState> = { action, currentState in
    var state = currentState ?? AppState()

    state.solarSystem = solarSystemReducer(action, state.solarSystem)
    state.newsFeed = newsFeedReducer(action, state.newsFeed)
    state.navigation = navigationReducer(action, state.navigation)
    state.update = updateReducer(action, state.update)
    state.ads = adReducer(action, state.ads)

    return state
}
