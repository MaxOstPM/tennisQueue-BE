import SwiftUI

/// Overlay view for CRT scanline effect (4 px spaced horizontal lines)
struct ScanlineOverlay: View {
    var body: some View {
        Canvas { context, size in
            // Draw horizontal lines across the view
            let lineSpacing: Double = 4.0
            var path = Path()
            var y: Double = 0
            while y < size.height {
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                y += lineSpacing
            }
            context.stroke(path, with: .color(Color.white.opacity(0.03)), lineWidth: 1)
        }
        .allowsHitTesting(false)
    }
}
