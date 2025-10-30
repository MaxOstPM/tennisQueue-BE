import Foundation
import ReSwift

func createNewsMiddleware(service: NewsServiceType) -> Middleware<AppState> {
    let logger = AppLogger.category(.news)

    return { dispatch, getState in
        { next in
            { action in
                guard let appAction = action as? AppAction else {
                    next(action)
                    return
                }

                switch appAction {
                case .fetchNewsRequested:
                    next(action)
                    service.fetchLatestNews { result in
                        switch result {
                        case .success(let items):
                            DispatchQueue.main.async {
                                dispatch(AppAction.news(.setError(nil)))
                                dispatch(AppAction.news(.loadNews(items)))
                            }
                        case .failure(let error):
                            logger.error("Failed to fetch news", error: error)
                            DispatchQueue.main.async {
                                dispatch(AppAction.news(.loadNews([])))
                                dispatch(AppAction.news(.setError(error)))
                            }
                        }
                    }

                default:
                    next(action)
                }
            }
        }
    }
}
