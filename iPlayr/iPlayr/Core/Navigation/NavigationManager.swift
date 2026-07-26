import Foundation
import Combine
import SwiftUI

enum NavigationEvent {
    case openNowPlaying
    case restoreStack
}

@MainActor
final class NavigationManager: ObservableObject {
    @Published var routes: [Route] = []

    /// The stack that was active before jumping to Now Playing.
    /// Non-nil only when the user entered Now Playing via long-press Menu/Play.
    private(set) var savedStack: [Route]?

    /// Whether the current Now Playing was entered via a global shortcut (long-press Menu or Play).
    /// When true, pressing Menu on Now Playing restores the saved stack
    /// instead of doing a normal pop.
    var isNowPlayingFromShortcut: Bool {
        savedStack != nil
    }

    private let eventSubject = PassthroughSubject<NavigationEvent, Never>()

    var events: AnyPublisher<NavigationEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    // MARK: - Basic Navigation

    func push(_ route: Route) {
        routes.append(route)
    }

    func pop() {
        guard !routes.isEmpty else { return }
        routes.removeLast()
    }

    func popToRoot() {
        routes.removeAll()
    }

    // MARK: - Now Playing Navigation

    /// Jump to Now Playing from anywhere, saving the current browsing stack.
    func goToNowPlaying() {
        savedStack = routes
        routes.removeAll()
        routes.append(.nowPlaying)
        eventSubject.send(.openNowPlaying)
    }

    /// Restore the navigation stack that was active before opening Now Playing.
    /// Returns true if a stack was restored, false if there was nothing to restore.
    @discardableResult
    func restoreFromNowPlaying() -> Bool {
        guard let stack = savedStack else { return false }
        savedStack = nil
        routes = stack
        eventSubject.send(.restoreStack)
        return true
    }

    /// Navigate to Now Playing from the main menu (normal push, no stack saving).
    func pushNowPlaying() {
        routes.append(.nowPlaying)
    }
}
