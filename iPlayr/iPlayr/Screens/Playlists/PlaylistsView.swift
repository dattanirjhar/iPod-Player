import SwiftUI

struct PlaylistsView: View {
    @EnvironmentObject private var iPlayrController: iPlayrButtonController
    @EnvironmentObject private var playerManager: AppleMusicManager
    @EnvironmentObject private var navigationManager: NavigationManager
    @StateObject private var playlistManager = PlaylistManager()
    @Environment(\.navigate) private var navigate
    @Environment(\.dismiss) private var dismiss
    @AppStorage(UserDefaultsKeys.sortOrder.rawValue) private var sortOrderRaw: String = SortOrder.alphabetical.rawValue
    @State private var selectedIndex = 0
    @State private var viewState: ViewState = .loading

    private var sortOrder: SortOrder {
        SortOrder(rawValue: sortOrderRaw) ?? .alphabetical
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            StatusBar(title: "Playlists")
            ZStack {
                if viewState == .content {
                    playlistScrollView
                }
                StateView(state: viewState)
            }
        }
        .shadowedBackground()
        .task { await loadPlaylists() }
        .onAppear(perform: setup)
        .navigationBarBackButtonHidden()
        .onDisappear {
            iPlayrController.saveCurrentIndex()
        }
        .onChange(of: sortOrderRaw) { _, _ in
            playlistManager.invalidateCache()
            Task { await loadPlaylists() }
        }
    }
    
    private func loadPlaylists() async {
        viewState = .loading
        await playlistManager.fetchPlaylists(sortOrder: sortOrder)
        
        if let playlists = playlistManager.playlists {
            if playlists.isEmpty {
                viewState = .empty(message: "No playlists found\nCreate some playlists to get started")
            } else {
                iPlayrController.menuCount = playlists.count
                viewState = .content
            }
        } else {
            viewState = .error(message: playlistManager.errorMessage ?? "An error occurred\nPlease try again later")
        }
    }
    
    @ViewBuilder
    private var playlistScrollView: some View {
        ScrollViewReader { scrollViewProxy in
            let savedPlaylists = playlistManager.playlists?.compactMap { $0 } ?? []
            let indexedPlaylists = Array(savedPlaylists.enumerated())
            List(indexedPlaylists, id: \.offset) { index, playlist in
                CollectionMenuItem(
                    model: playlist.toCollectionMenuModel(),
                    isSelected: index == selectedIndex
                )
                .id(index)
                .listRowInsets(EdgeInsets())
            }
            .listStyle(.plain)
            .onChange(of: iPlayrController.selectedIndex) { _, newIndex in
                guard iPlayrController.activePage == .playlists else { return }
                selectedIndex = newIndex
                scrollViewProxy.scrollTo(newIndex)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    scrollViewProxy.scrollTo(selectedIndex)
                }
            }
        }
    }
    
    private func setup() {
        iPlayrController.setActivePage(.playlists, menuCount: playlistManager.playlists?.count ?? 0)
        selectedIndex = iPlayrController.selectedIndex
        
        iPlayrController.takeControl { action in
            handleButtonAction(action)
        }
    }
    
    private func handleButtonAction(_ action: ButtonAction) {
        switch action {
        case .menu: dismiss()
        case .select: navigation()
        case .menuLongPress:
            if playerManager.currentTrack != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    navigationManager.goToNowPlaying()
                }
            }
        case .playPauseLongPress:
            if playerManager.currentTrack != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    navigationManager.goToNowPlaying()
                }
            }
        default: break
        }
    }
    
    private func navigation() {
        iPlayrController.releaseControl()
        let id = playlistManager.playlists?[selectedIndex].id ?? ""
        let playlistName = playlistManager.playlists?[selectedIndex].name ?? ""
        navigate(.push(.playlistTracks(id: id.rawValue, playlistName: playlistName)))
    }
    
}
