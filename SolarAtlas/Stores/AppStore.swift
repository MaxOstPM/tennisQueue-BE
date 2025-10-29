import Combine
import Foundation

/// Central store that exposes high-level app state derived from specialized stores.
final class AppStore: ObservableObject {
    @Published private(set) var state: AppState

    private let navigationStore: NavigationStore
    private let updateStore: UpdateStore
    private var cancellables: Set<AnyCancellable> = []

    init(navigationStore: NavigationStore, updateStore: UpdateStore) {
        self.navigationStore = navigationStore
        self.updateStore = updateStore
        self.state = AppState(
            activeTab: navigationStore.state.activeTab,
            isUpdateRequired: updateStore.state.isUpdateRequired
        )

        bindToStores()
    }

    /// Updates the active tab by forwarding the change to the navigation store.
    func setActiveTab(_ tab: AppTab) {
        guard state.activeTab != tab else { return }
        state.activeTab = tab
        navigationStore.dispatch(.setTab(tab))
    }

    /// Updates the forced-update flag by forwarding the change to the update store.
    func setUpdateRequired(_ isRequired: Bool) {
        guard state.isUpdateRequired != isRequired else { return }
        state.isUpdateRequired = isRequired
        updateStore.dispatch(.requireUpdate(isRequired))
    }

    private func bindToStores() {
        navigationStore.$state
            .map(\.activeTab)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tab in
                self?.state.activeTab = tab
            }
            .store(in: &cancellables)

        updateStore.$state
            .map(\.isUpdateRequired)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isRequired in
                self?.state.isUpdateRequired = isRequired
            }
            .store(in: &cancellables)
    }
}
