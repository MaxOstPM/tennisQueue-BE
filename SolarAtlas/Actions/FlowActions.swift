import Foundation

/// Actions that mutate SolarSystemState
enum SolarSystemAction {
    case setTime(Double)          // Adjust the time slider value
    case toggleAtlas(Bool)        // Show/hide ATLAS path
    case toggleOrbits(Bool)       // Show/hide orbits
    case toggleLabels(Bool)       // Show/hide labels
    case select(BodyID?)          // Select or deselect a celestial body
}

/// Actions that mutate NewsFeedState
enum NewsFeedAction {
    case loadNews([NewsItem])     // Replace newsFeed with fetched items
}

/// Actions that mutate NavigationState
enum NavigationAction {
    case setTab(Int)              // Change the active tab index
}

/// Actions that mutate UpdateState
enum UpdateAction {
    case requireUpdate(Bool)      // Set forced-update flag
}

/// Actions that mutate AdState
enum AdAction {
    case updateAds(AdState)       // Replace ad state (e.g., interstitial ready)
}
