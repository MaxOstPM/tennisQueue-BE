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
    static let fallbackTitle = String(localized: "news.item.fallbackTitle", comment: "Fallback title when Firestore omits a title")
    static let fallbackSummary = String(localized: "news.item.fallbackSummary", comment: "Fallback summary when Firestore omits a summary")
    static let fallbackSource = String(localized: "news.item.fallbackSource", comment: "Fallback source label when Firestore omits it")

    /// Lightweight placeholder item used when loading preview data.
    static var placeholder: NewsItem {
        NewsItem(
            title: String(localized: "news.item.placeholderTitle", comment: "Title used for preview placeholder content"),
            summary: String(localized: "news.item.placeholderSummary", comment: "Summary used for preview placeholder content"),
            publishedAt: Date(),
            source: String(localized: "news.item.placeholderSource", comment: "Source used for preview placeholder content"),
            articleURL: nil
        )
    }
}
