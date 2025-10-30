import FirebaseFirestore
import Foundation

protocol NewsServiceType {
    func fetchLatestNews(completion: @escaping (Result<[NewsItem], Error>) -> Void)
}

struct FirestoreNewsService: NewsServiceType {
    private let database: Firestore
    private let collectionName: String

    init(database: Firestore = Firestore.firestore(), collectionName: String = "news") {
        self.database = database
        self.collectionName = collectionName

        var settings = database.settings
        if settings.isPersistenceEnabled == false {
            settings.isPersistenceEnabled = true
            self.database.settings = settings
        }
    }

    func fetchLatestNews(completion: @escaping (Result<[NewsItem], Error>) -> Void) {
        database.collection(collectionName)
            .order(by: "publishedAt", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                let documents = snapshot?.documents ?? []
                let items = documents.map { document -> NewsItem in
                    mapDocumentToNewsItem(document)
                }

                completion(.success(items))
            }
    }

    private func mapDocumentToNewsItem(_ document: QueryDocumentSnapshot) -> NewsItem {
        let data = document.data()

        let title = (data["title"] as? String)?.sanitized ?? NewsItem.fallbackTitle
        let summary = (data["summary"] as? String)?.sanitized ?? NewsItem.fallbackSummary
        let source = (data["source"] as? String)?.sanitized ?? NewsItem.fallbackSource

        let publishedAt: Date
        if let timestamp = data["publishedAt"] as? Timestamp {
            publishedAt = timestamp.dateValue()
        } else if let date = data["publishedAt"] as? Date {
            publishedAt = date
        } else if let seconds = data["publishedAt"] as? TimeInterval {
            publishedAt = Date(timeIntervalSince1970: seconds)
        } else if let milliseconds = data["publishedAt"] as? Int {
            publishedAt = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
        } else if let createTime = document.createTime?.dateValue() {
            publishedAt = createTime
        } else if let updateTime = document.updateTime?.dateValue() {
            publishedAt = updateTime
        } else {
            publishedAt = Date()
        }

        let urlString = (data["url"] as? String)?.sanitized ?? (data["articleURL"] as? String)?.sanitized
        let articleURL = urlString.flatMap { URL(string: $0) }

        let identifier = UUID(uuidString: document.documentID) ?? UUID()

        return NewsItem(
            id: identifier,
            title: title,
            summary: summary,
            publishedAt: publishedAt,
            source: source,
            articleURL: articleURL
        )
    }
}

private extension Optional where Wrapped == String {
    var sanitized: String? {
        guard let value = self?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else {
            return nil
        }
        return value
    }
}
