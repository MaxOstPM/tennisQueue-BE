import SwiftUI
import SceneKit
import UIKit
import simd

public final class SolarSystemTapGestureProxy: ObservableObject {
    public weak var recognizer: UITapGestureRecognizer?

    public init(recognizer: UITapGestureRecognizer? = nil) {
        self.recognizer = recognizer
    }
}

public struct SolarSystemView: UIViewRepresentable {
    @Binding var selectedBody: SpaceBody?
    @Binding var timeline: CGFloat
    @Binding var showCometPath: Bool
    @ObservedObject var tapGestureProxy: SolarSystemTapGestureProxy

    public init(
        selectedBody: Binding<SpaceBody?>,
        timeline: Binding<CGFloat>,
        showCometPath: Binding<Bool>,
        tapGestureProxy: SolarSystemTapGestureProxy = SolarSystemTapGestureProxy()
    ) {
        _selectedBody = selectedBody
        _timeline = timeline
        _showCometPath = showCometPath
        self.tapGestureProxy = tapGestureProxy
    }

    public init(
        selectedBody: Binding<SpaceBody?>,
        timeline: Binding<CGFloat>
    ) {
        self.init(
            selectedBody: selectedBody,
            timeline: timeline,
            showCometPath: .constant(true)
        )
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    public func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        let scene = SCNScene()
        scnView.scene = scene
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = false
        scnView.defaultCameraController.interactionMode = .orbitTurntable
        scnView.backgroundColor = .black

        context.coordinator.parent = self
        context.coordinator.scnView = scnView
        context.coordinator.setupScene(in: scene)
        context.coordinator.updateScene(
            for: timeline,
            showCometPath: showCometPath
        )
        if let cameraNode = context.coordinator.sceneController.cameraNode {
            scnView.pointOfView = cameraNode
        }

        let tapRecognizer = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap(_:))
        )
        scnView.addGestureRecognizer(tapRecognizer)
        tapGestureProxy.recognizer = tapRecognizer

        return scnView
    }

    public func updateUIView(_ uiView: SCNView, context: Context) {
        context.coordinator.parent = self
        context.coordinator.scnView = uiView
        context.coordinator.updateScene(
            for: timeline,
            showCometPath: showCometPath
        )
    }

    public class Coordinator: NSObject {
        var parent: SolarSystemView
        let sceneController = SceneController()
        weak var scnView: SCNView?

        init(parent: SolarSystemView) {
            self.parent = parent
        }

        func setupScene(in scene: SCNScene) {
            sceneController.setupScene(in: scene)
        }

        func updateScene(for timeline: CGFloat, showCometPath: Bool) {
            sceneController.updateOrbits(for: timeline)
            sceneController.updateCometPosition(for: timeline)
            sceneController.cometPathNode?.isHidden = !showCometPath
        }

        @objc func handleTap(_ sender: UITapGestureRecognizer) {
            guard let scnView = scnView else { return }
            let location = sender.location(in: scnView)
            let results = scnView.hitTest(location, options: nil)

            for result in results {
                var node: SCNNode? = result.node
                while let current = node {
                    if let name = current.name,
                       let body = SpaceBody(rawValue: name) {
                        parent.selectedBody = body
                        return
                    }
                    node = current.parent
                }
            }
        }
    }
}

private final class SceneController {
    private struct PlanetConfiguration {
        let body: SpaceBody
        let radius: CGFloat
        let orbitalDistance: Float
        let color: UIColor
        let orbitalPeriod: CGFloat
    }

    private let planetConfigurations: [PlanetConfiguration] = [
        PlanetConfiguration(body: .mercury, radius: 0.1, orbitalDistance: 3.5, color: .lightGray, orbitalPeriod: 0.24),
        PlanetConfiguration(body: .venus, radius: 0.15, orbitalDistance: 5.5, color: .brown, orbitalPeriod: 0.62),
        PlanetConfiguration(body: .earth, radius: 0.2, orbitalDistance: 8.0, color: .blue, orbitalPeriod: 1.0),
        PlanetConfiguration(body: .mars, radius: 0.15, orbitalDistance: 10.5, color: .red, orbitalPeriod: 1.88),
        PlanetConfiguration(body: .jupiter, radius: 0.7, orbitalDistance: 14.0, color: .orange, orbitalPeriod: 11.86),
        PlanetConfiguration(body: .saturn, radius: 0.6, orbitalDistance: 18.0, color: .yellow, orbitalPeriod: 29.46),
        PlanetConfiguration(body: .uranus, radius: 0.4, orbitalDistance: 22.0, color: .cyan, orbitalPeriod: 84.0),
        PlanetConfiguration(body: .neptune, radius: 0.4, orbitalDistance: 26.0, color: UIColor.systemBlue, orbitalPeriod: 164.8)
    ]

    private(set) var orbitNodes: [SpaceBody: SCNNode] = [:]
    private(set) var orbitalPeriods: [SpaceBody: CGFloat] = [:]
    private(set) var cometPoints: [SCNVector3] = []
    private(set) var rootNode: SCNNode?

    var cometNode: SCNNode?
    var cometPathNode: SCNNode?
    var cameraNode: SCNNode?

    func setupScene(in scene: SCNScene) {
        scene.rootNode.childNodes.forEach { $0.removeFromParentNode() }

        orbitNodes.removeAll()
        orbitalPeriods.removeAll()
        cometPoints.removeAll()
        cometNode = nil
        cometPathNode = nil
        rootNode = scene.rootNode

        scene.background.contents = UIColor.black

        // Create the Sun with an omni light to illuminate the system.
        let sunGeometry = SCNSphere(radius: 2.0)
        sunGeometry.firstMaterial?.diffuse.contents = UIColor.orange
        sunGeometry.firstMaterial?.emission.contents = UIColor.orange
        let sunNode = SCNNode(geometry: sunGeometry)
        sunNode.name = SpaceBody.sun.rawValue

        let sunLight = SCNLight()
        sunLight.type = .omni
        sunLight.intensity = 2000
        sunNode.light = sunLight
        scene.rootNode.addChildNode(sunNode)

        // Add a dedicated camera so the full system is visible.
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 20, z: 50)
        cameraNode.look(at: .zero)
        scene.rootNode.addChildNode(cameraNode)
        self.cameraNode = cameraNode

        // Create orbit nodes for each planet and attach the planet mesh offset on the x-axis.
        for configuration in planetConfigurations {
            let planetGeometry = SCNSphere(radius: configuration.radius)
            let material = SCNMaterial()
            material.diffuse.contents = configuration.color
            planetGeometry.materials = [material]

            let planetNode = SCNNode(geometry: planetGeometry)
            planetNode.position = SCNVector3(configuration.orbitalDistance, 0, 0)
            planetNode.name = configuration.body.rawValue

            let orbitNode = SCNNode()
            orbitNode.addChildNode(planetNode)
            scene.rootNode.addChildNode(orbitNode)

            orbitNodes[configuration.body] = orbitNode
            orbitalPeriods[configuration.body] = configuration.orbitalPeriod
        }

        createComet()
    }

    func updateOrbits(for timeline: CGFloat) {
        guard !orbitNodes.isEmpty else { return }
        for (body, orbitNode) in orbitNodes {
            guard let period = orbitalPeriods[body], period != 0 else { continue }
            let angle = Float(2 * .pi * Double(timeline) / Double(period))
            orbitNode.eulerAngles.y = angle
        }
    }

    func createComet() {
        guard let rootNode else { return }

        let points: [SCNVector3] = [
            SCNVector3(0, -15, -50),
            SCNVector3(0, -10, -20),
            SCNVector3(0, 0, -5),
            SCNVector3(0, 0, -1.4),
            SCNVector3(0, 4, 10),
            SCNVector3(0, 8, 50)
        ]
        cometPoints = points

        let cometGeometry = SCNSphere(radius: 0.08)
        let cometMaterial = SCNMaterial()
        cometMaterial.diffuse.contents = UIColor.white
        cometMaterial.emission.contents = UIColor.cyan
        cometGeometry.materials = [cometMaterial]

        let cometNode = SCNNode(geometry: cometGeometry)
        cometNode.name = SpaceBody.atlas.rawValue
        cometNode.position = points.first ?? .zero
        rootNode.addChildNode(cometNode)
        self.cometNode = cometNode

        let pathNode = SCNNode()
        pathNode.name = "cometPathNode"

        for index in 0..<(points.count - 1) {
            let start = points[index]
            let end = points[index + 1]
            let segmentNode = cylinderNode(between: start, and: end)
            pathNode.addChildNode(segmentNode)
        }

        rootNode.addChildNode(pathNode)
        cometPathNode = pathNode
    }

    func updateCometPosition(for timeline: CGFloat) {
        guard let cometNode, !cometPoints.isEmpty else { return }

        let clampedTimeline = max(0, min(1, timeline))
        let segmentCount = cometPoints.count - 1
        guard segmentCount > 0 else { return }

        let scaledPosition = CGFloat(segmentCount) * clampedTimeline
        let segmentIndex = min(segmentCount - 1, Int(floor(scaledPosition)))
        let segmentProgress = Float(scaledPosition - CGFloat(segmentIndex))

        let start = cometPoints[segmentIndex]
        let end = cometPoints[segmentIndex + 1]
        let interpolated = start + (end - start) * segmentProgress
        cometNode.position = interpolated
    }

    private func cylinderNode(between start: SCNVector3, and end: SCNVector3) -> SCNNode {
        let vector = end - start
        let length = vector.length
        let cylinder = SCNCylinder(radius: 0.05, height: CGFloat(length))
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.cyan
        material.emission.contents = UIColor.cyan
        cylinder.materials = [material]

        let node = SCNNode(geometry: cylinder)
        node.position = (start + end) * 0.5
        node.name = nil

        let startVector = simd_float3(start)
        let endVector = simd_float3(end)
        let directionVector = endVector - startVector
        let up = simd_float3(0, 1, 0)
        let magnitude = simd_length(directionVector)
        if magnitude > .ulpOfOne {
            let direction = directionVector / magnitude
            let quaternion = simd_quatf(from: up, to: direction)
            node.simdOrientation = quaternion
        }

        return node
    }
}

private extension SCNVector3 {
    static var zero: SCNVector3 { SCNVector3(0, 0, 0) }

    static func +(lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
        SCNVector3(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
    }

    static func -(lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
        SCNVector3(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z)
    }

    static func *(lhs: SCNVector3, rhs: Float) -> SCNVector3 {
        SCNVector3(lhs.x * rhs, lhs.y * rhs, lhs.z * rhs)
    }

    var length: Float {
        sqrt(x * x + y * y + z * z)
    }
}

private extension simd_float3 {
    init(_ vector: SCNVector3) {
        self.init(Float(vector.x), Float(vector.y), Float(vector.z))
    }
}
