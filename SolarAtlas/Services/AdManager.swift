import Foundation
import GoogleMobileAds
import UIKit

protocol AdManagerType: AnyObject {
    var isInterstitialReady: Bool { get }
    func loadInterstitial(completion: @escaping (Bool) -> Void)
    func presentInterstitialIfReady(completion: @escaping (Bool) -> Void)
}

final class AdManager: NSObject, AdManagerType {
    private let adUnitID: String
    private var interstitial: GADInterstitialAd?
    private var readinessCompletion: ((Bool) -> Void)?

    init(adUnitID: String) {
        self.adUnitID = adUnitID
        super.init()
    }

    var isInterstitialReady: Bool {
        interstitial != nil
    }

    func loadInterstitial(completion: @escaping (Bool) -> Void) {
        readinessCompletion = completion
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: adUnitID, request: request) { [weak self] ad, error in
            guard let self else { return }

            if let error = error {
                NSLog("Interstitial failed to load: %@", error.localizedDescription)
                self.interstitial = nil
                self.readinessCompletion?(false)
                self.readinessCompletion = nil
                return
            }

            ad?.fullScreenContentDelegate = self
            self.interstitial = ad
            self.readinessCompletion?(true)
            self.readinessCompletion = nil
        }
    }

    func presentInterstitialIfReady(completion: @escaping (Bool) -> Void) {
        guard let interstitial = interstitial, let rootViewController = Self.topViewController() else {
            completion(false)
            return
        }

        interstitial.present(fromRootViewController: rootViewController)
        self.interstitial = nil
        completion(true)
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
        loadInterstitial { _ in }
    }
}
