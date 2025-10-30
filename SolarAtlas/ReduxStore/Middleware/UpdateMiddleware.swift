import Foundation
import ReSwift

func createUpdateMiddleware(service: UpdateServiceType,
                            analytics: AnalyticsTracking) -> Middleware<AppState> {
    let logger = AppLogger.category(.remoteConfig)

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
                    service.checkForRequiredUpdate { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let requirement):
                                dispatch(AppAction.update(.requireUpdate(requirement.requiresUpdate)))
                                if requirement.requiresUpdate {
                                    analytics.logForceUpdateRequired(
                                        minimumVersion: requirement.minimumVersion,
                                        currentVersion: requirement.currentVersion
                                    )
                                }
                            case .failure(let error):
                                logger.error("Update check failed", error: error)
                                let fallback = service.fallbackRequirement()
                                dispatch(AppAction.update(.requireUpdate(fallback.requiresUpdate)))
                                if fallback.requiresUpdate {
                                    analytics.logForceUpdateRequired(
                                        minimumVersion: fallback.minimumVersion,
                                        currentVersion: fallback.currentVersion
                                    )
                                }
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
