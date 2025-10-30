import Foundation
import ReSwift

private let adDisplayInterval: TimeInterval = 60 * 5

func createAdMiddleware(manager: AdManagerType) -> Middleware<AppState> {
    return { dispatch, getState in
        var pendingWorkItem: DispatchWorkItem?

        func schedulePresentation() {
            pendingWorkItem?.cancel()
            let workItem = DispatchWorkItem {
                dispatch(AppAction.showInterstitialIfReady)
            }
            pendingWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + adDisplayInterval, execute: workItem)
        }

        return { next in
            { action in
                guard let appAction = action as? AppAction else {
                    next(action)
                    return
                }

                switch appAction {
                case .startAdTimer:
                    next(action)
                    manager.loadInterstitial { isReady in
                        DispatchQueue.main.async {
                            dispatch(AppAction.ads(.setInterstitialReady(isReady)))
                        }
                    }
                    schedulePresentation()

                case .showInterstitialIfReady:
                    next(action)
                    manager.presentInterstitialIfReady { presented in
                        if presented {
                            DispatchQueue.main.async {
                                dispatch(AppAction.ads(.setInterstitialReady(false)))
                            }
                            manager.loadInterstitial { isReady in
                                DispatchQueue.main.async {
                                    dispatch(AppAction.ads(.setInterstitialReady(isReady)))
                                }
                            }
                            schedulePresentation()
                        } else if !manager.isInterstitialReady {
                            manager.loadInterstitial { isReady in
                                DispatchQueue.main.async {
                                    dispatch(AppAction.ads(.setInterstitialReady(isReady)))
                                }
                            }
                            schedulePresentation()
                        } else {
                            schedulePresentation()
                        }
                    }

                default:
                    next(action)
                }
            }
        }
    }
}
