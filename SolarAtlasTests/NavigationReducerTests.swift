import XCTest
@testable import SolarAtlas

final class NavigationReducerTests: XCTestCase {
    func testOpenRouteSetsNewsTab() {
        let action = AppAction.navigation(.openRoute(.news))
        let updated = navigationReducer(action, NavigationState())
        XCTAssertEqual(updated.activeTab, .news)
    }
}
