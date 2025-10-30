import Foundation

enum AdConsentStatus: Equatable {
    case unknown
    case requesting
    case obtained
    case notRequired
    case required
    case error(String)
}

enum AdPersonalization: Equatable {
    case unknown
    case personalized
    case nonPersonalized
}

struct AdConsentOutcome: Equatable {
    let status: AdConsentStatus
    let personalization: AdPersonalization
}
