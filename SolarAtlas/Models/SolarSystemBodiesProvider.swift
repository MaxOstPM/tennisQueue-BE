import SwiftUI

/// Provides commonly used solar system bodies for rendering and selection.
struct SolarSystemBodiesProvider {
    private let bodies: [CelestialBody]

    init() {
        bodies = [
            // Sun — central star (0 AU by definition, stationary for this visualization)
            CelestialBody(
                id: .sun,
                displayName: "Sun",
                color: .terminalAmber,
                pixelRadius: 6,
                orbitAU: 0.0,
                periodDays: 1.0,
                labelOffset: .zero
            ),

            // Mercury — 0.39 AU average orbital radius, 88-day orbital period
            CelestialBody(
                id: .mercury,
                displayName: "Mercury",
                color: .terminalCyan,
                pixelRadius: 2,
                orbitAU: 0.39,
                periodDays: 88,
                labelOffset: CGSize(width: 4, height: -4)
            ),

            // Venus — 0.72 AU, 225-day orbital period
            CelestialBody(
                id: .venus,
                displayName: "Venus",
                color: .terminalCyan,
                pixelRadius: 3,
                orbitAU: 0.72,
                periodDays: 225,
                labelOffset: CGSize(width: 6, height: -6)
            ),

            // Earth — 1.0 AU, 365-day orbital period
            CelestialBody(
                id: .earth,
                displayName: "Earth",
                color: .terminalCyan,
                pixelRadius: 3.5,
                orbitAU: 1.0,
                periodDays: 365,
                labelOffset: CGSize(width: -8, height: -8)
            ),

            // Mars — 1.52 AU, 687-day orbital period
            CelestialBody(
                id: .mars,
                displayName: "Mars",
                color: .terminalCyan,
                pixelRadius: 3,
                orbitAU: 1.52,
                periodDays: 687,
                labelOffset: CGSize(width: -10, height: 10)
            ),

            // Jupiter — 5.2 AU, 4,333-day orbital period (~11.9 Earth years)
            CelestialBody(
                id: .jupiter,
                displayName: "Jupiter",
                color: .terminalCyan,
                pixelRadius: 5,
                orbitAU: 5.2,
                periodDays: 4_333,
                labelOffset: CGSize(width: 12, height: -12)
            ),

            // Saturn — 9.5 AU, 10,759-day orbital period (~29.5 Earth years)
            CelestialBody(
                id: .saturn,
                displayName: "Saturn",
                color: .terminalCyan,
                pixelRadius: 5,
                orbitAU: 9.5,
                periodDays: 10_759,
                labelOffset: CGSize(width: -14, height: 14)
            ),

            // Uranus — 19.8 AU, 30,687-day orbital period (~84 Earth years)
            CelestialBody(
                id: .uranus,
                displayName: "Uranus",
                color: .terminalCyan,
                pixelRadius: 4,
                orbitAU: 19.8,
                periodDays: 30_687,
                labelOffset: CGSize(width: 16, height: 0)
            ),

            // Neptune — 30 AU, 60,190-day orbital period (~165 Earth years)
            CelestialBody(
                id: .neptune,
                displayName: "Neptune",
                color: .terminalCyan,
                pixelRadius: 4,
                orbitAU: 30.0,
                periodDays: 60_190,
                labelOffset: CGSize(width: -18, height: 0)
            ),

            // Comet 3I/ATLAS — interstellar visitor, rendered with its own trajectory
            CelestialBody(
                id: .atlas,
                displayName: "Comet ATLAS",
                color: .terminalGreen,
                pixelRadius: 2.5,
                orbitAU: 0.0,
                periodDays: 1.0,
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
        bodies.first { $0.id == id }
    }
}
