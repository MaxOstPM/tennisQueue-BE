import AppTrackingTransparency
import Foundation
import GoogleMobileAds
import SwiftUI
import UIKit
import UserMessagingPlatform

protocol ConsentManagerType: AnyObject {
    var canServeAds: Bool { get }
    var personalization: AdPersonalization { get }
    func requestConsentIfNeeded(presentingViewController: UIViewController?, completion: @escaping (Result<AdConsentOutcome, AppError>) -> Void)
    func makeAdRequest() -> GADRequest
}

final class ConsentManager: NSObject, ObservableObject, ConsentManagerType {
    static let shared = ConsentManager()

    @Published private(set) var canServeAds: Bool = false
    @Published private(set) var consentStatus: AdConsentStatus = .unknown
    @Published private(set) var personalization: AdPersonalization = .unknown

    private let consentInformation = UMPConsentInformation.sharedInstance
    private var isRequestInFlight = false
    private let logger = AppLogger.category(.consent)

    private override init() {
        super.init()
    }

    func requestConsentIfNeeded(presentingViewController: UIViewController?, completion: @escaping (Result<AdConsentOutcome, AppError>) -> Void) {
        if isRequestInFlight {
            DispatchQueue.main.async {
                completion(.success(AdConsentOutcome(status: self.consentStatus, personalization: self.personalization)))
            }
            return
        }

        isRequestInFlight = true
        updateState(status: .requesting, personalization: personalization, canServeAds: consentInformation.canRequestAds)

        let proceedToUMP: () -> Void = { [weak self] in
            guard let self else { return }
            self.performUMPRequest(presentingViewController: presentingViewController, completion: completion)
        }

        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { _ in
                proceedToUMP()
            }
        } else {
            proceedToUMP()
        }
    }

    func makeAdRequest() -> GADRequest {
        let request = GADRequest()
        if personalization == .nonPersonalized {
            let extras = GADExtras()
            extras.additionalParameters = ["npa": "1"]
            request.register(extras)
        }
        return request
    }

    private func performUMPRequest(presentingViewController: UIViewController?, completion: @escaping (Result<AdConsentOutcome, AppError>) -> Void) {
        let parameters = UMPRequestParameters()
        parameters.tagForUnderAgeOfConsent = false

        consentInformation.requestConsentInfoUpdate(with: parameters) { [weak self] error in
            guard let self else { return }
            if let error {
                let appError = AppError.adsConsent(underlying: error.localizedDescription)
                self.logger.error("Consent info update failed", error: appError)
                self.finishRequest(with: .failure(appError), completion: completion)
                return
            }

            if self.consentInformation.formStatus == .available {
                self.presentConsentForm(presentingViewController: presentingViewController, completion: completion)
            } else {
                let outcome = self.outcome(for: self.consentInformation.consentStatus)
                self.finishRequest(with: .success(outcome), completion: completion)
            }
        }
    }

    private func presentConsentForm(presentingViewController: UIViewController?, completion: @escaping (Result<AdConsentOutcome, AppError>) -> Void) {
        UMPConsentForm.load { [weak self] form, error in
            guard let self else { return }

            if let error {
                let appError = AppError.adsConsent(underlying: error.localizedDescription)
                self.logger.error("Consent form load failed", error: appError)
                self.finishRequest(with: .failure(appError), completion: completion)
                return
            }

            guard let form else {
                let appError = AppError.adsConsent(underlying: "form_unavailable")
                self.logger.error("Consent form unavailable", error: appError)
                self.finishRequest(with: .failure(appError), completion: completion)
                return
            }

            DispatchQueue.main.async {
                let presenter = presentingViewController ?? Self.topViewController()
                guard let presenter else {
                    let appError = AppError.adsConsent(underlying: "missing_presenter")
                    self.logger.error("No presenter for consent form", error: appError)
                    self.finishRequest(with: .failure(appError), completion: completion)
                    return
                }

                form.present(from: presenter) { [weak self] dismissError in
                    guard let self else { return }

                    if let dismissError {
                        let appError = AppError.adsConsent(underlying: dismissError.localizedDescription)
                        self.logger.error("Consent form dismissed with error", error: appError)
                        self.finishRequest(with: .failure(appError), completion: completion)
                        return
                    }

                    let outcome = self.outcome(for: self.consentInformation.consentStatus)
                    self.finishRequest(with: .success(outcome), completion: completion)
                }
            }
        }
    }

    private func outcome(for status: UMPConsentStatus) -> AdConsentOutcome {
        switch status {
        case .obtained:
            return AdConsentOutcome(status: .obtained, personalization: .personalized)
        case .required:
            return AdConsentOutcome(status: .required, personalization: .nonPersonalized)
        case .notRequired:
            return AdConsentOutcome(status: .notRequired, personalization: .personalized)
        case .unknown:
            fallthrough
        @unknown default:
            return AdConsentOutcome(status: .unknown, personalization: .nonPersonalized)
        }
    }

    private func finishRequest(with result: Result<AdConsentOutcome, AppError>, completion: @escaping (Result<AdConsentOutcome, AppError>) -> Void) {
        DispatchQueue.main.async {
            self.isRequestInFlight = false

            switch result {
            case .success(let outcome):
                self.updateState(status: outcome.status, personalization: outcome.personalization, canServeAds: self.consentInformation.canRequestAds)
            case .failure(let error):
                self.updateState(status: .error(error), personalization: .nonPersonalized, canServeAds: self.consentInformation.canRequestAds)
            }

            completion(result)
        }
    }

    private func updateState(status: AdConsentStatus, personalization: AdPersonalization, canServeAds: Bool) {
        if consentStatus != status {
            consentStatus = status
        }
        if self.personalization != personalization {
            self.personalization = personalization
        }
        if self.canServeAds != canServeAds {
            self.canServeAds = canServeAds
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
