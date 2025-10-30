import Foundation
import GoogleMobileAds
import UIKit

protocol AdManagerType: AnyObject {
    var isInterstitialReady: Bool { get }
    func loadInterstitial(completion: @escaping (Bool, Error?) -> Void)
    func presentInterstitialIfReady(completion: @escaping (Bool, Error?) -> Void)
}

final class AdManager: NSObject, AdManagerType {
    private let adUnitID: String
    private let consentManager: ConsentManagerType
    private var interstitial: GADInterstitialAd?
    private var readinessCompletion: ((Bool, Error?) -> Void)?

    init(interstitialAdUnitID: String, consentManager: ConsentManagerType) {
        self.adUnitID = interstitialAdUnitID
        self.consentManager = consentManager
        super.init()
    }

    var isInterstitialReady: Bool {
        interstitial != nil
    }

    func loadInterstitial(completion: @escaping (Bool, Error?) -> Void) {
        guard consentManager.canServeAds else {
            completion(false, nil)
            return
        }

        readinessCompletion = completion
        let request = consentManager.makeAdRequest()
        GADInterstitialAd.load(withAdUnitID: adUnitID, request: request) { [weak self] ad, error in
            guard let self else { return }

            if let error {
                NSLog("Interstitial failed to load: %@", error.localizedDescription)
                self.interstitial = nil
                self.finishLoad(success: false, error: error)
                return
            }

            guard let ad else {
                self.interstitial = nil
                self.finishLoad(success: false, error: nil)
                return
            }

            ad.fullScreenContentDelegate = self
            self.interstitial = ad
            self.finishLoad(success: true, error: nil)
        }
    }

    func presentInterstitialIfReady(completion: @escaping (Bool, Error?) -> Void) {
        guard consentManager.canServeAds else {
            completion(false, nil)
            return
        }

        guard let interstitial, let rootViewController = Self.topViewController() else {
            completion(false, nil)
            return
        }

        interstitial.present(fromRootViewController: rootViewController)
        self.interstitial = nil
        completion(true, nil)
    }

    private func finishLoad(success: Bool, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.readinessCompletion?(success, error)
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
        NSLog("Interstitial failed to present: %@", error.localizedDescription)
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        loadInterstitial { _, _ in }
    }
}
