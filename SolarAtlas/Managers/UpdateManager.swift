import Foundation
import FirebaseRemoteConfig

/// Coordinates forced-update checks via Firebase Remote Config.
enum UpdateManager {
    /// Fetches the latest remote configuration and updates the supplied store.
    static func checkForUpdate(updateStore: UpdateStore) {
        let remoteConfig = RemoteConfig.remoteConfig()
        remoteConfig.fetchAndActivate { _, error in
            guard error == nil else { return }
            let requiresUpdate = remoteConfig.configValue(forKey: "force_update_required").boolValue
            updateStore.dispatch(.requireUpdate(requiresUpdate))
        }
    }
}
