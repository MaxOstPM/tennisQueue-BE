import XCTest
@testable import SolarAtlas

final class AtlasPathTests: XCTestCase {
    func testAtlasPositionsAreInterpolatedCorrectly() {
        let expectations: [(time: Double, point: CGPoint)] = [
            (0.0, CGPoint(x: -45.0, y: -12.0)),
            (0.25, CGPoint(x: -16.6666666667, y: -5.0)),
            (0.5, CGPoint(x: 0.0, y: 0.0)),
            (0.75, CGPoint(x: 15.0, y: 4.1666666667)),
            (1.0, CGPoint(x: 45.0, y: 12.0))
        ]

        for expectation in expectations {
            let point = cometAtlasPath.position(at: expectation.time)
            XCTAssertEqual(point.x, expectation.point.x, accuracy: 0.0001, "Unexpected x at t=\(expectation.time)")
            XCTAssertEqual(point.y, expectation.point.y, accuracy: 0.0001, "Unexpected y at t=\(expectation.time)")
        }
    }
}
