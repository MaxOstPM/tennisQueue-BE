import Foundation
import ReSwift

func createAnalyticsMiddleware(tracker: AnalyticsTracking) -> Middleware<AppState> {
    return { _, getState in
        { next in
            { action in
                if let appAction = action as? AppAction {
                    switch appAction {
                    case .solarSystem(let solarAction):
                        switch solarAction {
                        case .selectBody(let bodyID):
                            if let bodyID,
                               let state = getState?(),
                               let body = state.solarSystem.bodies.first(where: { $0.bodyID == bodyID }) {
                                tracker.logPlanetSelected(id: bodyID, name: body.displayName)
                            }
                        case .commitTime(let value):
                            if let state = getState?() {
                                logTimelineChanged(in: state.solarSystem, value: value, tracker: tracker)
                            }
                        default:
                            break
                        }
                    default:
                        break
                    }
                }

                next(action)
            }
        }
    }
}

private func logTimelineChanged(in state: SolarSystemState,
                                value: Double,
                                tracker: AnalyticsTracking) {
    let clamped = max(0, min(1, value))
    let range = state.dateRange
    let interval = range.upperBound.timeIntervalSince(range.lowerBound)
    let date = range.lowerBound.addingTimeInterval(interval * clamped)
    tracker.logTimelineChanged(value: clamped, date: date)
}
