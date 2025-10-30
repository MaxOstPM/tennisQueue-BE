import SwiftUI

/// Color palette for Solar Atlas (CRT terminal theme)
extension Color {
    static let spaceBlack = Color(red: 10 / 255, green: 10 / 255, blue: 10 / 255)
    static let spaceBlackSubdued = Color(
        .sRGBLinear,
        red: 10 / 255,
        green: 10 / 255,
        blue: 10 / 255,
        opacity: 0.8
    )

    static let terminalAmberSurface = Color(
        .sRGBLinear,
        red: 245 / 255,
        green: 163 / 255,
        blue: 92 / 255,
        opacity: 0.96
    )

    static let terminalCyan = Color(red: 102 / 255, green: 229 / 255, blue: 229 / 255)
    static let terminalCyanDim = Color(
        .sRGBLinear,
        red: 102 / 255,
        green: 229 / 255,
        blue: 229 / 255,
        opacity: 0.45
    )
    static let terminalCyanGlow = Color(
        .sRGBLinear,
        red: 102 / 255,
        green: 229 / 255,
        blue: 229 / 255,
        opacity: 0.55
    )

    static let terminalAmber = Color(red: 245 / 255, green: 163 / 255, blue: 92 / 255)
    static let terminalGreen = Color(red: 51 / 255, green: 204 / 255, blue: 153 / 255)

    static let cardBackground = Color(red: 20 / 255, green: 31 / 255, blue: 31 / 255)
    static let cardBackgroundElevated = Color(
        .sRGBLinear,
        red: 20 / 255,
        green: 31 / 255,
        blue: 31 / 255,
        opacity: 0.9
    )

    static let foregroundCyan = Color(red: 163 / 255, green: 235 / 255, blue: 235 / 255)
    static let mutedText = Color(red: 115 / 255, green: 166 / 255, blue: 166 / 255)

    static let scanline = Color(.sRGBLinear, white: 1.0, opacity: 0.03)
    static let starfieldParticle = Color(
        .sRGBLinear,
        red: 163 / 255,
        green: 235 / 255,
        blue: 235 / 255,
        opacity: 0.35
    )
}
