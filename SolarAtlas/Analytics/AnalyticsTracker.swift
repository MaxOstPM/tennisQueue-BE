import Foundation
import FirebaseAnalytics

protocol AnalyticsTracking {
    func logPlanetSelected(id: BodyID, name: String)
    func logTimelineChanged(value: Double, date: Date)
    func logNewsItemOpened(id: String, source: String)
    func logAdShown(type: String)
    func logForceUpdateRequired(minimumVersion: String, currentVersion: String)
}

struct AnalyticsTracker: AnalyticsTracking {
    static let shared = AnalyticsTracker()

    private let analytics: Analytics.Type
    private let dateFormatter: ISO8601DateFormatter

    init(analytics: Analytics.Type = Analytics.self,
         dateFormatter: ISO8601DateFormatter = ISO8601DateFormatter()) {
        self.analytics = analytics
        self.dateFormatter = dateFormatter
    }

    func logPlanetSelected(id: BodyID, name: String) {
        logEvent(
            name: "planet_selected",
            parameters: [
                "planet_id": id.rawValue,
                "planet_name": name
            ]
        )
    }

    func logTimelineChanged(value: Double, date: Date) {
        logEvent(
            name: "timeline_changed",
            parameters: [
                "position": value,
                "date_iso": dateFormatter.string(from: date)
            ]
        )
    }

    func logNewsItemOpened(id: String, source: String) {
        logEvent(
            name: "news_item_opened",
            parameters: [
                "item_id": id,
                "source": source
            ]
        )
    }

    func logAdShown(type: String) {
        logEvent(
            name: "ad_shown",
            parameters: [
                "ad_type": type
            ]
        )
    }

    func logForceUpdateRequired(minimumVersion: String, currentVersion: String) {
        logEvent(
            name: "force_update_required",
            parameters: [
                "min_version": minimumVersion,
                "current_version": currentVersion
            ]
        )
    }

    private func logEvent(name: String, parameters: [String: Any]) {
        analytics.logEvent(name, parameters: parameters)
    }
}
