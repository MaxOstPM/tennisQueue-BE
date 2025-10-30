import Foundation
import ReSwift

func createNewsMiddleware(service: NewsServiceType) -> Middleware<AppState> {
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
                            NSLog("Failed to fetch news: %@", error.localizedDescription)
                            DispatchQueue.main.async {
                                dispatch(AppAction.news(.loadNews([])))
                                dispatch(AppAction.news(.setError("Unable to retrieve the latest dispatches. Check your connection and try again.")))
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
