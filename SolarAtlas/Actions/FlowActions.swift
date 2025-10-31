import Foundation
import ReSwift

/// Actions that mutate SolarSystemState
enum SolarSystemAction: Action {
    case setTime(Double)          // Adjust the time slider value
    case commitTime(Double)       // Finalize the time slider value
    case startAutoSpin            // Enable continuous auto spin
    case stopAutoSpin             // Disable auto spin
    case autoSpinTick(TimeInterval) // Tick emitted from display-link middleware
    case toggleAtlas(Bool)        // Show/hide ATLAS path
    case toggleOrbits(Bool)       // Show/hide orbits
    case toggleLabels(Bool)       // Show/hide labels
    case selectBody(BodyID?)      // Select or deselect a celestial body
}

/// Actions that mutate NewsFeedState
enum NewsFeedAction: Action {
    case loadNews([NewsItem])     // Replace newsFeed with fetched items
    case setError(AppError?)      // Persist the latest fetch error
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
    case setInterstitialReady(Bool)            // Flag whether an interstitial is ready
    case setConsentStatus(AdConsentStatus)     // Track consent gathering progress/result
    case setPersonalization(AdPersonalization) // Toggle whether personalized ads are allowed
    case setError(AppError?)                   // Persist the last ad-related error
}
