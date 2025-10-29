import SwiftUI

/// Color palette for Solar Atlas (CRT terminal theme)
extension Color {
    static let spaceBlack    = Color(red: 10/255, green: 10/255, blue: 10/255)        // Background (deep space)
    static let terminalCyan  = Color(red: 102/255, green: 229/255, blue: 229/255)     // Primary neon cyan
    static let terminalAmber = Color(red: 245/255, green: 163/255, blue: 92/255)      // Secondary amber accent
    static let terminalGreen = Color(red: 51/255, green: 204/255, blue: 153/255)      // Phosphor green accent
    static let cardBackground = Color(red: 20/255, green: 31/255, blue: 31/255)       // Panel background teal
    static let foregroundCyan = Color(red: 163/255, green: 235/255, blue: 235/255)    // Bright cyan text
    static let mutedText     = Color(red: 115/255, green: 166/255, blue: 166/255)     // Muted medium cyan text
}
