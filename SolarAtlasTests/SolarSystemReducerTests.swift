import XCTest
@testable import SolarAtlas

final class SolarSystemReducerTests: XCTestCase {
    func testSetTime_clamps() {
        let initial = SolarSystemState(time: 0.5)

        let clampedHigh = solarSystemReducer(AppAction.solarSystem(.setTime(1.2)), initial)
        XCTAssertEqual(clampedHigh.time, 1.0, accuracy: 0.0001)

        let clampedLow = solarSystemReducer(AppAction.solarSystem(.setTime(-0.1)), initial)
        XCTAssertEqual(clampedLow.time, 0.0, accuracy: 0.0001)
    }

    func testCommitTime_updates() {
        let initial = SolarSystemState(time: 0.1)
        let updated = solarSystemReducer(AppAction.solarSystem(.commitTime(0.75)), initial)
        XCTAssertEqual(updated.time, 0.75, accuracy: 0.0001)
    }

    func testAutoSpinToggle() {
        let started = solarSystemReducer(AppAction.solarSystem(.startAutoSpin), SolarSystemState(isAutoSpinning: false))
        XCTAssertTrue(started.isAutoSpinning)

        let stopped = solarSystemReducer(AppAction.solarSystem(.stopAutoSpin), started)
        XCTAssertFalse(stopped.isAutoSpinning)
    }

    func testAutoSpinTick_advancesWhenEnabled() {
        var spinningState = SolarSystemState(time: 0.2, isAutoSpinning: true)
        let advanced = solarSystemReducer(AppAction.solarSystem(.autoSpinTick(1.0)), spinningState)
        XCTAssertEqual(advanced.time, 0.25, accuracy: 0.0001)

        spinningState.isAutoSpinning = false
        let unchanged = solarSystemReducer(AppAction.solarSystem(.autoSpinTick(1.0)), spinningState)
        XCTAssertEqual(unchanged.time, spinningState.time, accuracy: 0.0001)
    }

    func testAutoSpinTick_capsPlaybackSpeed() {
        let fastState = SolarSystemState(time: 0.4, isAutoSpinning: true, playbackSpeed: .ludicrous)
        let advanced = solarSystemReducer(AppAction.solarSystem(.autoSpinTick(1.0)), fastState)
        XCTAssertEqual(advanced.time, 0.5, accuracy: 0.0001)
    }

    func testSetCelestialBodies_updatesBodies() {
        var initial = SolarSystemState()
        initial.bodies = []
        let replacement = SolarSystemBodiesProvider.defaultBodies
        let updated = solarSystemReducer(AppAction.setCelestialBodies(replacement), initial)
        XCTAssertEqual(updated.bodies, replacement)
    }
}
