import Foundation

/// Typed error that normalizes the failure domains surfaced across services and middleware.
enum AppError: Error, Equatable {
    case network(underlying: String?)
    case firestoreDecoding(underlying: String?)
    case remoteConfig(underlying: String?)
    case adsNoFill
    case adsConsent(underlying: String?)
    case adsPresentation(underlying: String?)
    case unknown(underlying: String?)

    /// Human readable string surfaced to end users.
    var localizedDescription: String {
        switch self {
        case .network:
            return String(localized: "error.general.network", comment: "Shown when any networking call fails")
        case .firestoreDecoding:
            return String(localized: "error.firestore.decode", comment: "Shown when Firestore data cannot be decoded")
        case .remoteConfig:
            return String(localized: "error.remoteConfig.fetch", comment: "Shown when Remote Config fails to fetch")
        case .adsNoFill:
            return String(localized: "error.ads.noFill", comment: "Shown when the ad server returns no fill")
        case .adsConsent:
            return String(localized: "error.ads.consent", comment: "Shown when ad consent flow cannot be completed")
        case .adsPresentation:
            return String(localized: "error.ads.presentation", comment: "Shown when an ad fails to present")
        case .unknown:
            return String(localized: "error.general.unknown", comment: "Fallback message for uncategorized errors")
        }
    }

    /// Technical metadata included with logs.
    var metadata: [String: String] {
        switch self {
        case .network(let underlying):
            return Self.baseMetadata(domain: "network", underlying: underlying)
        case .firestoreDecoding(let underlying):
            return Self.baseMetadata(domain: "firestore", underlying: underlying)
        case .remoteConfig(let underlying):
            return Self.baseMetadata(domain: "remoteConfig", underlying: underlying)
        case .adsNoFill:
            return Self.baseMetadata(domain: "ads", underlying: "no_fill")
        case .adsConsent(let underlying):
            return Self.baseMetadata(domain: "adsConsent", underlying: underlying)
        case .adsPresentation(let underlying):
            return Self.baseMetadata(domain: "adsPresentation", underlying: underlying)
        case .unknown(let underlying):
            return Self.baseMetadata(domain: "unknown", underlying: underlying)
        }
    }

    private static func baseMetadata(domain: String, underlying: String?) -> [String: String] {
        var values = ["domain": domain]
        if let underlying, !underlying.isEmpty {
            values["underlying"] = underlying
        }
        return values
    }
}
