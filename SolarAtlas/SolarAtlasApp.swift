import SwiftUI
import FirebaseCore
import GoogleMobileAds

@main
struct SolarAtlasApp: App {
    @StateObject private var appStore: AppStore
    @Environment(\.scenePhase) private var scenePhase

    init() {
        FirebaseApp.configure()
        GADMobileAds.sharedInstance().start(completionHandler: nil)

        let newsService = FirestoreNewsService()
        let updateService = RemoteConfigUpdateService()
        let consentManager = ConsentManager.shared
        let adManager = AdManager(interstitialAdUnitID: AdConfiguration.interstitialAdUnitID, consentManager: consentManager)
        let store = AppStore(
            newsService: newsService,
            updateService: updateService,
            adManager: adManager,
            consentManager: consentManager
        )

        _appStore = StateObject(wrappedValue: store)
    }

    var body: some Scene {
        WindowGroup {
            AppTabView()
                .environmentObject(appStore)
                .task {
                    appStore.dispatch(.checkForUpdate)
                    appStore.dispatch(.requestAdConsent)
                    appStore.dispatch(.fetchNewsRequested)
                }
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .active {
                        appStore.dispatch(.appDidBecomeActive)
                    }
                }
        }
    }
}
