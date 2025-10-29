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
                get: { store.state.activeTab },
                set: { store.setActiveTab($0) }
            )) {
                SolarSystemView()
                    .tabItem {
                        Image(systemName: "globe")
                        Text(NSLocalizedString("Solar System", comment: "Tab title for solar system"))
                    }
                    .tag(AppTab.solarSystem)

                NewsFeedView()
                    .tabItem {
                        Image(systemName: "newspaper")
                        Text(NSLocalizedString("News", comment: "Tab title for news feed"))
                    }
                    .tag(AppTab.newsFeed)
            }
            .accentColor(Color.terminalCyan)

            // Overlay the forced-update prompt if an update is required
            if store.state.isUpdateRequired {
                UpdatePromptView()
                    .zIndex(1)  // ensure it stays on top
                    .interactiveDismissDisabled(true)
            }
        }
    }
}

// The AppTabView coordinates tab navigation and shows UpdatePromptView when needed.
// Tab bar icons have a retro neon style (cyan tint). Tab switching is not animated (default behavior).
