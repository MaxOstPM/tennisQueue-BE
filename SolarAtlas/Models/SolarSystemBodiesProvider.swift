import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

/// Provides commonly used solar system bodies for rendering and selection.
struct SolarSystemBodiesProvider {
    private static let logger = AppLogger.category(.firestore)

    /// NASA-referenced orbital defaults used whenever remote loading fails.
    static let defaultBodies: [CelestialBody] = [
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

        // Mercury — 0.387 AU average orbital radius, 88-day orbital period
        CelestialBody(
            id: .mercury,
            displayName: String(localized: "body.name.mercury", comment: "Display name for Mercury"),
            colorHex: "#66E5E5",
            pixelRadius: 2,
            orbitAU: 0.387,
            periodDays: 88,
            initialAngle: 0.2,
            labelOffset: CGSize(width: 4, height: -4)
        ),

        // Venus — 0.724 AU, 225-day orbital period
        CelestialBody(
            id: .venus,
            displayName: String(localized: "body.name.venus", comment: "Display name for Venus"),
            colorHex: "#66E5E5",
            pixelRadius: 3,
            orbitAU: 0.724,
            periodDays: 225,
            initialAngle: 0.5,
            labelOffset: CGSize(width: 6, height: -6)
        ),

        // Earth — 1.0 AU, 365.25-day orbital period
        CelestialBody(
            id: .earth,
            displayName: String(localized: "body.name.earth", comment: "Display name for Earth"),
            colorHex: "#66E5E5",
            pixelRadius: 3.5,
            orbitAU: 1.0,
            periodDays: 365.25,
            initialAngle: 0,
            labelOffset: CGSize(width: -8, height: -8)
        ),

        // Mars — 1.524 AU, 687-day orbital period
        CelestialBody(
            id: .mars,
            displayName: String(localized: "body.name.mars", comment: "Display name for Mars"),
            colorHex: "#66E5E5",
            pixelRadius: 3,
            orbitAU: 1.524,
            periodDays: 687,
            initialAngle: 0.3,
            labelOffset: CGSize(width: -10, height: 10)
        ),

        // Jupiter — 5.205 AU, 4,333-day orbital period (~11.9 Earth years)
        CelestialBody(
            id: .jupiter,
            displayName: String(localized: "body.name.jupiter", comment: "Display name for Jupiter"),
            colorHex: "#66E5E5",
            pixelRadius: 5,
            orbitAU: 5.205,
            periodDays: 4_333,
            initialAngle: 0.8,
            labelOffset: CGSize(width: 12, height: -12)
        ),

        // Saturn — 9.54 AU, 10,759-day orbital period (~29.5 Earth years)
        CelestialBody(
            id: .saturn,
            displayName: String(localized: "body.name.saturn", comment: "Display name for Saturn"),
            colorHex: "#66E5E5",
            pixelRadius: 5,
            orbitAU: 9.54,
            periodDays: 10_759,
            initialAngle: 1.1,
            labelOffset: CGSize(width: -14, height: 14)
        ),

        // Uranus — 19.2 AU, 30,687-day orbital period (~84 Earth years)
        CelestialBody(
            id: .uranus,
            displayName: String(localized: "body.name.uranus", comment: "Display name for Uranus"),
            colorHex: "#66E5E5",
            pixelRadius: 4,
            orbitAU: 19.2,
            periodDays: 30_687,
            initialAngle: 1.4,
            labelOffset: CGSize(width: 16, height: 0)
        ),

        // Neptune — 30.1 AU, 60,190-day orbital period (~165 Earth years)
        CelestialBody(
            id: .neptune,
            displayName: String(localized: "body.name.neptune", comment: "Display name for Neptune"),
            colorHex: "#66E5E5",
            pixelRadius: 4,
            orbitAU: 30.1,
            periodDays: 60_190,
            initialAngle: 1.7,
            labelOffset: CGSize(width: -18, height: 0)
        ),

        // Comet 3I/ATLAS — interstellar visitor, rendered with its own trajectory (placeholder values)
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

    private let bodies: [CelestialBody]

    init(bodies: [CelestialBody] = SolarSystemBodiesProvider.defaultBodies) {
        self.bodies = bodies
    }

    /// Returns every known celestial body in the provider.
    var allBodies: [CelestialBody] {
        bodies
    }

    /// Fetches a specific celestial body by identifier.
    func body(for id: BodyID) -> CelestialBody? {
        bodies.first { $0.bodyID == id }
    }

    /// Loads celestial bodies from Firestore.
    static func loadBodiesFromFirebase() async -> [CelestialBody]? {
        do {
            let snapshot = try await Firestore.firestore()
                .collection("celestialBodies")
                .getDocuments()

            var fetchedBodies: [CelestialBody] = []
            fetchedBodies.reserveCapacity(snapshot.documents.count)

            var invalidDocuments: [String] = []

            for document in snapshot.documents {
                do {
                    let body = try document.data(as: CelestialBody.self)
                    fetchedBodies.append(body)
                } catch {
                    let decodingError = AppError.firestoreDecoding(underlying: error.localizedDescription)
                    invalidDocuments.append(document.documentID)
                    logger.error("Failed to decode celestial body",
                                 metadata: ["documentID": document.documentID],
                                 error: decodingError)
                    continue
                }
            }

            if !invalidDocuments.isEmpty {
                logger.warning("Skipped invalid celestial body documents",
                                metadata: ["documentIDs": invalidDocuments.joined(separator: ",")])
            }

            return fetchedBodies
        } catch {
            let fetchError = AppError.network(underlying: error.localizedDescription)
            logger.error("Failed to fetch celestial bodies", error: fetchError)
            return nil
        }
    }

    /// Attempts to load celestial bodies from Firestore, falling back to defaults if validation fails.
    static func loadBodiesWithFallback() async -> [CelestialBody] {
        guard let fetchedBodies = await loadBodiesFromFirebase() else {
            return defaultBodies
        }

        var bodiesByID: [BodyID: CelestialBody] = [:]
        for body in fetchedBodies {
            guard let id = body.bodyID else { continue }
            if bodiesByID[id] != nil {
                logger.warning("Duplicate celestial body detected", metadata: ["bodyID": id.rawValue])
            }
            bodiesByID[id] = body
        }

        guard bodiesByID.count == BodyID.allCases.count else {
            logger.warning("Celestial body payload missing entries",
                           metadata: ["fetchedCount": "\(fetchedBodies.count)"])
            return defaultBodies
        }

        let orderedBodies = BodyID.allCases.compactMap { bodiesByID[$0] }
        guard orderedBodies.count == BodyID.allCases.count else {
            logger.warning("Celestial body payload failed ordering validation")
            return defaultBodies
        }

        return orderedBodies
    }
}
