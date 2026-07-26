import SwiftUI
import MusicKit

struct ArtistsView: View {
    @EnvironmentObject private var iPlayrController: iPlayrButtonController
    @EnvironmentObject private var playerManager: AppleMusicManager
    @EnvironmentObject private var navigationManager: NavigationManager
    @StateObject private var artistManager = ArtistManager()
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
            StatusBar(title: "Artists")

            ZStack {
                if viewState == ViewState.content {
                    artistsScrollView
                }
                StateView(state: viewState)
            }
        }
        .shadowedBackground()
        .task { await loadArtists() }
        .onAppear(perform: setup)
        .navigationBarBackButtonHidden()
        .onDisappear {
            iPlayrController.saveCurrentIndex()
        }
        .onChange(of: sortOrderRaw) { _, _ in
            artistManager.invalidateCache()
            Task { await loadArtists() }
        }
    }

    private func loadArtists() async {
        viewState = .loading
        await artistManager.getCurrentUserArtists(sortOrder: sortOrder)

        if let artists = artistManager.savedArtists {
            if artists.isEmpty {
                viewState = .empty(message: "No artists found\nAdd some music to your library")
            } else {
                iPlayrController.menuCount = artists.count
                viewState = .content
            }
        } else {
            viewState = .error(message: artistManager.errorMessage ?? "An error occurred\nPlease try again")
        }
    }

    @ViewBuilder
    private var artistsScrollView: some View {
        ScrollViewReader { scrollViewProxy in
            if let savedArtists = artistManager.savedArtists {
                List(savedArtists.indices, id: \.self) { index in
                    let artist = savedArtists[index]
                    artistRow(for: artist, index: index)
                        .id(index)
                        .listRowInsets(EdgeInsets())
                }
                .listStyle(.plain)
                .onChange(of: iPlayrController.selectedIndex) { _, newIndex in
                    guard iPlayrController.activePage == .artists else { return }
                    selectedIndex = newIndex
                    scrollViewProxy.scrollTo(newIndex)
                }
            } else {
                Text("No artists found")
            }
        }
    }

    @ViewBuilder
    private func artistRow(for artist: Artist, index: Int) -> some View {
        CollectionMenuItem(
            model: artist.toCollectionMenuModel(),
            isSelected: index == selectedIndex
        )
    }

    private func setup() {
        iPlayrController.setActivePage(.artists, menuCount: artistManager.savedArtists?.count ?? 0)
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
        guard let savedArtists = artistManager.savedArtists, selectedIndex < savedArtists.count else { return }
        let artistName = savedArtists[selectedIndex].name
        navigate(.push(.artistAlbums(id: artistName, artistName: artistName)))
    }
}
