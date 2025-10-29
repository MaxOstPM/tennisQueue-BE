import SwiftUI

/// Unique identifiers for each celestial body rendered in the solar system view.
enum BodyID: String, CaseIterable, Equatable {
    case sun
    case mercury
    case venus
    case earth
    case mars
    case jupiter
    case saturn
    case uranus
    case neptune
    case atlas
}

/// Model representing a celestial body (planet or significant object).
struct CelestialBody: Identifiable {
    let id: BodyID           // Unique identifier (from BodyID enum)
    let displayName: String  // Human-readable name
    let color: Color         // Display color (neon glow)
    let pixelRadius: CGFloat // Radius for drawing the body (in points)
    let orbitAU: CGFloat     // Orbit radius relative to Earth (1.0 = 1 AU)
    let periodDays: Double   // Orbital period in Earth days
    let labelOffset: CGSize  // Offset for label text positioning (to avoid overlap)
}

extension CelestialBody {
    /// Convenience accessor to retrieve the default set of solar system bodies.
    static var solarSystemBodies: [CelestialBody] {
        SolarSystemBodiesProvider().allBodies
    }
}
