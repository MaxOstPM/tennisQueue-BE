import ReSwift

/// Root action enum that encapsulates every action flowing through the app store.
enum AppAction: Action {
    case solarSystem(SolarSystemAction)
    case news(NewsFeedAction)
    case navigation(NavigationAction)
    case update(UpdateAction)
    case ads(AdAction)

    case fetchNewsRequested
    case checkForUpdate
    case startAdTimer
    case showInterstitialIfReady
    case requestAdConsent
    case appDidBecomeActive
}
