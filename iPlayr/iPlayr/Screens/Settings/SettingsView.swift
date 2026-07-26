import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var iPlayrController: iPlayrButtonController
    @EnvironmentObject private var playerManager: AppleMusicManager
    @EnvironmentObject private var navigationManager: NavigationManager
    @Environment(\.navigate) private var navigate
    @Environment(\.dismiss) private var dismiss
    @AppStorage(UserDefaultsKeys.hapticsEnabled.rawValue) private var hapticsEnabled: Bool = true
    @AppStorage(UserDefaultsKeys.soundsEnabled.rawValue) private var soundsEnabled: Bool = true
    @AppStorage(UserDefaultsKeys.sortOrder.rawValue) private var sortOrderRaw: String = SortOrder.alphabetical.rawValue
    @State private var selectedIndex: Int = 0

    private var sortOrder: SortOrder {
        SortOrder(rawValue: sortOrderRaw) ?? .alphabetical
    }

    private var menus: [Menu] {
        [
            .init(id: 0, name: "Themes", next: true),
            .init(id: 1, name: "Sort Order", next: false, value: sortOrder.rawValue),
            .init(id: 2, name: "Haptics", next: false, value: hapticsEnabled ? "On" : "Off"),
            .init(id: 3, name: "Sounds", next: false, value: soundsEnabled ? "On" : "Off"),
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            StatusBar(title: "Settings")
            ForEach(menus.indices, id: \.self) { index in
                MenuItemView(menu: menus[index], isSelected: selectedIndex == index)
            }
            Spacer()
        }
        .shadowedBackground()
        .onAppear(perform: setup)
        .onChange(of: iPlayrController.selectedIndex) { _, newValue in
            guard iPlayrController.activePage == .settings else { return }
            selectedIndex = newValue
        }
        .navigationBarBackButtonHidden()
        .onDisappear {
            iPlayrController.saveCurrentIndex()
        }
    }

    private func setup() {
        iPlayrController.setActivePage(.settings, menuCount: menus.count)
        selectedIndex = iPlayrController.selectedIndex

        iPlayrController.takeControl { action in
            handleButtonAction(action)
        }
    }

    private func handleButtonAction(_ action: ButtonAction) {
        switch action {
        case .menu:
            dismiss()
        case .select:
            handleSelect()
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

    private func handleSelect() {
        switch selectedIndex {
        case 0:
            iPlayrController.releaseControl()
            navigate(.push(.theme))
        case 1:
            var order = sortOrder
            order.toggle()
            sortOrderRaw = order.rawValue
        case 2:
            hapticsEnabled.toggle()
        case 3:
            soundsEnabled.toggle()
        default:
            break
        }
    }
}
