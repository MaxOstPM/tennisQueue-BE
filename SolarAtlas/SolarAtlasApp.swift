import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseRemoteConfig
import GoogleMobileAds

@main
struct SolarAtlasApp: App {
    init() {
        FirebaseApp.configure()
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }

    var body: some Scene {
        WindowGroup {
            AppTabView()
        }
    }
}

struct AppTabView: View {
    var body: some View {
        Text("SolarAtlas Root View")
    }
}
