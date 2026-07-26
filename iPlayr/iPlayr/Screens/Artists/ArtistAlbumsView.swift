import SwiftUI
import MusicKit

struct ArtistAlbumsView: View {
    let artistId: String
    let artistName: String
    @EnvironmentObject private var iPlayrController: iPlayrButtonController
    @EnvironmentObject private var playerManager: AppleMusicManager
    @EnvironmentObject private var navigationManager: NavigationManager
    @StateObject private var artistManager = ArtistManager()
    @Environment(\.navigate) private var navigate
    @Environment(\.dismiss) private var dismiss
    @State private var selectedIndex = 0
    @State private var viewState: ViewState = .loading

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            StatusBar(title: artistName)

            ZStack {
                if viewState == ViewState.content {
                    albumsScrollView
                }
                StateView(state: viewState)
            }
        }
        .shadowedBackground()
        .task { await loadAlbums() }
        .onAppear(perform: setup)
        .navigationBarBackButtonHidden()
        .onDisappear {
            iPlayrController.saveCurrentIndex()
        }
    }

    private func loadAlbums() async {
        viewState = .loading
        await artistManager.getArtistAlbums(artistName: artistId)

        if let albums = artistManager.artistAlbums {
            if albums.isEmpty {
                viewState = .empty(message: "No albums found\nfor this artist")
            } else {
                iPlayrController.menuCount = albums.count
                viewState = .content
            }
        } else {
            viewState = .error(message: artistManager.errorMessage ?? "An error occurred\nPlease try again")
        }
    }

    @ViewBuilder
    private var albumsScrollView: some View {
        ScrollViewReader { scrollViewProxy in
            if let albums = artistManager.artistAlbums {
                List(albums.indices, id: \.self) { index in
                    let album = albums[index]
                    CollectionMenuItem(
                        model: album.toCollectionMenuModel(),
                        isSelected: index == selectedIndex
                    )
                    .id(index)
                    .listRowInsets(EdgeInsets())
                }
                .listStyle(.plain)
                .onChange(of: iPlayrController.selectedIndex) { _, newIndex in
                    guard iPlayrController.activePage == .artistAlbums else { return }
                    selectedIndex = newIndex
                    scrollViewProxy.scrollTo(newIndex)
                }
            } else {
                Text("No albums found")
            }
        }
    }

    private func setup() {
        iPlayrController.setActivePage(.artistAlbums, menuCount: artistManager.artistAlbums?.count ?? 0)
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
        guard let albums = artistManager.artistAlbums, selectedIndex < albums.count else { return }
        let id = albums[selectedIndex].id
        let albumName = albums[selectedIndex].title
        navigate(.push(.albumTracks(id: id.rawValue, albumName: albumName)))
    }
}
