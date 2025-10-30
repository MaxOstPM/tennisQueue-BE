import Foundation
import ReSwift

func createUpdateMiddleware(service: UpdateServiceType) -> Middleware<AppState> {
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
                    service.checkForRequiredUpdate { requiresUpdate in
                        DispatchQueue.main.async {
                            dispatch(AppAction.update(.requireUpdate(requiresUpdate)))
                        }
                    }

                default:
                    next(action)
                }
            }
        }
    }
}
