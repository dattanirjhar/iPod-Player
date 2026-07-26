import SwiftUI
import MusicKit

struct HomeListView: View {
    @EnvironmentObject private var iPlayrController: iPlayrButtonController
    @EnvironmentObject private var authManager: MusicAuthorizationManager
    @EnvironmentObject private var playerManager: AppleMusicManager
    @EnvironmentObject private var navigationManager: NavigationManager
    @Environment(\.navigate) private var navigate
    
    /// Whether something is currently playing or paused (track loaded).
    private var hasActiveTrack: Bool {
        playerManager.currentTrack != nil
    }
    
    private var menus: [Menu] {
        var items: [Menu] = []
        var nextId = 0
        
        // Dynamic "Now Playing" — only appears when a track is loaded
        if hasActiveTrack {
            items.append(.init(id: nextId, name: "Now Playing", next: true))
            nextId += 1
        }
        
        items.append(.init(id: nextId, name: "Music", next: true))
        nextId += 1
        items.append(.init(id: nextId, name: "Settings", next: true))
        nextId += 1
        
        if !authManager.isAuthorized {
            items.append(.init(id: nextId, name: "Sign In", next: true))
        }
        
        return items
    }
    
    @State private var selectedIndex: Int = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            StatusBar(title: "iPlayr")
            ForEach(menus.indices, id: \.self) { index in
                MenuItemView(menu: menus[index], isSelected: selectedIndex == index)
            }
            Spacer()
        }
        .shadowedBackground()
        .navigationBarBackButtonHidden()
        .onAppear(perform: setup)
        .onChange(of: iPlayrController.selectedIndex) { _, newValue in
            guard iPlayrController.activePage == .home else { return }
            selectedIndex = newValue
        }
        .onChange(of: authManager.isAuthorized) { _, isAuthorized in
            if isAuthorized {
                iPlayrController.resetIndex(for: .home)
                iPlayrController.setActivePage(.home, menuCount: menus.count)
                selectedIndex = iPlayrController.selectedIndex
            }
        }
        .onChange(of: hasActiveTrack) { _, _ in
            // Update menu count when track availability changes
            iPlayrController.menuCount = menus.count
            // Clamp selected index if it's now out of bounds
            if selectedIndex >= menus.count {
                selectedIndex = max(0, menus.count - 1)
                iPlayrController.selectedIndex = selectedIndex
            }
        }
        .onDisappear {
            iPlayrController.saveCurrentIndex()
        }
    }
    
    private func setup() {
        iPlayrController.setActivePage(.home, menuCount: menus.count)
        selectedIndex = iPlayrController.selectedIndex
        
        iPlayrController.takeControl { action in
            handleButtonAction(action)
        }
    }
    
    private func handleButtonAction(_ action: ButtonAction) {
        switch action {
        case .select: navigation()
        case .menuLongPress:
            // Long-press Menu from home → go to Now Playing if track is loaded
            if hasActiveTrack {
                // 50ms delay after haptic before transition
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    navigationManager.goToNowPlaying()
                }
            }
        case .playPauseLongPress:
            // Long-press Play/Pause → go to Now Playing
            if hasActiveTrack {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    navigationManager.goToNowPlaying()
                }
            }
        case .playPause: break
        default: break
        }
    }
    
    private func navigation() {
        iPlayrController.releaseControl()
        let route: Route
        let menuName = menus[selectedIndex].name
        switch menuName {
        case "Now Playing":
            navigationManager.pushNowPlaying()
            return
        case "Music":
            route = .music
        case "Settings":
            route = .settings
        case "Sign In":
            route = .signIn
        default:
            route = .music
        }
        navigate(.push(route))
    }
    
}
