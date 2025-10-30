import FirebaseRemoteConfig
import Foundation

struct UpdateRequirement {
    let requiresUpdate: Bool
    let minimumVersion: String
    let currentVersion: String
}

protocol UpdateServiceType {
    func checkForRequiredUpdate(completion: @escaping (UpdateRequirement) -> Void)
}

struct RemoteConfigUpdateService: UpdateServiceType {
    private let remoteConfig: RemoteConfig
    private let bundle: Bundle

    init(remoteConfig: RemoteConfig = RemoteConfig.remoteConfig(), bundle: Bundle = .main) {
        self.remoteConfig = remoteConfig
        self.bundle = bundle
    }

    func checkForRequiredUpdate(completion: @escaping (UpdateRequirement) -> Void) {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings

        remoteConfig.fetchAndActivate { _, error in
            DispatchQueue.global(qos: .userInitiated).async {
                let currentVersion = Self.currentAppVersion(from: bundle)
                let localMinimumVersion = Self.normalizedVersion(bundle.object(forInfoDictionaryKey: "MinimumVersion") as? String)

                let remoteMinimum = Self.normalizedVersion(remoteConfig["minimum_version"].stringValue)

                let minimumVersion: String
                let requiresUpdate: Bool
                if let remoteMinimum = remoteMinimum, error == nil {
                    minimumVersion = remoteMinimum
                    requiresUpdate = Self.isVersion(currentVersion, olderThan: remoteMinimum)
                } else if let localMinimum = localMinimumVersion {
                    minimumVersion = localMinimum
                    requiresUpdate = Self.isVersion(currentVersion, olderThan: localMinimum)
                } else {
                    minimumVersion = currentVersion
                    requiresUpdate = false
                }

                completion(UpdateRequirement(
                    requiresUpdate: requiresUpdate,
                    minimumVersion: minimumVersion,
                    currentVersion: currentVersion
                ))
            }
        }
    }

    private static func currentAppVersion(from bundle: Bundle) -> String {
        (bundle.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "0"
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
