import Foundation
import XCTest
@testable import SolarAtlas

final class AppReducerTests: XCTestCase {
    func testSolarSystemActionUpdatesSlice() {
        let initial = AppState()
        let action = AppAction.solarSystem(.setTime(0.75))

        let updated = appReducer(action, initial)

        XCTAssertEqual(updated.solarSystem.time, 0.75, accuracy: 0.0001)
        XCTAssertEqual(updated.navigation, initial.navigation)
        XCTAssertEqual(updated.newsFeed, initial.newsFeed)
    }

    func testNewsLoadClearsErrorWhenItemsArrive() {
        let initialNews = NewsFeedState(newsFeed: [], error: AppError.network(underlying: "offline"))
        let initial = AppState(navigation: NavigationState(),
                               solarSystem: SolarSystemState(),
                               newsFeed: initialNews,
                               update: UpdateState(),
                               ads: AdState())
        let article = NewsItem(
            id: UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE") ?? UUID(),
            title: "Launch",
            summary: "Test",
            publishedAt: Date(timeIntervalSince1970: 0),
            source: "Example News",
            articleURL: URL(string: "https://example.com")
        )
        let action = AppAction.news(.loadNews([article]))

        let updated = appReducer(action, initial)

        XCTAssertEqual(updated.newsFeed.newsFeed.count, 1)
        XCTAssertNil(updated.newsFeed.error)
    }

    func testSideEffectActionsDoNotMutateState() {
        let initial = AppState()
        let actions: [AppAction] = [.fetchNewsRequested,
                                    .checkForUpdate,
                                    .startAdTimer,
                                    .showInterstitialIfReady,
                                    .requestAdConsent,
                                    .appDidBecomeActive]

        let result = actions.reduce(initial) { state, action in
            appReducer(action, state)
        }

        XCTAssertEqual(result, initial)
    }
}
