import XCTest
@testable import SolarAtlas

final class NavigationReducerTests: XCTestCase {
    func testOpenRouteSetsNewsTab() {
        var state = NavigationState()
        navigationReducer(state: &state, action: .openRoute(.news))
        XCTAssertEqual(state.activeTab, .news)
    }
}
