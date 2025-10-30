import Foundation
import SwiftUI

/// State for the Solar System flow (controls simulation and selections)
struct SolarSystemState: Equatable {
    var time: Double
    var dateRange: ClosedRange<Date>
    var showAtlasPath: Bool
    var showOrbits: Bool
    var showLabels: Bool
    var selected: BodyID?

    init(time: Double = 0.5,
         dateRange: ClosedRange<Date>? = nil,
         showAtlasPath: Bool = true,
         showOrbits: Bool = true,
         showLabels: Bool = true,
         selected: BodyID? = nil) {
        self.time = time
        self.dateRange = dateRange ?? Self.defaultDateRange()
        self.showAtlasPath = showAtlasPath
        self.showOrbits = showOrbits
        self.showLabels = showLabels
        self.selected = selected
    }

    private static func defaultDateRange() -> ClosedRange<Date> {
        let calendar = Calendar(identifier: .gregorian)
        let now = Date()
        let start = calendar.date(byAdding: .day, value: -365, to: now) ?? now
        let end = calendar.date(byAdding: .day, value: 365, to: now) ?? now
        return start...end
    }
}

/// State for the News Feed flow
struct NewsFeedState: Equatable {
    var newsFeed: [NewsItem] = []                // Loaded news articles
    var errorMessage: String? = nil              // Last fetch error presented to the user
}

/// State for navigation/tab selection
struct NavigationState: Equatable {
    var activeTab: AppTab = .solarSystem         // Currently selected tab
}

/// State for forced update logic
struct UpdateState: Equatable {
    var isUpdateRequired: Bool = false           // Whether a forced update is required
}

/// State for advertising
struct AdState: Equatable {
    var interstitialReady: Bool = false          // Whether an interstitial ad is loaded
    var consentStatus: AdConsentStatus = .unknown
    var personalization: AdPersonalization = .unknown
    var lastError: String? = nil
}
