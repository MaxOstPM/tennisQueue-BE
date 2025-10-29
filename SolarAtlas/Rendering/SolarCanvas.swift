import SwiftUI

/// Core canvas responsible for rendering the solar system visualization.
struct SolarCanvas: View {
    @EnvironmentObject var solarStore: SolarSystemStore

    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                drawSolarSystem(in: &context, size: size)
            }
            .contentShape(Rectangle())
            // Use a zero-distance drag gesture to capture tap locations for hit-testing.
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onEnded { value in
                        handleTap(at: value.location, canvasSize: geometry.size)
                    }
            )
        }
    }

    private func drawSolarSystem(in context: inout GraphicsContext, size: CGSize) {
        let state = solarStore.state
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let scale = renderScale(for: size)

        for body in solarSystemBodies where body.id != .atlas {
            if body.id != .sun && state.showOrbits {
                drawOrbit(for: body, in: &context, center: center, scale: scale)
            }

            let position = position(for: body, state: state, center: center, scale: scale)
            drawBody(body, at: position, in: &context)

            if state.showLabels {
                drawLabel(for: body, at: position, in: &context)
            }
        }

        if state.showAtlasPath {
            drawCometAtlas(in: &context, state: state, center: center, scale: scale)
        }
    }

    private func drawOrbit(for body: CelestialBody,
                           in context: inout GraphicsContext,
                           center: CGPoint,
                           scale: CGFloat) {
        let orbitRadius = body.orbitAU * scale
        guard orbitRadius > 0 else { return }

        let orbitRect = CGRect(
            x: center.x - orbitRadius,
            y: center.y - orbitRadius,
            width: orbitRadius * 2,
            height: orbitRadius * 2
        )

        let orbitPath = Path(ellipseIn: orbitRect)
        context.stroke(
            orbitPath,
            with: .color(.terminalCyan),
            style: StrokeStyle(lineWidth: 1.5, dash: [5, 5])
        )
    }

    private func drawBody(_ body: CelestialBody,
                          at position: CGPoint,
                          in context: inout GraphicsContext) {
        let radius = max(body.pixelRadius, 1)
        let bodyRect = CGRect(
            x: position.x - radius,
            y: position.y - radius,
            width: radius * 2,
            height: radius * 2
        )

        context.fill(Path(ellipseIn: bodyRect), with: .color(body.color))
    }

    private func drawLabel(for body: CelestialBody,
                           at position: CGPoint,
                           in context: inout GraphicsContext) {
        let labelPoint = CGPoint(
            x: position.x + body.labelOffset.width,
            y: position.y + body.labelOffset.height
        )

        let text = Text(body.displayName)
            .font(.system(size: 10, weight: .regular, design: .monospaced))
            .foregroundColor(.foregroundCyan)

        context.draw(text, at: labelPoint)
    }

    private func drawCometAtlas(in context: inout GraphicsContext,
                                state: SolarSystemState,
                                center: CGPoint,
                                scale: CGFloat) {
        let scaledPoints = cometAtlasPath.pathPoints().map { point -> CGPoint in
            CGPoint(
                x: center.x + point.x * scale,
                y: center.y + point.y * scale
            )
        }

        if scaledPoints.count > 1 {
            var trajectory = Path()
            trajectory.addLines(scaledPoints)
            context.stroke(
                trajectory,
                with: .color(.terminalGreen),
                style: StrokeStyle(lineWidth: 1.5, dash: [4, 3])
            )
        }

        let cometPoint = cometAtlasPath.position(at: state.time)
        let cometPosition = CGPoint(
            x: center.x + cometPoint.x * scale,
            y: center.y + cometPoint.y * scale
        )

        let atlasBody = solarSystemBodies.first { $0.id == .atlas }
        let cometRadius = max(atlasBody?.pixelRadius ?? 3, 3)
        let cometRect = CGRect(
            x: cometPosition.x - cometRadius,
            y: cometPosition.y - cometRadius,
            width: cometRadius * 2,
            height: cometRadius * 2
        )
        context.fill(Path(ellipseIn: cometRect), with: .color(.terminalGreen))

        if state.showLabels, let atlasBody {
            drawLabel(for: atlasBody, at: cometPosition, in: &context)
        }
    }

    private func handleTap(at location: CGPoint, canvasSize: CGSize) {
        let state = solarStore.state
        let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
        let scale = renderScale(for: canvasSize)

        for body in solarSystemBodies {
            let targetPoint: CGPoint
            let touchRadius = max(body.pixelRadius * 2, CGFloat(20))

            if body.id == .atlas {
                let cometPoint = cometAtlasPath.position(at: state.time)
                targetPoint = CGPoint(
                    x: center.x + cometPoint.x * scale,
                    y: center.y + cometPoint.y * scale
                )
            } else {
                targetPoint = position(for: body, state: state, center: center, scale: scale)
            }

            let dx = location.x - targetPoint.x
            let dy = location.y - targetPoint.y
            if (dx * dx + dy * dy).squareRoot() <= touchRadius {
                solarStore.dispatch(.select(body.id))
                return
            }
        }

        solarStore.dispatch(.select(nil))
    }

    private func position(for body: CelestialBody,
                          state: SolarSystemState,
                          center: CGPoint,
                          scale: CGFloat) -> CGPoint {
        if body.id == .sun {
            return center
        }

        let radius = body.orbitAU * scale
        guard radius > 0 else { return center }

        let angle = (state.time * 2 * .pi) / body.periodDays
        let x = center.x + CGFloat(cos(angle) * Double(radius))
        let y = center.y + CGFloat(sin(angle) * Double(radius))
        return CGPoint(x: x, y: y)
    }

    private func renderScale(for size: CGSize) -> CGFloat {
        let maxOrbit = solarSystemBodies.map(\.orbitAU).max() ?? CGFloat(1)
        let safeMaxOrbit = max(maxOrbit, 0.1)
        let reference = min(size.width, size.height) * 0.45
        guard reference > 0 else { return 1 }
        return reference / safeMaxOrbit
    }
}
