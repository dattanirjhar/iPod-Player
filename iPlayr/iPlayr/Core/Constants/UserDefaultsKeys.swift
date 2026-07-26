public enum UserDefaultsKeys: String {
    case currentTheme = "currentTheme"
    case hapticsEnabled = "hapticsEnabled"
    case soundsEnabled = "soundsEnabled"
    case sortOrder = "sortOrder"
}

enum SortOrder: String, CaseIterable {
    case alphabetical = "Alphabetical"
    case dateAdded = "Date Added"

    mutating func toggle() {
        self = (self == .alphabetical) ? .dateAdded : .alphabetical
    }
}
