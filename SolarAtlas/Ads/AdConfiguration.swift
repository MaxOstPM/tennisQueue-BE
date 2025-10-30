import Foundation

enum AdConfiguration {
    static var bannerAdUnitID: String {
        #if DEBUG
        return "ca-app-pub-3940256099942544/2934735716"
        #else
        if let value = Bundle.main.object(forInfoDictionaryKey: "GADBannerAdUnitID") as? String, !value.isEmpty {
            return value
        }
        return "ca-app-pub-3940256099942544/2934735716"
        #endif
    }

    static var interstitialAdUnitID: String {
        #if DEBUG
        return "ca-app-pub-3940256099942544/4411468910"
        #else
        if let value = Bundle.main.object(forInfoDictionaryKey: "GADInterstitialAdUnitID") as? String, !value.isEmpty {
            return value
        }
        return "ca-app-pub-3940256099942544/4411468910"
        #endif
    }
}
