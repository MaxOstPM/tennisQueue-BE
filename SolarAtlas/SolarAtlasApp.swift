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
    @EnvironmentObject private var navigationStore: NavigationStore

    private var selection: Binding<AppTab> {
        Binding(
            get: { navigationStore.state.activeTab },
            set: { navigationStore.dispatch(.setTab($0)) }
        )
    }

    var body: some View {
        TabView(selection: selection) {
            SolarSystemView()
                .tabItem {
                    Label(NSLocalizedString("Explore", comment: "Solar system tab title"), systemImage: "globe")
                }
                .tag(AppTab.solarSystem)

            ComingSoonView(title: NSLocalizedString("News Feed", comment: "News feed tab title"))
                .tabItem {
                    Label(NSLocalizedString("News", comment: "News tab label"), systemImage: "newspaper")
                }
                .tag(AppTab.newsFeed)

            ComingSoonView(title: NSLocalizedString("Updates", comment: "Updates tab title"))
                .tabItem {
                    Label(NSLocalizedString("Updates", comment: "Updates tab label"), systemImage: "clock.arrow.circlepath")
                }
                .tag(AppTab.updates)
        }
        .tint(.terminalCyan)
    }
}

private struct ComingSoonView: View {
    var title: String

    var body: some View {
        ZStack {
            Color.spaceBlack.ignoresSafeArea()
            Text(title.uppercased())
                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                .foregroundColor(.mutedText)
        }
    }
}
