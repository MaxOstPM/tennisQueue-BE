import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Root tab view containing the Solar System and News Feed tabs, with global overlay for update prompts.
struct AppTabView: View {
    @EnvironmentObject var store: AppStore

    init() {
#if canImport(UIKit)
        // Customize UITabBar appearance for a consistent look (no blur, dark background)
        let tabBarAppearance = UITabBar.appearance()
        tabBarAppearance.isTranslucent = false

        if #available(iOS 15, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Color.spaceBlack)
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.terminalCyan)
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor(Color.terminalCyan)
            ]
            tabBarAppearance.standardAppearance = appearance
            tabBarAppearance.scrollEdgeAppearance = appearance
        } else {
            tabBarAppearance.barTintColor = UIColor(Color.spaceBlack)
            tabBarAppearance.backgroundColor = UIColor(Color.spaceBlack)
            tabBarAppearance.tintColor = UIColor(Color.terminalCyan)
        }
#endif
    }

    var body: some View {
        ZStack {
            Color.spaceBlack.ignoresSafeArea()

            // Main TabView with two tabs
            TabView(selection: Binding(
                get: { store.state.navigation.activeTab },
                set: { store.dispatch(.navigation(.setTab($0))) }
            )) {
                SolarSystemView()
                    .tabItem {
                        Image(systemName: "globe")
                        Text(NSLocalizedString("tab.solarSystem.title", comment: "Tab title for the solar system screen"))
                    }
                    .tag(AppTab.solarSystem)

                NewsFeedView()
                    .tabItem {
                        Image(systemName: "newspaper")
                        Text(NSLocalizedString("tab.news.title", comment: "Tab title for the news feed"))
                    }
                    .tag(AppTab.news)
            }
            .accentColor(Color.terminalCyan)
            .onOpenURL { url in
                guard let route = AppRoute(url: url) else { return }
                store.dispatch(.navigation(.openRoute(route)))
            }

            // Overlay the forced-update prompt if an update is required
            if store.state.update.isUpdateRequired {
                UpdatePromptView()
                    .zIndex(1)  // ensure it stays on top
                    .interactiveDismissDisabled(true)
            }
        }
    }
}

// The AppTabView coordinates tab navigation and shows UpdatePromptView when needed.
// Tab bar icons have a retro neon style (cyan tint). Tab switching is not animated (default behavior).
