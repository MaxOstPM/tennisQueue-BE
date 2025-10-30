import Foundation
import ReSwift

/// Actions that mutate SolarSystemState
enum SolarSystemAction: Action {
    case setTime(Double)          // Adjust the time slider value
    case toggleAtlas(Bool)        // Show/hide ATLAS path
    case toggleOrbits(Bool)       // Show/hide orbits
    case toggleLabels(Bool)       // Show/hide labels
    case select(BodyID?)          // Select or deselect a celestial body
}

/// Actions that mutate NewsFeedState
enum NewsFeedAction: Action {
    case loadNews([NewsItem])     // Replace newsFeed with fetched items
}

/// Actions that mutate NavigationState
enum NavigationAction: Action {
    case setTab(AppTab)           // Change the active tab
    case openRoute(AppRoute)      // Handle deep links by mapping to tabs
}

/// Actions that mutate UpdateState
enum UpdateAction: Action {
    case requireUpdate(Bool)      // Set forced-update flag
}

/// Actions that mutate AdState
enum AdAction: Action {
    case setInterstitialReady(Bool)  // Flag whether an interstitial is ready
}
