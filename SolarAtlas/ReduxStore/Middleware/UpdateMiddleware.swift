import Foundation
import ReSwift

func createUpdateMiddleware(service: UpdateServiceType,
                            analytics: AnalyticsTracking) -> Middleware<AppState> {
    return { dispatch, getState in
        { next in
            { action in
                guard let appAction = action as? AppAction else {
                    next(action)
                    return
                }

                switch appAction {
                case .checkForUpdate:
                    next(action)
                    service.checkForRequiredUpdate { requirement in
                        DispatchQueue.main.async {
                            dispatch(AppAction.update(.requireUpdate(requirement.requiresUpdate)))
                            if requirement.requiresUpdate {
                                analytics.logForceUpdateRequired(
                                    minimumVersion: requirement.minimumVersion,
                                    currentVersion: requirement.currentVersion
                                )
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
