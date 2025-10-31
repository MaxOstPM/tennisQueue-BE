import Foundation
import GoogleMobileAds
import SwiftUI
import UIKit

struct BannerAdView: UIViewRepresentable {
    typealias UIViewType = GADBannerView

    @ObservedObject private var consentManager: ConsentManager
    private let adUnitID: String

    init(consentManager: ConsentManager = .shared,
         adUnitID: String = AdConfiguration.bannerAdUnitID) {
        self._consentManager = ObservedObject(initialValue: consentManager)
        self.adUnitID = adUnitID
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(consentManager: consentManager, adUnitID: adUnitID)
    }

    func makeUIView(context: Context) -> GADBannerView {
        let banner = GADBannerView(adSize: GADAdSizeBanner)
        banner.adUnitID = adUnitID
        banner.delegate = context.coordinator
        context.coordinator.bannerView = banner
        context.coordinator.updateRootViewController()
        context.coordinator.loadAdIfNeeded()
        return banner
    }

    func updateUIView(_ uiView: GADBannerView, context: Context) {
        context.coordinator.bannerView = uiView
        context.coordinator.updateRootViewController()
        context.coordinator.loadAdIfNeeded()
    }

    final class Coordinator: NSObject, GADBannerViewDelegate {
        private let consentManager: ConsentManager
        private let adUnitID: String
        private var didLoadAd = false
        private let logger = AppLogger.category(.ads)

        weak var bannerView: GADBannerView?

        init(consentManager: ConsentManager, adUnitID: String) {
            self.consentManager = consentManager
            self.adUnitID = adUnitID
        }

        func updateRootViewController() {
            bannerView?.rootViewController = Self.topViewController()
        }

        func loadAdIfNeeded() {
            guard let bannerView else { return }
            guard consentManager.canServeAds else { return }
            guard !didLoadAd else { return }

            let request = consentManager.makeAdRequest()
            bannerView.load(request)
        }

        func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
            didLoadAd = true
        }

        func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
            let appError = AppError.mapAdLoadError(error)
            logger.warning("Banner ad failed to load",
                           metadata: appError.metadata.merging(["raw": error.localizedDescription]) { $1 },
                           error: appError)
            didLoadAd = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 30) { [weak self] in
                self?.loadAdIfNeeded()
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
}
