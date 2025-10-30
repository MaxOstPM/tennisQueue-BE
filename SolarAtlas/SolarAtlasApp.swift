import SwiftUI
import FirebaseCore
import GoogleMobileAds

@main
struct SolarAtlasApp: App {
    @StateObject private var appStore: AppStore

    init() {
        FirebaseApp.configure()
        GADMobileAds.sharedInstance().start(completionHandler: nil)

        let newsService = FirestoreNewsService()
        let updateService = RemoteConfigUpdateService()
        let adManager = AdManager(adUnitID: "ca-app-pub-3940256099942544/4411468910")
        let store = AppStore(
            newsService: newsService,
            updateService: updateService,
            adManager: adManager
        )

        _appStore = StateObject(wrappedValue: store)

        store.dispatch(.checkForUpdate)
        store.dispatch(.startAdTimer)
        store.dispatch(.fetchNewsRequested)
    }

    var body: some Scene {
        WindowGroup {
            AppTabView()
                .environmentObject(appStore)
        }
    }
}
