import SwiftUI
import MusicKit

struct SongsView: View {
    @EnvironmentObject private var iPlayrController: iPlayrButtonController
    @EnvironmentObject private var playerManager: AppleMusicManager
    @EnvironmentObject private var navigationManager: NavigationManager
    @StateObject private var songManager = SongManager()
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
            StatusBar(title: "Songs")

            ZStack {
                if viewState == ViewState.content {
                    songsScrollView
                }
                StateView(state: viewState)
            }
        }
        .shadowedBackground()
        .task { await loadSongs() }
        .onAppear(perform: setup)
        .navigationBarBackButtonHidden()
        .onDisappear {
            iPlayrController.saveCurrentIndex()
        }
        .onChange(of: sortOrderRaw) { _, _ in
            songManager.invalidateCache()
            Task { await loadSongs() }
        }
    }

    private func loadSongs() async {
        viewState = .loading
        await songManager.getAllSongs(sortOrder: sortOrder)

        if let songs = songManager.savedSongs {
            if songs.isEmpty {
                viewState = .empty(message: "No songs found\nAdd some music to your library")
            } else {
                iPlayrController.menuCount = songs.count
                viewState = .content
            }
        } else {
            viewState = .error(message: songManager.errorMessage ?? "An error occurred\nPlease try again")
        }
    }

    @ViewBuilder
    private var songsScrollView: some View {
        ScrollViewReader { scrollViewProxy in
            if let savedSongs = songManager.savedSongs {
                List(savedSongs.indices, id: \.self) { index in
                    let song = savedSongs[index]
                    CollectionMenuItem(
                        model: song.toCollectionMenuModel(),
                        isSelected: index == selectedIndex
                    )
                    .id(index)
                    .listRowInsets(EdgeInsets())
                }
                .listStyle(.plain)
                .onChange(of: iPlayrController.selectedIndex) { _, newIndex in
                    guard iPlayrController.activePage == .songs else { return }
                    selectedIndex = newIndex
                    scrollViewProxy.scrollTo(newIndex)
                }
            } else {
                Text("No songs found")
            }
        }
    }

    private func setup() {
        iPlayrController.setActivePage(.songs, menuCount: songManager.savedSongs?.count ?? 0)
        selectedIndex = iPlayrController.selectedIndex

        iPlayrController.takeControl { action in
            handleButtonAction(action)
        }
    }

    private func handleButtonAction(_ action: ButtonAction) {
        switch action {
        case .menu: dismiss()
        case .select: playSong()
        case .selectLongPress:
            // Long-press center: jump to Now Playing if highlighted song is the current track
            if let savedSongs = songManager.savedSongs,
               selectedIndex < savedSongs.count,
               let currentTrack = playerManager.currentTrack,
               savedSongs[selectedIndex].id == currentTrack.id {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    navigationManager.goToNowPlaying()
                }
            }
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

    private func playSong() {
        guard let savedSongs = songManager.savedSongs, selectedIndex < savedSongs.count else { return }
        let songId = savedSongs[selectedIndex].id.rawValue
        iPlayrController.releaseControl()
        navigate(.push(.songPlayer(songId: songId)))
    }
}
