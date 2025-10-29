import Foundation

/// Reducer for SolarSystemState
func solarSystemReducer(state: inout SolarSystemState, action: SolarSystemAction) {
    switch action {
    case .setTime(let newTime):
        state.time = newTime
    case .toggleAtlas(let flag):
        state.showAtlasPath = flag
    case .toggleOrbits(let flag):
        state.showOrbits = flag
    case .toggleLabels(let flag):
        state.showLabels = flag
    case .select(let bodyID):
        state.selected = bodyID
    }
}

/// Reducer for NewsFeedState
func newsFeedReducer(state: inout NewsFeedState, action: NewsFeedAction) {
    switch action {
    case .loadNews(let items):
        state.newsFeed = items
    }
}

/// Reducer for NavigationState
func navigationReducer(state: inout NavigationState, action: NavigationAction) {
    switch action {
    case .setTab(let tab):
        state.activeTab = tab
    }
}

/// Reducer for UpdateState
func updateReducer(state: inout UpdateState, action: UpdateAction) {
    switch action {
    case .requireUpdate(let flag):
        state.isUpdateRequired = flag
    }
}

/// Reducer for AdState
func adReducer(state: inout AdState, action: AdAction) {
    switch action {
    case .updateAds(let newAdState):
        state = newAdState
    }
}
