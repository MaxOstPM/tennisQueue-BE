import Foundation
import ReSwift

/// High-level tabs available in the application.
enum AppTab: Hashable {
    case solarSystem
    case news

    init(route: AppRoute) {
        switch route {
        case .solarSystem:
            self = .solarSystem
        case .news:
            self = .news
        }
    }

    var route: AppRoute {
        switch self {
        case .solarSystem:
            return .solarSystem
        case .news:
            return .news
        }
    }
}

/// Deep-linkable application routes.
enum AppRoute: Equatable {
    case solarSystem
    case news

    var tab: AppTab {
        switch self {
        case .solarSystem:
            return .solarSystem
        case .news:
            return .news
        }
    }

    init?(url: URL) {
        let pathComponent = url.pathComponents.last?.lowercased() ?? url.host?.lowercased()

        switch pathComponent {
        case "solarsystem", "solar-system", "home":
            self = .solarSystem
        case "news", "dispatch":
            self = .news
        default:
            return nil
        }
    }

    var url: URL? {
        var components = URLComponents()
        components.scheme = "solaratlas"
        components.host = "app"
        components.path = "/\(pathComponent)"
        return components.url
    }

    private var pathComponent: String {
        switch self {
        case .solarSystem:
            return "solar-system"
        case .news:
            return "news"
        }
    }
}

/// Global application state handled by the ReSwift store.
struct AppState: StateType, Equatable {
    var navigation: NavigationState = NavigationState()
    var solarSystem: SolarSystemState = SolarSystemState()
    var newsFeed: NewsFeedState = NewsFeedState()
    var update: UpdateState = UpdateState()
    var ads: AdState = AdState()
}
