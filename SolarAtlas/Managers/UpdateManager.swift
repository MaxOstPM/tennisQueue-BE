import Foundation
import FirebaseRemoteConfig

/// Handles the forced-update logic using Firebase Remote Config.
///
/// Call this from application launch (see `SolarAtlasApp.init`) so the
/// `UpdateStore` reflects whether the current build must be upgraded before
/// the UI appears. The UI layer observes `UpdateState.isUpdateRequired` and
/// presents a prompt when necessary.
struct UpdateManager {
    /// Fetch the remote configuration and update the supplied store with the
    /// latest forced-update requirement.
    static func checkForUpdate(store: UpdateStore) {
        let remoteConfig = RemoteConfig.remoteConfig()

        // Configure a short fetch interval so the check happens on every app launch.
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings

        remoteConfig.fetchAndActivate { _, error in
            let currentVersion = Self.currentAppVersion()
            var evaluatedRemote = false
            var requiresUpdate = false
            let localMinimumVersion = Self.normalizedVersion(
                Bundle.main.object(forInfoDictionaryKey: "MinimumVersion") as? String
            )

            if error == nil {
                // Attempt to use the remote minimum version first.
                if let remoteMinimum = Self.normalizedVersion(remoteConfig["minimum_version"].stringValue) {
                    evaluatedRemote = true
                    if Self.isVersion(currentVersion, olderThan: remoteMinimum) {
                        requiresUpdate = true
                    }
                }
            } else {
                // Log the remote config error for debugging purposes.
                if let error = error {
                    NSLog("Remote Config fetch failed: %@", error.localizedDescription)
                }
            }

            // When the remote fetch failed or didn't yield a usable value,
            // fall back to a locally defined minimum version bundled with the app.
            if !evaluatedRemote,
               let localMinimum = localMinimumVersion {
                requiresUpdate = Self.isVersion(currentVersion, olderThan: localMinimum)
            }

            // Default to `false` when no data is available to avoid locking users out.
            if !evaluatedRemote,
               localMinimumVersion == nil {
                requiresUpdate = false
            }

            store.dispatch(.requireUpdate(requiresUpdate))
        }
    }

    private static func currentAppVersion() -> String {
        (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "0"
    }

    private static func normalizedVersion(_ version: String?) -> String? {
        guard let version = version?.trimmingCharacters(in: .whitespacesAndNewlines), !version.isEmpty else {
            return nil
        }
        return version
    }

    private static func isVersion(_ current: String, olderThan required: String) -> Bool {
        current.compare(required, options: .numeric) == .orderedAscending
    }
}
