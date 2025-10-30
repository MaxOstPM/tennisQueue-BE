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
        if !items.isEmpty {
            state.errorMessage = nil
        }
    case .setError(let message):
        state.errorMessage = message
    }
}

/// Reducer for NavigationState
func navigationReducer(state: inout NavigationState, action: NavigationAction) {
    switch action {
    case .setTab(let tab):
        state.activeTab = tab
    case .openRoute(let route):
        state.activeTab = route.tab
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
    case .setInterstitialReady(let isReady):
        state.interstitialReady = isReady
    case .setConsentStatus(let status):
        state.consentStatus = status
        if case .error(let message) = status {
            state.lastError = message
        } else if state.lastError != nil {
            state.lastError = nil
        }
    case .setPersonalization(let personalization):
        state.personalization = personalization
    case .setError(let message):
        state.lastError = message
    }
}
