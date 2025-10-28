import SwiftUI
import SceneKit

public final class SolarSystemTapGestureProxy: ObservableObject {
    public weak var recognizer: UITapGestureRecognizer?

    public init(recognizer: UITapGestureRecognizer? = nil) {
        self.recognizer = recognizer
    }
}

public struct SolarSystemView: UIViewRepresentable {
    @Binding private var selectedBody: SpaceBody?
    @Binding private var timeline: CGFloat
    @ObservedObject private var tapGestureProxy: SolarSystemTapGestureProxy

    public init(
        selectedBody: Binding<SpaceBody?>,
        timeline: Binding<CGFloat>,
        tapGestureProxy: SolarSystemTapGestureProxy
    ) {
        _selectedBody = selectedBody
        _timeline = timeline
        self.tapGestureProxy = tapGestureProxy
    }

    public func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = SCNScene()
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = true
        scnView.defaultCameraController.interactionMode = .orbitTurntable

        let tapRecognizer = UITapGestureRecognizer()
        scnView.addGestureRecognizer(tapRecognizer)
        tapGestureProxy.recognizer = tapRecognizer

        return scnView
    }

    public func updateUIView(_ uiView: SCNView, context: Context) {
        // Intentionally left blank; no dynamic updates required currently.
    }
}
