import SwiftUI
import FirebaseCore
import GoogleMobileAds

@main
struct SolarAtlasApp: App {
    @StateObject private var solarSystemStore: SolarSystemStore
    @StateObject private var newsFeedStore: NewsFeedStore
    @StateObject private var navigationStore: NavigationStore
    @StateObject private var updateStore: UpdateStore
    @StateObject private var adStore: AdStore

    init() {
        let calendar = Calendar(identifier: .gregorian)
        let now = Date()
        let startDate = calendar.date(byAdding: .day, value: -365, to: now) ?? now
        let endDate = calendar.date(byAdding: .day, value: 365, to: now) ?? now

        let solarInitialState = SolarSystemState(dateRange: startDate...endDate)
        let solarSystemStore = SolarSystemStore(initial: solarInitialState)
        let newsFeedStore = NewsFeedStore(initial: NewsFeedState())
        let navigationStore = NavigationStore(initial: NavigationState(activeTab: .solarSystem))
        let updateStore = UpdateStore(initial: UpdateState())
        let adStore = AdStore(initial: AdState())

        _solarSystemStore = StateObject(wrappedValue: solarSystemStore)
        _newsFeedStore = StateObject(wrappedValue: newsFeedStore)
        _navigationStore = StateObject(wrappedValue: navigationStore)
        _updateStore = StateObject(wrappedValue: updateStore)
        _adStore = StateObject(wrappedValue: adStore)

        FirebaseApp.configure()
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        UpdateManager.checkForUpdate(updateStore: updateStore)
    }

    var body: some Scene {
        WindowGroup {
            AppTabView()
                .environmentObject(solarSystemStore)
                .environmentObject(newsFeedStore)
                .environmentObject(navigationStore)
                .environmentObject(updateStore)
                .environmentObject(adStore)
        }
    }
}

struct AppTabView: View {
    var body: some View {
        SolarSystemView()
    }
}
