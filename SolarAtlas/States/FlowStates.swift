import Foundation
import SwiftUI

/// State for the Solar System flow (controls simulation and selections)
struct SolarSystemState: Equatable {
    var time: Double = 0.5                       // Normalized time slider value (0–1)
    var dateRange: ClosedRange<Date>             // Date range corresponding to slider
    var showAtlasPath: Bool = true               // Toggle for showing comet ATLAS path
    var showOrbits: Bool = true                  // Toggle for showing planetary orbits
    var showLabels: Bool = true                  // Toggle for planet name labels
    var selected: BodyID? = nil                  // Currently selected celestial body
}

/// State for the News Feed flow
struct NewsFeedState: Equatable {
    var newsFeed: [NewsItem] = []                // Loaded news articles
}

/// State for navigation/tab selection
struct NavigationState: Equatable {
    var activeTab: Int = 0                       // Currently selected tab index
}

/// State for forced update logic
struct UpdateState: Equatable {
    var isUpdateRequired: Bool = false           // Whether a forced update is required
}

/// State for advertising
struct AdState: Equatable {
    var interstitialReady: Bool = false          // Whether an interstitial ad is loaded
}
