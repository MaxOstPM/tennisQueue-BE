import Foundation
import SwiftUI
import FirebaseFirestoreSwift

/// Unique identifiers for each celestial body rendered in the solar system view.
enum BodyID: String, CaseIterable, Equatable, Codable {
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
struct CelestialBody: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    let displayName: String
    let colorHex: String
    let pixelRadius: Double
    let orbitAU: Double
    let periodDays: Double
    let initialAngle: Double
    private let labelOffsetX: Double
    private let labelOffsetY: Double

    enum CodingKeys: String, CodingKey {
        case displayName
        case colorHex
        case pixelRadius
        case orbitAU
        case periodDays
        case initialAngle
        case labelOffsetX
        case labelOffsetY
    }

    init(id: String? = nil,
         displayName: String,
         colorHex: String,
         pixelRadius: Double,
         orbitAU: Double,
         periodDays: Double,
         initialAngle: Double,
         labelOffset: CGSize = .zero) {
        self._id = DocumentID(wrappedValue: id)
        self.displayName = displayName
        self.colorHex = colorHex
        self.pixelRadius = pixelRadius
        self.orbitAU = orbitAU
        self.periodDays = periodDays
        self.initialAngle = initialAngle
        self.labelOffsetX = Double(labelOffset.width)
        self.labelOffsetY = Double(labelOffset.height)
    }

    init(id: BodyID,
         displayName: String,
         colorHex: String,
         pixelRadius: Double,
         orbitAU: Double,
         periodDays: Double,
         initialAngle: Double,
         labelOffset: CGSize = .zero) {
        self.init(id: id.rawValue,
                  displayName: displayName,
                  colorHex: colorHex,
                  pixelRadius: pixelRadius,
                  orbitAU: orbitAU,
                  periodDays: periodDays,
                  initialAngle: initialAngle,
                  labelOffset: labelOffset)
    }
}

extension CelestialBody {
    /// Convenience accessor that maps the stored identifier to the strongly typed BodyID enum.
    var bodyID: BodyID? {
        guard let id else { return nil }
        return BodyID(rawValue: id)
    }

    /// Human friendly color value resolved from the stored hexadecimal string.
    var color: Color {
        Color(hex: colorHex) ?? .white
    }

    /// Pixel radius converted to Core Graphics' CGFloat for drawing operations.
    var radiusPoints: CGFloat {
        CGFloat(pixelRadius)
    }

    /// Orbit distance converted to Core Graphics' CGFloat for drawing operations.
    var orbitPoints: CGFloat {
        CGFloat(orbitAU)
    }

    /// Label offset expressed as a CGSize for layout convenience.
    var labelOffset: CGSize {
        CGSize(width: labelOffsetX, height: labelOffsetY)
    }
}

private extension Color {
    init?(hex: String) {
        let hexString = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        guard Scanner(string: hexString).scanHexInt64(&int) else { return nil }

        let a, r, g, b: UInt64
        switch hexString.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255,
                            (int >> 8) * 17,
                            (int >> 4 & 0xF) * 17,
                            (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255,
                            int >> 16,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24,
                            int >> 16 & 0xFF,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        default:
            return nil
        }

        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}
