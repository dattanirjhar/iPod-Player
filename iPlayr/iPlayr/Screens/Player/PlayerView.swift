import SwiftUI
import MusicKit
import MediaPlayer

struct PlayerView: View {
    let id: String
    let trackIndex: Int
    let isFromCoverFlow: Bool
    let isFromPlaylist: Bool
    var isSingleSong: Bool = false
    var initialArtwork: Artwork?
    var onDismissFromCoverFlow: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var iPlayrController: iPlayrButtonController
    @EnvironmentObject private var playerManager: AppleMusicManager

    var body: some View {
        PlaybackDisplayView(
            isFromCoverFlow: isFromCoverFlow,
            showStatusBar: !isFromCoverFlow,
            initialArtwork: initialArtwork
        )
        .onAppear {
            iPlayrController.activePage = .player
            setupButtonListener()
            Task {
                try? await Task.sleep(for: .milliseconds(200))
                if isSingleSong {
                    try await playerManager.playSong(id: id)
                } else if isFromPlaylist {
                    try await playerManager.playPlaylist(id: id, fromIndex: trackIndex)
                } else {
                    try await playerManager.playAlbum(id: id, fromIndex: trackIndex)
                }
            }
        }
        .navigationBarBackButtonHidden()
    }

    private func setupButtonListener() {
        guard iPlayrController.activePage == .player else { return }
        iPlayrController.takeControl { action in
            switch action {
            case .menu:
                if isFromCoverFlow {
                    onDismissFromCoverFlow?()
                } else {
                    dismiss()
                }
            case .select:
                break
            case .forwardEndAlt:
                Task { try? await playerManager.skipToNextTrack() }
            case .backwardEndAlt:
                Task { try? await playerManager.skipToPreviousTrack() }
            case .playPause:
                Task {
                    try? await playerManager.togglePlayPause()
                }
            case .forwardLongPress:
                break
            case .forwardLongPressEnd:
                break
            case .backwardLongPress:
                break
            case .backwardLongPressEnd:
                break
            default:
                break
            }
        }
    }
}
