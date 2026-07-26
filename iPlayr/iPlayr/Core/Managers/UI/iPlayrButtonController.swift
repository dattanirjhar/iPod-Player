import Foundation
import UIKit
import AudioToolbox

enum ButtonAction: Sendable {
    case menu, forwardEndAlt, backwardEndAlt, playPause, select
    case menuLongPress, selectLongPress, playPauseLongPress
    case forwardLongPress, backwardLongPress, forwardLongPressEnd, backwardLongPressEnd
}

enum Page: Sendable {
    case home, music, login, playlists, albumTracks, playlistTracks, coverFlow,
         coverFlowSongList, player, theme, settings, albums, artists, artistAlbums, songs, nowPlaying
}

@MainActor
final class iPlayrButtonController: ObservableObject {
    @Published var selectedIndex: Int = 0
    @Published var menuCount: Int = 0
    @Published var activePage: Page = .home

    var hasRightView: Bool {
        switch activePage {
        case .home, .music, .settings, .theme, .login:
            return true
        default:
            return false
        }
    }

    private var activeInputHandler: ((ButtonAction) -> Void)?
    private var globalPlaybackHandler: ((ButtonAction) -> Void)?
    private var scrollHandler: ((ScrollDirection) -> Void)?

    // MARK: - Haptics (4 distinct strengths)

    private let selectionFeedback = UISelectionFeedbackGenerator()
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)

    enum ScrollDirection {
        case up, down
    }

    func takeControl(handler: @escaping (ButtonAction) -> Void) {
        self.activeInputHandler = handler
    }

    func releaseControl() {
        self.activeInputHandler = nil
    }

    var hasScrollHandler: Bool {
        scrollHandler != nil
    }

    func setScrollHandler(_ handler: @escaping (ScrollDirection) -> Void) {
        self.scrollHandler = handler
    }

    func releaseScrollHandler() {
        self.scrollHandler = nil
    }

    func setGlobalPlaybackHandler(_ handler: @escaping (ButtonAction) -> Void) {
        self.globalPlaybackHandler = handler
    }

    private var savedIndices: [Page: Int] = [:]

    private var lastInteractionTime: Date = .distantPast
    private let debounceInterval: TimeInterval = 0.1

    private var hapticsEnabled: Bool {
        UserDefaults.standard.object(forKey: UserDefaultsKeys.hapticsEnabled.rawValue) as? Bool ?? true
    }

    private var soundsEnabled: Bool {
        UserDefaults.standard.object(forKey: UserDefaultsKeys.soundsEnabled.rawValue) as? Bool ?? true
    }

    private func handleInput(_ action: ButtonAction) {
        let now = Date()

        switch action {
        case .menu:
            guard now.timeIntervalSince(lastInteractionTime) > debounceInterval else { return }
            lastInteractionTime = now
            if hapticsEnabled { lightImpact.impactOccurred() }
            if soundsEnabled { AudioServicesPlaySystemSound(1306) }

        case .select:
            guard now.timeIntervalSince(lastInteractionTime) > debounceInterval else { return }
            lastInteractionTime = now
            if hapticsEnabled { mediumImpact.impactOccurred() }
            if soundsEnabled { AudioServicesPlaySystemSound(1306) }

        case .playPause:
            guard now.timeIntervalSince(lastInteractionTime) > debounceInterval else { return }
            lastInteractionTime = now
            if hapticsEnabled { lightImpact.impactOccurred() }

        case .forwardEndAlt, .backwardEndAlt:
            guard now.timeIntervalSince(lastInteractionTime) > debounceInterval else { return }
            lastInteractionTime = now
            if hapticsEnabled { lightImpact.impactOccurred() }

        case .menuLongPress, .selectLongPress, .playPauseLongPress:
            guard now.timeIntervalSince(lastInteractionTime) > debounceInterval else { return }
            lastInteractionTime = now
            if hapticsEnabled { heavyImpact.impactOccurred() }

        default:
            break
        }

        activeInputHandler?(action)

        switch action {
        case .playPause, .forwardEndAlt, .backwardEndAlt:
            if activePage != .player && activePage != .nowPlaying {
                globalPlaybackHandler?(action)
            }
        default:
            break
        }
    }

    func menuButtonPressed() { handleInput(.menu) }
    func selectButtonPressed() { handleInput(.select) }
    func menuLongPressed() { handleInput(.menuLongPress) }
    func selectLongPressed() { handleInput(.selectLongPress) }
    func playPauseLongPressed() { handleInput(.playPauseLongPress) }
    func forwardEndAltButtonPressed() { handleInput(.forwardEndAlt) }
    func backwardEndAltButtonPressed() { handleInput(.backwardEndAlt) }
    func playPauseButtonPressed() { handleInput(.playPause) }

    func forwardLongPressStarted() { handleInput(.forwardLongPress) }
    func forwardLongPressEnded() { handleInput(.forwardLongPressEnd) }
    func backwardLongPressStarted() { handleInput(.backwardLongPress) }
    func backwardLongPressEnded() { handleInput(.backwardLongPressEnd) }

    func prepareHaptics() {
        if hapticsEnabled {
            selectionFeedback.prepare()
        }
    }

    func scrollUp() {
        if hapticsEnabled {
            selectionFeedback.selectionChanged()
        }
        if let scrollHandler {
            scrollHandler(.up)
            return
        }
        guard menuCount > 0 else { return }
        selectedIndex = selectedIndex > 0 ? selectedIndex - 1 : menuCount - 1
    }

    func scrollDown() {
        if hapticsEnabled {
            selectionFeedback.selectionChanged()
        }
        if let scrollHandler {
            scrollHandler(.down)
            return
        }
        guard menuCount > 0 else { return }
        selectedIndex = selectedIndex < menuCount - 1 ? selectedIndex + 1 : 0
    }

    func setActivePage(_ page: Page, menuCount: Int) {
        saveCurrentIndex()
        activePage = page
        self.menuCount = menuCount
        selectedIndex = savedIndices[page] ?? 0
    }

    func saveCurrentIndex() {
        savedIndices[activePage] = selectedIndex
    }

    func resetIndex(for page: Page) {
        savedIndices[page] = 0
    }
}
