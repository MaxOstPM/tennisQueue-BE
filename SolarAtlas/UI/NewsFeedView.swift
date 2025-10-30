import SwiftUI

/// Neon-styled feed listing astronomy news stories.
struct NewsFeedView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.openURL) private var openURL

    private let analytics = AnalyticsTracker.shared

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        ZStack {
            Color.spaceBlack.ignoresSafeArea()

            Group {
                if newsItems.isEmpty {
                    emptyScroll
                } else {
                    feedScroll
                }
            }
        }
        .overlay(ScanlineOverlay())
        .onAppear {
            if newsItems.isEmpty {
                store.dispatch(.fetchNewsRequested)
            }
        }
    }

    private var emptyScroll: some View {
        ScrollView {
            VStack(spacing: .spaceXL) {
                header
                emptyState
            }
            .padding(.horizontal, .space2XL)
            .padding(.vertical, .spaceXL)
        }
        .refreshable { store.dispatch(.fetchNewsRequested) }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            bannerInset
        }
    }

    private var feedScroll: some View {
        ScrollView {
            LazyVStack(spacing: .spaceXL, pinnedViews: [.sectionHeaders]) {
                Section(header: header.padding(.bottom, .spaceLG)) {
                    ForEach(newsItems) { item in
                        newsCard(for: item)
                    }
                }
            }
            .padding(.vertical, .spaceXL)
        }
        .padding(.horizontal, .space2XL)
        .refreshable { store.dispatch(.fetchNewsRequested) }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            bannerInset
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: .spaceXS) {
            Text("Mission Dispatch")
                .font(Font.ds.titleL)
                .foregroundColor(.foregroundCyan)
                .glow()

            Text("Curated astronomical reports from the Solar Atlas network.")
                .font(Font.ds.label)
                .foregroundColor(.mutedText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.spaceBlack)
    }

    private var emptyState: some View {
        VStack(spacing: .spaceLG) {
            Image(systemName: "antenna.radiowaves.left.and.right")
                .font(Font.ds.iconXL)
                .foregroundColor(.terminalCyan)
                .glow()

            Text("No telemetry yet")
                .font(Font.ds.titleM)
                .foregroundColor(.foregroundCyan)

            Text(emptyStateMessage)
                .font(Font.ds.body)
                .foregroundColor(.mutedText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, .spaceXL)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func newsCard(for item: NewsItem) -> some View {
        TerminalPanel {
            VStack(alignment: .leading, spacing: .spaceMD) {
                Text(item.title)
                    .font(Font.ds.titleM)
                    .foregroundColor(.foregroundCyan)

                Text(item.summary)
                    .font(Font.ds.body)
                    .foregroundColor(.mutedText)

                HStack {
                    Text(item.source.uppercased())
                        .font(Font.ds.captionEmphasis)
                        .foregroundColor(.terminalAmber)

                    Spacer()

                    Text(dateFormatter.string(from: item.publishedAt))
                        .font(Font.ds.caption)
                        .foregroundColor(.mutedText)
                }

                if let url = item.articleURL {
                    Button {
                        analytics.logNewsItemOpened(id: item.id.uuidString, source: item.source)
                        openURL(url)
                    } label: {
                        Text("Read full briefing")
                            .font(Font.ds.labelEmphasis)
                            .foregroundColor(.terminalCyan)
                            .underline()
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
    }

    private var bannerInset: some View {
        Group {
            if shouldRenderBanner {
                BannerAdView()
                    .frame(height: .space4XL)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, .spaceMD)
                    .padding(.horizontal, .space2XL)
                    .background(Color.spaceBlack)
            }
        }
    }

    private var shouldRenderBanner: Bool {
        switch store.state.ads.consentStatus {
        case .unknown, .requesting:
            return false
        default:
            return true
        }
    }
}

private extension NewsFeedView {
    var newsItems: [NewsItem] {
        store.state.newsFeed.newsFeed
    }

    var errorMessage: String? {
        store.state.newsFeed.errorMessage
    }

    var emptyStateMessage: String {
        if let errorMessage {
            return errorMessage
        }
        return "Connect to the network to receive the latest Solar Atlas dispatches."
    }
}
