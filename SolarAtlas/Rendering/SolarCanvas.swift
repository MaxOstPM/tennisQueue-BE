import SwiftUI

/// Core canvas responsible for rendering the solar system visualization.
struct SolarCanvas: View {
    @EnvironmentObject var store: AppStore
    @StateObject private var layoutCache = LayoutCache()

    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                drawSolarSystem(in: &context, size: size)
            }
            .drawingGroup()
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
        let state = solarSystem
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let scale = renderScale(for: size)
        let timeBucket = layoutCache.timeBucket(for: state.time)

        for body in solarSystemBodies where body.id != .atlas {
            if body.id != .sun && state.showOrbits {
                drawOrbit(for: body, in: &context, center: center, scale: scale)
            }

            let position = position(for: body,
                                    center: center,
                                    scale: scale,
                                    timeBucket: timeBucket)
            drawBody(body, at: position, in: &context)

            if state.showLabels {
                drawLabel(for: body, at: position, in: &context)
            }
        }

        if state.showAtlasPath {
            drawCometAtlas(in: &context,
                           state: state,
                           center: center,
                           scale: scale,
                           timeBucket: timeBucket)
        }
    }

    private func drawOrbit(for body: CelestialBody,
                           in context: inout GraphicsContext,
                           center: CGPoint,
                           scale: CGFloat) {
        guard let orbitPath = layoutCache.orbitPath(for: body, scale: scale, center: center) else { return }
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
            .font(Font.ds.micro)
            .foregroundColor(.foregroundCyan)

        context.draw(text, at: labelPoint)
    }

    private func drawCometAtlas(in context: inout GraphicsContext,
                                state: SolarSystemState,
                                center: CGPoint,
                                scale: CGFloat,
                                timeBucket: Int) {
        let scaledPoints = layoutCache.atlasTrajectory(scale: scale).map { point -> CGPoint in
            CGPoint(x: center.x + point.x, y: center.y + point.y)
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

        let cometOffset = layoutCache.atlasPosition(timeBucket: timeBucket, scale: scale)
        let cometPosition = CGPoint(
            x: center.x + cometOffset.x,
            y: center.y + cometOffset.y
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
        let state = solarSystem
        let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
        let scale = renderScale(for: canvasSize)
        let timeBucket = layoutCache.timeBucket(for: state.time)

        for body in solarSystemBodies {
            let targetPoint: CGPoint
            let touchRadius = max(body.pixelRadius * 2, CGFloat(20))

            if body.id == .atlas {
                let cometOffset = layoutCache.atlasPosition(timeBucket: timeBucket, scale: scale)
                targetPoint = CGPoint(
                    x: center.x + cometOffset.x,
                    y: center.y + cometOffset.y
                )
            } else {
                targetPoint = position(for: body,
                                       center: center,
                                       scale: scale,
                                       timeBucket: timeBucket)
            }

            let dx = location.x - targetPoint.x
            let dy = location.y - targetPoint.y
            if (dx * dx + dy * dy).squareRoot() <= touchRadius {
                store.dispatch(.solarSystem(.select(body.id)))
                return
            }
        }

        store.dispatch(.solarSystem(.select(nil)))
    }

    private func position(for body: CelestialBody,
                          center: CGPoint,
                          scale: CGFloat,
                          timeBucket: Int) -> CGPoint {
        if body.id == .sun {
            return center
        }

        let offset = layoutCache.relativePosition(for: body, timeBucket: timeBucket, scale: scale)
        return CGPoint(x: center.x + offset.x, y: center.y + offset.y)
    }

    private func renderScale(for size: CGSize) -> CGFloat {
        let maxOrbit = solarSystemBodies.map(\.orbitAU).max() ?? CGFloat(1)
        let safeMaxOrbit = max(maxOrbit, 0.1)
        let reference = min(size.width, size.height) * 0.45
        guard reference > 0 else { return 1 }
        return reference / safeMaxOrbit
    }

    private var solarSystem: SolarSystemState {
        store.state.solarSystem
    }
}

// MARK: - Layout cache

private final class LayoutCache: ObservableObject {
    private struct OrbitKey: Hashable {
        let radiusBucket: Int
    }

    private struct PositionKey: Hashable {
        let bodyID: BodyID
        let timeBucket: Int
        let scaleBucket: Int
    }

    private struct AtlasKey: Hashable {
        let scaleBucket: Int
    }

    private struct AtlasPositionKey: Hashable {
        let timeBucket: Int
        let scaleBucket: Int
    }

    private static let timeBucketCount = 240
    private static let scalePrecision: CGFloat = 0.5
    private static let radiusPrecision: CGFloat = 0.5

    private var orbitPaths: [OrbitKey: Path] = [:]
    private var relativePositions: [PositionKey: CGPoint] = [:]
    private var atlasTrajectories: [AtlasKey: [CGPoint]] = [:]
    private var atlasPositions: [AtlasPositionKey: CGPoint] = [:]

    func timeBucket(for time: Double) -> Int {
        let clamped = max(0, min(1, time))
        return Int((clamped * Double(Self.timeBucketCount)).rounded())
    }

    func orbitPath(for body: CelestialBody, scale: CGFloat, center: CGPoint) -> Path? {
        let radius = body.orbitAU * scale
        guard radius > 0 else { return nil }
        let key = OrbitKey(radiusBucket: bucket(for: radius, precision: Self.radiusPrecision))
        let basePath: Path
        if let cached = orbitPaths[key] {
            basePath = cached
        } else {
            var path = Path()
            let diameter = radius * 2
            let rect = CGRect(x: -radius, y: -radius, width: diameter, height: diameter)
            path.addEllipse(in: rect)
            orbitPaths[key] = path
            basePath = path
        }

        var transform = CGAffineTransform(translationX: center.x, y: center.y)
        return basePath.applying(transform)
    }

    func relativePosition(for body: CelestialBody, timeBucket: Int, scale: CGFloat) -> CGPoint {
        let key = PositionKey(
            bodyID: body.id,
            timeBucket: max(0, min(timeBucket, Self.timeBucketCount)),
            scaleBucket: bucket(for: scale, precision: Self.scalePrecision)
        )

        if let cached = relativePositions[key] {
            return cached
        }

        let quantizedTime = Double(key.timeBucket) / Double(Self.timeBucketCount)
        let radius = body.orbitAU * scale
        let angle = (quantizedTime * 2 * .pi) / body.periodDays
        let point = CGPoint(
            x: CGFloat(cos(angle)) * radius,
            y: CGFloat(sin(angle)) * radius
        )
        relativePositions[key] = point
        return point
    }

    func atlasTrajectory(scale: CGFloat) -> [CGPoint] {
        let key = AtlasKey(scaleBucket: bucket(for: scale, precision: Self.scalePrecision))
        if let cached = atlasTrajectories[key] {
            return cached
        }

        let points = cometAtlasPath.pathPoints().map { point -> CGPoint in
            CGPoint(x: point.x * scale, y: point.y * scale)
        }
        atlasTrajectories[key] = points
        return points
    }

    func atlasPosition(timeBucket: Int, scale: CGFloat) -> CGPoint {
        let key = AtlasPositionKey(
            timeBucket: max(0, min(timeBucket, Self.timeBucketCount)),
            scaleBucket: bucket(for: scale, precision: Self.scalePrecision)
        )

        if let cached = atlasPositions[key] {
            return cached
        }

        let quantizedTime = Double(key.timeBucket) / Double(Self.timeBucketCount)
        let rawPoint = cometAtlasPath.position(at: quantizedTime)
        let scaled = CGPoint(x: rawPoint.x * scale, y: rawPoint.y * scale)
        atlasPositions[key] = scaled
        return scaled
    }

    private func bucket(for value: CGFloat, precision: CGFloat) -> Int {
        guard precision > 0 else { return Int(value) }
        return Int((value / precision).rounded())
    }
}
