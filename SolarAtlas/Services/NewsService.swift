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
    }

    func fetchLatestNews(completion: @escaping (Result<[NewsItem], Error>) -> Void) {
        database.collection(collectionName)
            .order(by: "published_at", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }

                let items: [NewsItem] = documents.compactMap { document in
                    let data = document.data()
                    guard let title = data["title"] as? String,
                          let summary = data["summary"] as? String,
                          let source = data["source"] as? String,
                          let timestamp = data["published_at"] as? Timestamp else {
                        return nil
                    }

                    let url: URL?
                    if let urlString = data["url"] as? String {
                        url = URL(string: urlString)
                    } else {
                        url = nil
                    }

                    return NewsItem(
                        id: UUID(uuidString: document.documentID) ?? UUID(),
                        title: title,
                        summary: summary,
                        publishedAt: timestamp.dateValue(),
                        source: source,
                        articleURL: url
                    )
                }

                completion(.success(items))
            }
    }
}
