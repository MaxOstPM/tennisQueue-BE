import Foundation
import SwiftUI

/// Represents a single curated astronomy news article shown in the feed.
struct NewsItem: Identifiable, Equatable {
    let id: UUID
    let title: String
    let summary: String
    let publishedAt: Date
    let source: String
    let articleURL: URL?

    init(id: UUID = UUID(),
         title: String,
         summary: String,
         publishedAt: Date,
         source: String,
         articleURL: URL? = nil) {
        self.id = id
        self.title = title
        self.summary = summary
        self.publishedAt = publishedAt
        self.source = source
        self.articleURL = articleURL
    }
}

extension NewsItem {
    static let fallbackTitle = "Solar Atlas Transmission"
    static let fallbackSummary = "Mission control hasn't shared additional telemetry for this dispatch."
    static let fallbackSource = "Solar Atlas"

    /// Lightweight placeholder item used when loading preview data.
    static var placeholder: NewsItem {
        NewsItem(
            title: "Awaiting Latest Telemetry",
            summary: "Stay tuned for breaking discoveries from observatories across the Solar Atlas network.",
            publishedAt: Date(),
            source: "Solar Atlas",
            articleURL: nil
        )
    }
}
