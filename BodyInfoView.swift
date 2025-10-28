import SwiftUI

public struct BodyInfoView: View {
    let spaceBody: SpaceBody
    @Binding var selectedBody: SpaceBody?

    public init(body: SpaceBody, selectedBody: Binding<SpaceBody?>) {
        self.spaceBody = body
        _selectedBody = selectedBody
    }

    public var body: some View {
        VStack(spacing: 16) {
            Text(spaceBody.displayName)
                .font(.headline)

            Text(spaceBody.description)
                .multilineTextAlignment(.leading)
                .padding()

            Button("Close") {
                selectedBody = nil
            }
            .padding(.top, 8)
        }
        .padding()
    }
}
