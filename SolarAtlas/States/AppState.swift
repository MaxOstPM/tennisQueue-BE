import Foundation

/// High-level tabs available in the application.
enum AppTab: Hashable {
    case solarSystem
    case newsFeed
}

/// Global application state used by `AppStore`.
struct AppState: Equatable {
    var activeTab: AppTab = .solarSystem
    var isUpdateRequired: Bool = false
}
