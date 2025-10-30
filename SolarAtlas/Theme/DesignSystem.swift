import SwiftUI

/// Centralized design tokens for typography and reusable modifiers.
extension Font {
    enum ds {
        static let display = Font.system(size: 48, weight: .heavy, design: .monospaced)
        static let titleL = Font.system(size: 24, weight: .heavy, design: .monospaced)
        static let titleM = Font.system(size: 20, weight: .semibold, design: .monospaced)
        static let titleS = Font.system(size: 16, weight: .semibold, design: .monospaced)

        static let body = Font.system(size: 14, weight: .regular, design: .monospaced)
        static let bodyEmphasis = Font.system(size: 14, weight: .semibold, design: .monospaced)

        static let label = Font.system(size: 13, weight: .medium, design: .monospaced)
        static let labelEmphasis = Font.system(size: 13, weight: .semibold, design: .monospaced)

        static let caption = Font.system(size: 12, weight: .regular, design: .monospaced)
        static let captionEmphasis = Font.system(size: 12, weight: .semibold, design: .monospaced)
        static let micro = Font.system(size: 10, weight: .regular, design: .monospaced)

        static let icon = Font.system(size: 20, weight: .semibold, design: .monospaced)
        static let iconSmall = Font.system(size: 14, weight: .semibold, design: .monospaced)
        static let iconXL = Font.system(size: 48, weight: .regular, design: .monospaced)
    }
}
