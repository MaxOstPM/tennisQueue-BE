import Foundation
import ReSwift

/// Container for the app-wide ReSwift store, exposed as an ObservableObject for SwiftUI.
final class AppStore: ObservableObject {
    @Published private(set) var state: AppState

    private let store: Store<AppState>
    init(initialState: AppState = AppState(),
         newsService: NewsServiceType,
         updateService: UpdateServiceType,
         adManager: AdManagerType,
         consentManager: ConsentManagerType,
         analytics: AnalyticsTracking = AnalyticsTracker.shared) {
        self.state = initialState
        let middlewares: [Middleware<AppState>] = [
            createNewsMiddleware(service: newsService),
            createUpdateMiddleware(service: updateService, analytics: analytics),
            createAdMiddleware(manager: adManager, consentManager: consentManager, analytics: analytics),
            createTimelineMiddleware(),
            createAnalyticsMiddleware(tracker: analytics)
        ]

        self.store = Store<AppState>(
            reducer: appReducer,
            state: initialState,
            middleware: middlewares
        )

        store.subscribe(self) { subscription in
            subscription.select { $0 }
        }
    }

    /// Dispatches the provided action to the underlying ReSwift store.
    func dispatch(_ action: AppAction) {
        if Thread.isMainThread {
            store.dispatch(action)
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.store.dispatch(action)
            }
        }
    }
}

extension AppStore: StoreSubscriber {
    func newState(state: AppState) {
        guard self.state != state else { return }
        if Thread.isMainThread {
            self.state = state
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.state = state
            }
        }
    }
}
