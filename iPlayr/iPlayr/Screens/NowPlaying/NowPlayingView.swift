import SwiftUI
import MusicKit

/// Display-only Now Playing screen. Shows the currently playing track
/// without triggering any new playback. Reuses PlaybackDisplayView
/// for the shared artwork/progress/volume UI.
struct NowPlayingView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var iPlayrController: iPlayrButtonController
    @EnvironmentObject private var playerManager: AppleMusicManager
    @EnvironmentObject private var navigationManager: NavigationManager

    var body: some View {
        PlaybackDisplayView(
            isFromCoverFlow: false,
            showStatusBar: true
        )
        .onAppear {
            iPlayrController.setActivePage(.nowPlaying, menuCount: 0)
            setupButtonListener()
        }
        .onDisappear {
            iPlayrController.releaseScrollHandler()
        }
        .navigationBarBackButtonHidden()
    }

    private func setupButtonListener() {
        guard iPlayrController.activePage == .nowPlaying else { return }
        iPlayrController.takeControl { action in
            switch action {
            case .menu:
                // If we came here via long-press shortcut, restore the previous stack.
                // Otherwise, just pop normally.
                if navigationManager.isNowPlayingFromShortcut {
                    navigationManager.restoreFromNowPlaying()
                } else {
                    dismiss()
                }
            case .forwardEndAlt:
                Task { try? await playerManager.skipToNextTrack() }
            case .backwardEndAlt:
                Task { try? await playerManager.skipToPreviousTrack() }
            case .playPause:
                Task { try? await playerManager.togglePlayPause() }
            case .forwardLongPress:
                // Seeking is handled by PlaybackDisplayView's volume/scroll setup
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
