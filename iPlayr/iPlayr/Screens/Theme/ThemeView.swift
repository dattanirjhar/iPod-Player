import SwiftUI

struct ThemeView: View {
    @EnvironmentObject private var iPlayrController: iPlayrButtonController
    @EnvironmentObject private var playerManager: AppleMusicManager
    @EnvironmentObject private var navigationManager: NavigationManager
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var theme: ThemeManager
    private let availableThemes: [ThemeType] = [
        .silver, .dark, .u2Edition, .graphite, .productRed, .champagneGold, .roseGold, .oceanBlue, .lime, .midnight
    ]
    private var menus: [Menu] {
        availableThemes.enumerated().map { index, type in
            Menu(id: index, name: type.theme.name, next: false)
        }
    }
    @State private var selectedIndex: Int = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            StatusBar(title: "Themes")
            
            GeometryReader { geo in
                let rowHeight: CGFloat = 26
                let visibleRows = Int(geo.size.height / rowHeight)
                
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(menus, id: \.id) { menu in
                        MenuItemView(menu: menu, isSelected: selectedIndex == menu.id)
                            .frame(height: rowHeight)
                    }
                }
                .offset(y: -CGFloat(max(0, selectedIndex - (visibleRows - 1))) * rowHeight)
                .animation(.easeOut(duration: 0.15), value: selectedIndex)
            }
            .clipped()
        }
        .shadowedBackground()
        .onAppear(perform: setup)
        .onChange(of: iPlayrController.selectedIndex) { _, newValue in
            guard iPlayrController.activePage == .theme else { return }
            selectedIndex = newValue
        }
        .navigationBarBackButtonHidden()
        .onDisappear {
            iPlayrController.saveCurrentIndex()
        }
    }

    private func setup() {
        iPlayrController.setActivePage(.theme, menuCount: menus.count)
        selectedIndex = iPlayrController.selectedIndex

        iPlayrController.takeControl { action in
            switch action {
            case .menu:
                dismiss()
            case .select:
                setTheme()
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
            default:
                break
            }
        }
    }

    private func setTheme() {
        withAnimation {
            theme.setTheme(availableThemes[selectedIndex])
        }
    }
}
