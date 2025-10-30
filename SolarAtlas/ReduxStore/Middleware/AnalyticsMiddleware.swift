import Foundation
import ReSwift

func createAnalyticsMiddleware(tracker: AnalyticsTracking) -> Middleware<AppState> {
    return { _, _ in
        { next in
            { action in
                if let appAction = action as? AppAction {
                    switch appAction {
                    case .solarSystem(let solarAction):
                        switch solarAction {
                        case .select(let bodyID):
                            if let bodyID,
                               let body = solarSystemBodies.first(where: { $0.id == bodyID }) {
                                tracker.logPlanetSelected(id: bodyID, name: body.displayName)
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
