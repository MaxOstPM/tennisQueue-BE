import SwiftUI
import SceneKit

public struct SolarSystemContainerView: View {
    @State private var timeline: CGFloat = 0.0
    @State private var showCometPath: Bool = true
    @State private var selectedBody: SpaceBody? = nil
    @StateObject private var tapGestureProxy = SolarSystemTapGestureProxy()

    public init() {}

    public var body: some View {
        VStack {
            SolarSystemView(
                selectedBody: $selectedBody,
                timeline: $timeline,
                showCometPath: $showCometPath,
                tapGestureProxy: tapGestureProxy
            )
            .frame(minHeight: 400)

            VStack(spacing: 12) {
                VStack(alignment: .leading) {
                    Text("Time")
                        .font(.subheadline)
                    Slider(value: $timeline, in: 0...1)
                }

                Toggle("Show Comet Path", isOn: $showCometPath)
                    .onChange(of: showCometPath) { newValue in
                        guard
                            let scnView = tapGestureProxy.recognizer?.view as? SCNView,
                            let node = scnView.scene?.rootNode.childNode(
                                withName: "cometPathNode",
                                recursively: true
                            )
                        else { return }
                        node.isHidden = !newValue
                    }
            }
            .padding()
        }
        .sheet(item: $selectedBody) { body in
            BodyInfoView(body: body, selectedBody: $selectedBody)
        }
    }
}
