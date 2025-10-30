import SwiftUI

/// Provides commonly used solar system bodies for rendering and selection.
struct SolarSystemBodiesProvider {
    private let bodies: [CelestialBody]

    init() {
        bodies = [
            // Sun — central star (0 AU by definition, stationary for this visualization)
            CelestialBody(
                id: .sun,
                displayName: String(localized: "body.name.sun", comment: "Display name for the Sun"),
                colorHex: "#F5A35C",
                pixelRadius: 6,
                orbitAU: 0.0,
                periodDays: 1.0,
                initialAngle: 0,
                labelOffset: .zero
            ),

            // Mercury — 0.39 AU average orbital radius, 88-day orbital period
            CelestialBody(
                id: .mercury,
                displayName: String(localized: "body.name.mercury", comment: "Display name for Mercury"),
                colorHex: "#66E5E5",
                pixelRadius: 2,
                orbitAU: 0.39,
                periodDays: 88,
                initialAngle: 0.2,
                labelOffset: CGSize(width: 4, height: -4)
            ),

            // Venus — 0.72 AU, 225-day orbital period
            CelestialBody(
                id: .venus,
                displayName: String(localized: "body.name.venus", comment: "Display name for Venus"),
                colorHex: "#66E5E5",
                pixelRadius: 3,
                orbitAU: 0.72,
                periodDays: 225,
                initialAngle: 0.5,
                labelOffset: CGSize(width: 6, height: -6)
            ),

            // Earth — 1.0 AU, 365-day orbital period
            CelestialBody(
                id: .earth,
                displayName: String(localized: "body.name.earth", comment: "Display name for Earth"),
                colorHex: "#66E5E5",
                pixelRadius: 3.5,
                orbitAU: 1.0,
                periodDays: 365,
                initialAngle: 0,
                labelOffset: CGSize(width: -8, height: -8)
            ),

            // Mars — 1.52 AU, 687-day orbital period
            CelestialBody(
                id: .mars,
                displayName: String(localized: "body.name.mars", comment: "Display name for Mars"),
                colorHex: "#66E5E5",
                pixelRadius: 3,
                orbitAU: 1.52,
                periodDays: 687,
                initialAngle: 0.3,
                labelOffset: CGSize(width: -10, height: 10)
            ),

            // Jupiter — 5.2 AU, 4,333-day orbital period (~11.9 Earth years)
            CelestialBody(
                id: .jupiter,
                displayName: String(localized: "body.name.jupiter", comment: "Display name for Jupiter"),
                colorHex: "#66E5E5",
                pixelRadius: 5,
                orbitAU: 5.2,
                periodDays: 4_333,
                initialAngle: 0.8,
                labelOffset: CGSize(width: 12, height: -12)
            ),

            // Saturn — 9.5 AU, 10,759-day orbital period (~29.5 Earth years)
            CelestialBody(
                id: .saturn,
                displayName: String(localized: "body.name.saturn", comment: "Display name for Saturn"),
                colorHex: "#66E5E5",
                pixelRadius: 5,
                orbitAU: 9.5,
                periodDays: 10_759,
                initialAngle: 1.1,
                labelOffset: CGSize(width: -14, height: 14)
            ),

            // Uranus — 19.8 AU, 30,687-day orbital period (~84 Earth years)
            CelestialBody(
                id: .uranus,
                displayName: String(localized: "body.name.uranus", comment: "Display name for Uranus"),
                colorHex: "#66E5E5",
                pixelRadius: 4,
                orbitAU: 19.8,
                periodDays: 30_687,
                initialAngle: 1.4,
                labelOffset: CGSize(width: 16, height: 0)
            ),

            // Neptune — 30 AU, 60,190-day orbital period (~165 Earth years)
            CelestialBody(
                id: .neptune,
                displayName: String(localized: "body.name.neptune", comment: "Display name for Neptune"),
                colorHex: "#66E5E5",
                pixelRadius: 4,
                orbitAU: 30.0,
                periodDays: 60_190,
                initialAngle: 1.7,
                labelOffset: CGSize(width: -18, height: 0)
            ),

            // Comet 3I/ATLAS — interstellar visitor, rendered with its own trajectory
            CelestialBody(
                id: .atlas,
                displayName: String(localized: "body.name.atlas", comment: "Display name for comet ATLAS"),
                colorHex: "#33CC99",
                pixelRadius: 2.5,
                orbitAU: 0.0,
                periodDays: 1.0,
                initialAngle: 0,
                labelOffset: CGSize(width: 0, height: -10)
            )
        ]
    }

    /// Returns every known celestial body in the provider.
    var allBodies: [CelestialBody] {
        bodies
    }

    /// Fetches a specific celestial body by identifier.
    func body(for id: BodyID) -> CelestialBody? {
        bodies.first { $0.bodyID == id }
    }
}
