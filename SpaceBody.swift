import Foundation

public enum SpaceBody: String, CaseIterable, Identifiable, Hashable {
    case sun = "Sun"
    case mercury = "Mercury"
    case venus = "Venus"
    case earth = "Earth"
    case mars = "Mars"
    case jupiter = "Jupiter"
    case saturn = "Saturn"
    case uranus = "Uranus"
    case neptune = "Neptune"
    case atlas = "ATLAS"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .sun:
            return "Sun"
        case .mercury:
            return "Mercury"
        case .venus:
            return "Venus"
        case .earth:
            return "Earth"
        case .mars:
            return "Mars"
        case .jupiter:
            return "Jupiter"
        case .saturn:
            return "Saturn"
        case .uranus:
            return "Uranus"
        case .neptune:
            return "Neptune"
        case .atlas:
            return "ATLAS"
        }
    }

    public var description: String {
        switch self {
        case .sun:
            return "The Sun is a G-type main-sequence star that provides the energy sustaining life on Earth."
        case .mercury:
            return "Mercury is the smallest planet in our solar system and orbits the Sun in just 88 Earth days."
        case .venus:
            return "Venus has a dense atmosphere of carbon dioxide that traps heat, making it the hottest planet."
        case .earth:
            return "Earth is the only known planet to support life, with vast oceans and a protective atmosphere."
        case .mars:
            return "Mars is known as the Red Planet and hosts the largest volcano in the solar system, Olympus Mons."
        case .jupiter:
            return "Jupiter is the largest planet, famous for its Great Red Spot, a storm larger than Earth."
        case .saturn:
            return "Saturn is renowned for its stunning ring system composed of ice and rocky debris."
        case .uranus:
            return "Uranus rotates on its side, causing extreme seasonal variations over its 84-year orbit."
        case .neptune:
            return "Neptune features supersonic winds and a deep blue color due to methane in its atmosphere."
        case .atlas:
            return "ATLAS is the third interstellar object discovered in 2025, offering new insights into extrasolar visitors."
        }
    }
}
