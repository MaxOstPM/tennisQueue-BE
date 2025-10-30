import Foundation
import ReSwift

private let adDisplayInterval: TimeInterval = 60 * 5

func createAdMiddleware(manager: AdManagerType, consentManager: ConsentManagerType) -> Middleware<AppState> {
    return { dispatch, getState in
        var pendingWorkItem: DispatchWorkItem?

        func schedulePresentation() {
            guard consentManager.canServeAds else { return }
            pendingWorkItem?.cancel()
            let workItem = DispatchWorkItem {
                dispatch(AppAction.showInterstitialIfReady)
            }
            pendingWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + adDisplayInterval, execute: workItem)
        }

        func preloadInterstitial() {
            guard consentManager.canServeAds else { return }
            manager.loadInterstitial { isReady, error in
                DispatchQueue.main.async {
                    dispatch(AppAction.ads(.setInterstitialReady(isReady)))
                    if let error {
                        dispatch(AppAction.ads(.setError(error.localizedDescription)))
                    } else if isReady {
                        dispatch(AppAction.ads(.setError(nil)))
                    }
                }
            }
        }

        return { next in
            { action in
                guard let appAction = action as? AppAction else {
                    next(action)
                    return
                }

                switch appAction {
                case .requestAdConsent:
                    next(action)
                    consentManager.requestConsentIfNeeded(presentingViewController: nil) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let outcome):
                                dispatch(AppAction.ads(.setConsentStatus(outcome.status)))
                                dispatch(AppAction.ads(.setPersonalization(outcome.personalization)))
                                dispatch(AppAction.ads(.setError(nil)))
                            case .failure(let error):
                                dispatch(AppAction.ads(.setConsentStatus(.error(error.localizedDescription))))
                                dispatch(AppAction.ads(.setPersonalization(.nonPersonalized)))
                                dispatch(AppAction.ads(.setError(error.localizedDescription)))
                            }

                            if consentManager.canServeAds {
                                dispatch(AppAction.startAdTimer)
                            }
                        }
                    }

                case .startAdTimer:
                    next(action)
                    guard consentManager.canServeAds else { return }
                    preloadInterstitial()
                    schedulePresentation()

                case .appDidBecomeActive:
                    next(action)
                    guard consentManager.canServeAds else { return }
                    if !manager.isInterstitialReady {
                        preloadInterstitial()
                    }
                    schedulePresentation()

                case .showInterstitialIfReady:
                    next(action)
                    guard consentManager.canServeAds else { return }
                    manager.presentInterstitialIfReady { presented, error in
                        DispatchQueue.main.async {
                            if let error {
                                dispatch(AppAction.ads(.setError(error.localizedDescription)))
                            }

                            if presented {
                                dispatch(AppAction.ads(.setInterstitialReady(false)))
                                preloadInterstitial()
                            } else if !manager.isInterstitialReady {
                                preloadInterstitial()
                            }
                        }
                        schedulePresentation()
                    }

                default:
                    next(action)
                }
            }
        }
    }
}
