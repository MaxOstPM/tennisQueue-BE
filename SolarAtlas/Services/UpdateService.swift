import FirebaseRemoteConfig
import Foundation

struct UpdateRequirement {
    let requiresUpdate: Bool
    let minimumVersion: String
    let currentVersion: String
}

protocol UpdateServiceType {
    func checkForRequiredUpdate(completion: @escaping (Result<UpdateRequirement, AppError>) -> Void)
    func fallbackRequirement() -> UpdateRequirement
}

struct RemoteConfigUpdateService: UpdateServiceType {
    private let remoteConfig: RemoteConfig
    private let bundle: Bundle
    private let logger = AppLogger.category(.remoteConfig)

    init(remoteConfig: RemoteConfig = RemoteConfig.remoteConfig(), bundle: Bundle = .main) {
        self.remoteConfig = remoteConfig
        self.bundle = bundle
    }

    func checkForRequiredUpdate(completion: @escaping (Result<UpdateRequirement, AppError>) -> Void) {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings

        remoteConfig.fetchAndActivate { _, error in
            DispatchQueue.global(qos: .userInitiated).async {
                let currentVersion = Self.currentAppVersion(from: bundle)
                let localMinimum = Self.normalizedVersion(bundle.object(forInfoDictionaryKey: "MinimumVersion") as? String)
                let remoteMinimum = Self.normalizedVersion(remoteConfig["minimum_version"].stringValue)

                if let error {
                    let appError = AppError.remoteConfig(underlying: error.localizedDescription)
                    logger.error("Remote Config fetch failed", error: appError)
                    completion(.failure(appError))
                    return
                }

                if let remoteMinimum {
                    completion(.success(Self.makeRequirement(currentVersion: currentVersion, minimumVersion: remoteMinimum)))
                } else if let localMinimum {
                    completion(.success(Self.makeRequirement(currentVersion: currentVersion, minimumVersion: localMinimum)))
                } else {
                    completion(.success(Self.makeRequirement(currentVersion: currentVersion, minimumVersion: currentVersion)))
                }
            }
        }
    }

    func fallbackRequirement() -> UpdateRequirement {
        let currentVersion = Self.currentAppVersion(from: bundle)
        let localMinimum = Self.normalizedVersion(bundle.object(forInfoDictionaryKey: "MinimumVersion") as? String)
        let minimum = localMinimum ?? currentVersion
        return Self.makeRequirement(currentVersion: currentVersion, minimumVersion: minimum)
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

    private static func makeRequirement(currentVersion: String, minimumVersion: String) -> UpdateRequirement {
        UpdateRequirement(
            requiresUpdate: isVersion(currentVersion, olderThan: minimumVersion),
            minimumVersion: minimumVersion,
            currentVersion: currentVersion
        )
    }
}
