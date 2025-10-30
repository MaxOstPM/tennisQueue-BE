import Foundation
import GoogleMobileAds
import UIKit

protocol AdManagerType: AnyObject {
    var isInterstitialReady: Bool { get }
    func loadInterstitial(completion: @escaping (Result<Bool, AppError>) -> Void)
    func presentInterstitialIfReady(completion: @escaping (Result<Bool, AppError>) -> Void)
}

final class AdManager: NSObject, AdManagerType {
    private let adUnitID: String
    private let consentManager: ConsentManagerType
    private var interstitial: GADInterstitialAd?
    private var readinessCompletion: ((Result<Bool, AppError>) -> Void)?
    private let logger = AppLogger.category(.ads)

    init(interstitialAdUnitID: String, consentManager: ConsentManagerType) {
        self.adUnitID = interstitialAdUnitID
        self.consentManager = consentManager
        super.init()
    }

    var isInterstitialReady: Bool {
        interstitial != nil
    }

    func loadInterstitial(completion: @escaping (Result<Bool, AppError>) -> Void) {
        guard consentManager.canServeAds else {
            completion(.success(false))
            return
        }

        readinessCompletion = completion
        let request = consentManager.makeAdRequest()
        GADInterstitialAd.load(withAdUnitID: adUnitID, request: request) { [weak self] ad, error in
            guard let self else { return }

            if let error {
                let appError = AppError.adsNoFill
                self.logger.warning("Interstitial failed to load", metadata: ["underlying": error.localizedDescription])
                self.interstitial = nil
                self.finishLoad(result: .failure(appError))
                return
            }

            guard let ad else {
                self.interstitial = nil
                self.finishLoad(result: .success(false))
                return
            }

            ad.fullScreenContentDelegate = self
            self.interstitial = ad
            self.finishLoad(result: .success(true))
        }
    }

    func presentInterstitialIfReady(completion: @escaping (Result<Bool, AppError>) -> Void) {
        guard consentManager.canServeAds else {
            completion(.success(false))
            return
        }

        guard let interstitial, let rootViewController = Self.topViewController() else {
            completion(.success(false))
            return
        }

        interstitial.present(fromRootViewController: rootViewController)
        self.interstitial = nil
        completion(.success(true))
    }

    private func finishLoad(result: Result<Bool, AppError>) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.readinessCompletion?(result)
            self.readinessCompletion = nil
        }
    }

    private static func topViewController(base: UIViewController? = UIApplication.shared.connectedScenes
        .compactMap { ($0 as? UIWindowScene)?.keyWindow }
        .first?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return topViewController(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

extension AdManager: GADFullScreenContentDelegate {
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        let appError = AppError.adsPresentation(underlying: error.localizedDescription)
        logger.error("Interstitial presentation failed", error: appError)
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        loadInterstitial { _ in }
    }
}
