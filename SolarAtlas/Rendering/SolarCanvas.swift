import SwiftUI

final class OrbitRenderCache: ObservableObject {
    @Published private var cachedPath = Path()
    private var cachedSize: CGSize = .zero
    private var cachedScale: CGFloat = 0
    private var cachedCenter: CGPoint = .zero
    private var cachedBodyCount: Int = 0
    private var cachedBodySignature: Int = 0
    private var showingOrbits = true

    var orbitsPath: Path { cachedPath }

    func rebuildIfNeeded(size: CGSize,
                         showOrbits: Bool,
                         scale: CGFloat,
                         center: CGPoint,
                         bodies: [CelestialBody]) {
        guard showOrbits else {
            if showingOrbits {
                cachedPath = Path()
                showingOrbits = false
                cachedCenter = .zero
                cachedSize = .zero
                cachedScale = 0
                cachedBodyCount = 0
                cachedBodySignature = 0
            }
            return
        }

        if !showingOrbits {
            showingOrbits = true
            cachedSize = .zero
            cachedCenter = .zero
        }

        var hasher = Hasher()
        bodies.forEach { body in
            hasher.combine(body.id ?? body.displayName)
            hasher.combine(body.orbitAU)
        }
        let bodySignature = hasher.finalize()

        guard size != cachedSize || cachedScale != scale || cachedCenter != center || cachedBodyCount != bodies.count || cachedBodySignature != bodySignature else {
            return
        }

        cachedSize = size
        cachedScale = scale
        cachedCenter = center
        cachedBodyCount = bodies.count
        cachedBodySignature = bodySignature

        var path = Path()
        for body in bodies where body.bodyID != .sun && body.bodyID != .atlas {
            let radius = CGFloat(body.orbitAU) * scale
            guard radius > 0 else { continue }
            let rect = CGRect(x: center.x - radius,
                              y: center.y - radius,
                              width: radius * 2,
                              height: radius * 2)
            path.addEllipse(in: rect)
        }

        cachedPath = path
    }
}

/// Core canvas responsible for rendering the solar system visualization.
struct SolarCanvas: View {
    @EnvironmentObject var store: AppStore
    @StateObject private var layoutCache = LayoutCache()
    @StateObject private var orbitCache = OrbitRenderCache()

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
        let resolvedBodies = bodies
        let time = state.time
        let scale = renderScale(for: size)
        let center = drawingCenter(for: state,
                                   bodies: resolvedBodies,
                                   canvasSize: size,
                                   scale: scale,
                                   time: time)
        orbitCache.rebuildIfNeeded(size: size,
                                   showOrbits: state.showOrbits,
                                   scale: scale,
                                   center: center,
                                   bodies: resolvedBodies)

        if state.showOrbits && !orbitCache.orbitsPath.isEmpty {
            context.stroke(
                orbitCache.orbitsPath,
                with: .color(.terminalCyan.opacity(0.35)),
                style: StrokeStyle(lineWidth: 1.5, dash: [5, 5])
            )
        }

        for body in resolvedBodies where body.bodyID != .atlas {

            let position = position(for: body,
                                    center: center,
                                    scale: scale,
                                    time: time)
            drawBody(body,
                     at: position,
                     isSelected: state.selectedBody == body.bodyID,
                     in: &context)

            if state.showLabels {
                drawLabel(for: body, at: position, in: &context)
            }
        }

        if state.showAtlasPath {
            drawCometAtlas(in: &context,
                           state: state,
                           center: center,
                           scale: scale,
                           time: time)
        }
    }

    private func drawBody(_ body: CelestialBody,
                          at position: CGPoint,
                          isSelected: Bool,
                          in context: inout GraphicsContext) {
        let radius = max(CGFloat(body.pixelRadius), 1)
        let bodyRect = CGRect(
            x: position.x - radius,
            y: position.y - radius,
            width: radius * 2,
            height: radius * 2
        )

        context.fill(Path(ellipseIn: bodyRect), with: .color(body.color))

        guard isSelected else { return }

        let highlightColor = Color.terminalCyan

        let outerGlowRect = bodyRect.insetBy(dx: -12, dy: -12)
        let outerGlowPath = Path(ellipseIn: outerGlowRect)
        context.stroke(
            outerGlowPath,
            with: .color(highlightColor.opacity(0.35)),
            style: StrokeStyle(lineWidth: 8)
        )

        let borderRect = bodyRect.insetBy(dx: -4, dy: -4)
        let borderPath = Path(ellipseIn: borderRect)
        context.stroke(
            borderPath,
            with: .color(highlightColor),
            style: StrokeStyle(lineWidth: 2)
        )
    }

    private func drawLabel(for body: CelestialBody,
                           at position: CGPoint,
                           in context: inout GraphicsContext) {
        let offset = body.labelOffset
        let labelPoint = CGPoint(
            x: position.x + offset.width,
            y: position.y + offset.height
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
                                time: Double) {
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

        let cometOffset = layoutCache.atlasPosition(time: time, scale: scale)
        let cometPosition = CGPoint(
            x: center.x + cometOffset.x,
            y: center.y + cometOffset.y
        )

        let atlasBody = bodies.first { $0.bodyID == .atlas }
        let cometRadius = max(CGFloat(atlasBody?.pixelRadius ?? 3), 3)
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
        let resolvedBodies = bodies
        let time = state.time
        let scale = renderScale(for: canvasSize)
        let center = drawingCenter(for: state,
                                   bodies: resolvedBodies,
                                   canvasSize: canvasSize,
                                   scale: scale,
                                   time: time)

        let currentSelection = state.selectedBody

        for body in resolvedBodies {
            let targetPoint: CGPoint
            let touchRadius = max(CGFloat(body.pixelRadius) * 2, CGFloat(20))

            if body.bodyID == .atlas {
                let cometOffset = layoutCache.atlasPosition(time: time, scale: scale)
                targetPoint = CGPoint(
                    x: center.x + cometOffset.x,
                    y: center.y + cometOffset.y
                )
            } else {
                targetPoint = position(for: body,
                                       center: center,
                                       scale: scale,
                                       time: time)
            }

            let dx = location.x - targetPoint.x
            let dy = location.y - targetPoint.y
            if (dx * dx + dy * dy).squareRoot() <= touchRadius {
                guard let bodyID = body.bodyID else {
                    store.dispatch(.solarSystem(.selectBody(nil)))
                    return
                }

                let newSelection = currentSelection == bodyID ? nil : bodyID
                store.dispatch(.solarSystem(.selectBody(newSelection)))
                return
            }
        }

        store.dispatch(.solarSystem(.selectBody(nil)))
    }

    private func position(for body: CelestialBody,
                          center: CGPoint,
                          scale: CGFloat,
                          time: Double) -> CGPoint {
        if body.bodyID == .sun {
            return center
        }

        let offset = layoutCache.relativePosition(for: body, time: time, scale: scale)
        return CGPoint(x: center.x + offset.x, y: center.y + offset.y)
    }

    private func drawingCenter(for state: SolarSystemState,
                               bodies: [CelestialBody],
                               canvasSize: CGSize,
                               scale: CGFloat,
                               time: Double) -> CGPoint {
        let baseCenter = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
        guard let focusedID = state.selectedBody else { return baseCenter }

        if focusedID == .sun {
            return baseCenter
        }

        if focusedID == .atlas {
            let offset = layoutCache.atlasPosition(time: time, scale: scale)
            return CGPoint(x: baseCenter.x - offset.x, y: baseCenter.y - offset.y)
        }

        guard let focusBody = bodies.first(where: { $0.bodyID == focusedID }) else {
            return baseCenter
        }

        let offset = layoutCache.relativePosition(for: focusBody, time: time, scale: scale)
        return CGPoint(x: baseCenter.x - offset.x, y: baseCenter.y - offset.y)
    }

    private func renderScale(for size: CGSize) -> CGFloat {
        let maxOrbit = bodies.map { CGFloat($0.orbitAU) }.max() ?? CGFloat(1)
        let safeMaxOrbit = max(maxOrbit, 0.1)
        let reference = min(size.width, size.height) * 0.45
        guard reference > 0 else { return 1 }
        return reference / safeMaxOrbit
    }

    private var solarSystem: SolarSystemState {
        store.state.solarSystem
    }

    private var bodies: [CelestialBody] {
        let stateBodies = solarSystem.bodies
        return stateBodies.isEmpty ? SolarSystemBodiesProvider.defaultBodies : stateBodies
    }
}

// MARK: - Layout cache

private final class LayoutCache: ObservableObject {
    private struct OrbitKey: Hashable {
        let radiusBucket: Int
    }

    private struct AtlasKey: Hashable {
        let scaleBucket: Int
    }

    private static let scalePrecision: CGFloat = 0.5
    private static let radiusPrecision: CGFloat = 0.5

    private var orbitPaths: [OrbitKey: Path] = [:]
    private var atlasTrajectories: [AtlasKey: [CGPoint]] = [:]

    func orbitPath(for body: CelestialBody, scale: CGFloat, center: CGPoint) -> Path? {
        let radius = CGFloat(body.orbitAU) * scale
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

    func relativePosition(for body: CelestialBody, time: Double, scale: CGFloat) -> CGPoint {
        let clampedTime = max(0, min(1, time))
        let radius = CGFloat(body.orbitAU) * scale
        let angle = (clampedTime * 2 * .pi) / body.periodDays + body.initialAngle
        return CGPoint(
            x: CGFloat(cos(angle)) * radius,
            y: CGFloat(sin(angle)) * radius
        )
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

    func atlasPosition(time: Double, scale: CGFloat) -> CGPoint {
        let clampedTime = max(0, min(1, time))
        let rawPoint = cometAtlasPath.position(at: clampedTime)
        return CGPoint(x: rawPoint.x * scale, y: rawPoint.y * scale)
    }

    private func bucket(for value: CGFloat, precision: CGFloat) -> Int {
        guard precision > 0 else { return Int(value) }
        return Int((value / precision).rounded())
    }
}
