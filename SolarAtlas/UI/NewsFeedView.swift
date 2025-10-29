import SwiftUI

/// Neon-styled feed listing astronomy news stories.
struct NewsFeedView: View {
    @EnvironmentObject private var newsStore: NewsFeedStore

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        ZStack {
            Color.spaceBlack.ignoresSafeArea()

            if newsStore.state.newsFeed.isEmpty {
                VStack(spacing: .spaceXL) {
                    header
                    emptyState
                }
                .padding(.horizontal, .space2XL)
            } else {
                ScrollView {
                    LazyVStack(spacing: .spaceXL, pinnedViews: [.sectionHeaders]) {
                        Section(header: header.padding(.bottom, .spaceLG)) {
                            ForEach(newsStore.state.newsFeed) { item in
                                newsCard(for: item)
                            }
                        }
                    }
                    .padding(.vertical, .spaceXL)
                }
                .padding(.horizontal, .space2XL)
            }
        }
        .overlay(ScanlineOverlay())
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: .spaceXS) {
            Text("Mission Dispatch")
                .font(.system(size: 28, weight: .heavy, design: .monospaced))
                .foregroundColor(.foregroundCyan)
                .glow()

            Text("Curated astronomical reports from the Solar Atlas network.")
                .font(.system(size: 13, weight: .regular, design: .monospaced))
                .foregroundColor(.mutedText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.spaceBlack)
    }

    private var emptyState: some View {
        VStack(spacing: .spaceLG) {
            Image(systemName: "antenna.radiowaves.left.and.right")
                .font(.system(size: 56))
                .foregroundColor(.terminalCyan)
                .glow()

            Text("No telemetry yet")
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundColor(.foregroundCyan)

            Text("Connect to the network to receive the latest Solar Atlas dispatches.")
                .font(.system(size: 14, weight: .regular, design: .monospaced))
                .foregroundColor(.mutedText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, .spaceXL)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func newsCard(for item: NewsItem) -> some View {
        VStack(alignment: .leading, spacing: .spaceMD) {
            Text(item.title)
                .font(.system(size: 20, weight: .semibold, design: .monospaced))
                .foregroundColor(.foregroundCyan)

            Text(item.summary)
                .font(.system(size: 14, weight: .regular, design: .monospaced))
                .foregroundColor(.mutedText)

            HStack {
                Text(item.source.uppercased())
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(.terminalAmber)

                Spacer()

                Text(dateFormatter.string(from: item.publishedAt))
                    .font(.system(size: 12, weight: .regular, design: .monospaced))
                    .foregroundColor(.mutedText)
            }

            if let url = item.articleURL {
                Link(destination: url) {
                    Text("Read full briefing")
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        .foregroundColor(.terminalCyan)
                        .underline()
                }
            }
        }
        .padding(.spaceXL)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.cardBackground.opacity(0.95))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.terminalCyan.opacity(0.35), lineWidth: 1)
        )
        .glow(color: .terminalCyan.opacity(0.4))
    }
}
