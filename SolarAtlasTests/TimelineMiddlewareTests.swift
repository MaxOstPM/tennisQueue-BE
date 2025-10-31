import XCTest
import ReSwift
@testable import SolarAtlas

private final class MockTimelineTicker: TimelineTicking {
    private(set) var isRunning: Bool = false
    private let onTick: (TimeInterval) -> Void

    init(onTick: @escaping (TimeInterval) -> Void) {
        self.onTick = onTick
    }

    func start() {
        isRunning = true
    }

    func stop() {
        isRunning = false
    }

    func send(_ delta: TimeInterval) {
        guard isRunning else { return }
        onTick(delta)
    }
}

final class TimelineMiddlewareTests: XCTestCase {
    func testAutoSpinTickDispatchesOnlyWhenRunning() {
        var dispatchedActions: [AppAction] = []
        var ticker: MockTimelineTicker?

        let middleware = createTimelineMiddleware { handler in
            let mock = MockTimelineTicker(onTick: handler)
            ticker = mock
            return mock
        }

        let dispatch: DispatchFunction = { action in
            if let action = action as? AppAction {
                dispatchedActions.append(action)
            }
            return action
        }

        let middlewareDispatch = middleware(dispatch, { nil }) { $0 }

        middlewareDispatch(AppAction.solarSystem(.startAutoSpin))
        ticker?.send(0.5)

        guard case .solarSystem(.autoSpinTick(let delta))? = dispatchedActions.last else {
            XCTFail("Expected autoSpinTick after ticker fired")
            return
        }
        XCTAssertEqual(delta, 0.02, accuracy: 0.0001)

        middlewareDispatch(AppAction.solarSystem(.stopAutoSpin))
        let dispatchedCount = dispatchedActions.count
        ticker?.send(0.5)
        XCTAssertEqual(dispatchedActions.count, dispatchedCount)
    }

    func testScopedStartAutoSpinCreatesTicker() {
        var dispatchedActions: [AppAction] = []
        var ticker: MockTimelineTicker?

        let middleware = createTimelineMiddleware { handler in
            let mock = MockTimelineTicker(onTick: handler)
            ticker = mock
            return mock
        }

        let dispatch: DispatchFunction = { action in
            if let action = action as? AppAction {
                dispatchedActions.append(action)
            }
            return action
        }

        let middlewareDispatch = middleware(dispatch, { nil }) { $0 }

        middlewareDispatch(AppAction.solarSystem(.startAutoSpin))
        ticker?.send(0.01)

        guard case .solarSystem(.autoSpinTick(let delta))? = dispatchedActions.last else {
            XCTFail("Expected autoSpinTick when scoped action starts ticker")
            return
        }
        XCTAssertEqual(delta, 0.01, accuracy: 0.0001)

        middlewareDispatch(AppAction.solarSystem(.stopAutoSpin))
        let dispatchedCount = dispatchedActions.count
        ticker?.send(0.25)
        XCTAssertEqual(dispatchedActions.count, dispatchedCount)
    }
}
