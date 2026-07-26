import SwiftUI

struct PodTheme: Identifiable, Equatable {
    let id: String
    let name: String

    // Chassis
    let chassisTop: Color
    let chassisMid: Color
    let chassisBottom: Color
    let chassisHighlight: Color

    // Screen Bezel
    let bezel: Color

    // Wheel
    let wheelLight: Color
    let wheelDark: Color
    let wheelHighlight: Color

    // Center button
    let centerLight: Color
    let centerDark: Color

    // Glyphs
    let glyphTint: Color

    // Depth levers
    let sheen: CGFloat
    
    static let silver = PodTheme(
        id: "silver", name: "Silver",
        chassisTop: Color(hex: "FDFDFD"), chassisMid: Color(hex: "DCDFE3"), chassisBottom: Color(hex: "B3B8BF"),
        chassisHighlight: .white,
        bezel: Color(hex: "9FA4AA"),
        wheelLight: Color(hex: "FFFFFF"), wheelDark: Color(hex: "DFE2E6"), wheelHighlight: .white,
        centerLight: Color(hex: "FFFFFF"), centerDark: Color(hex: "DCDFE3"),
        glyphTint: Color.buttonIconTint,
        sheen: 0.85
    )

    static let dark = PodTheme(
        id: "dark", name: "Black",
        chassisTop: Color(hex: "3A3C40"), chassisMid: Color(hex: "212226"), chassisBottom: Color(hex: "101113"),
        chassisHighlight: .white,
        bezel: Color(hex: "08090A"),
        wheelLight: Color(hex: "4C4E52"), wheelDark: Color(hex: "1D1E20"), wheelHighlight: .white,
        centerLight: Color(hex: "4C4E52"), centerDark: Color(hex: "1D1E20"),
        glyphTint: .white,
        sheen: 0.35
    )

    static let u2Edition = PodTheme(
        id: "u2Edition", name: "U2 Edition",
        chassisTop: Color(hex: "3A3C40"), chassisMid: Color(hex: "1F2023"), chassisBottom: Color(hex: "121315"),
        chassisHighlight: .white,
        bezel: Color(hex: "08090A"),
        wheelLight: Color(hex: "FF5A4D"), wheelDark: Color(hex: "A20E08"), wheelHighlight: Color(hex: "FFB3AD"),
        centerLight: Color(hex: "3A3C40"), centerDark: Color(hex: "121315"),
        glyphTint: .white,
        sheen: 0.45
    )

    static let graphite = PodTheme(
        id: "graphite", name: "Graphite",
        chassisTop: Color(hex: "3A3D42"), chassisMid: Color(hex: "2A2D31"), chassisBottom: Color(hex: "17191C"),
        chassisHighlight: .white,
        bezel: Color(hex: "101214"),
        wheelLight: Color(hex: "55595F"), wheelDark: Color(hex: "2E3136"), wheelHighlight: Color(hex: "C9CED6"),
        centerLight: Color(hex: "55595F"), centerDark: Color(hex: "2E3136"),
        glyphTint: .white,
        sheen: 0.40
    )

    static let productRed = PodTheme(
        id: "productRed", name: "PRODUCT(RED)",
        chassisTop: Color(hex: "FF6B5C"), chassisMid: Color(hex: "C8102E"), chassisBottom: Color(hex: "8A0A1F"),
        chassisHighlight: .white,
        bezel: Color(hex: "6A0818"), // slightly darker red, reading as shaded metal
        wheelLight: Color(hex: "FFFFFF"), wheelDark: Color(hex: "E3E5E8"), wheelHighlight: .white,
        centerLight: Color(hex: "FFFFFF"), centerDark: Color(hex: "E3E5E8"),
        glyphTint: Color(hex: "C8102E"),
        sheen: 0.70
    )

    static let champagneGold = PodTheme(
        id: "champagneGold", name: "Champagne Gold",
        chassisTop: Color(hex: "FFF2D6"), chassisMid: Color(hex: "E6BF6B"), chassisBottom: Color(hex: "B0872F"),
        chassisHighlight: .white,
        bezel: Color(hex: "8C6B25"),
        wheelLight: Color(hex: "F3D89A"), wheelDark: Color(hex: "C9A24E"), wheelHighlight: Color(hex: "FFF3D6"),
        centerLight: Color(hex: "F3D89A"), centerDark: Color(hex: "C9A24E"),
        glyphTint: .black,
        sheen: 0.70
    )

    static let roseGold = PodTheme(
        id: "roseGold", name: "Rose Gold",
        chassisTop: Color(hex: "F4D3CC"), chassisMid: Color(hex: "C98B84"), chassisBottom: Color(hex: "9E655E"),
        chassisHighlight: .white,
        bezel: Color(hex: "80524C"),
        wheelLight: Color(hex: "F7C9C0"), wheelDark: Color(hex: "D98F86"), wheelHighlight: Color(hex: "FFE1DC"),
        centerLight: Color(hex: "F7C9C0"), centerDark: Color(hex: "D98F86"),
        glyphTint: .black,
        sheen: 0.60
    )

    static let oceanBlue = PodTheme(
        id: "oceanBlue", name: "Ocean Blue",
        chassisTop: Color(hex: "8FD3FF"), chassisMid: Color(hex: "1F83E6"), chassisBottom: Color(hex: "0A4F9E"),
        chassisHighlight: .white,
        bezel: Color(hex: "083C7A"),
        wheelLight: Color(hex: "8FD3FF"), wheelDark: Color(hex: "0A6BD6"), wheelHighlight: Color(hex: "CDE9FF"),
        centerLight: Color(hex: "8FD3FF"), centerDark: Color(hex: "0A6BD6"),
        glyphTint: .white,
        sheen: 0.55
    )

    static let lime = PodTheme(
        id: "lime", name: "Lime",
        chassisTop: Color(hex: "D6F5A0"), chassisMid: Color(hex: "8CC63F"), chassisBottom: Color(hex: "5A8A1E"),
        chassisHighlight: .white,
        bezel: Color(hex: "486E18"),
        wheelLight: Color(hex: "D6F5A0"), wheelDark: Color(hex: "6FB52A"), wheelHighlight: Color(hex: "EFFFD1"),
        centerLight: Color(hex: "D6F5A0"), centerDark: Color(hex: "6FB52A"),
        glyphTint: .black,
        sheen: 0.60
    )

    static let midnight = PodTheme(
        id: "midnight", name: "Midnight",
        chassisTop: Color(hex: "33405A"), chassisMid: Color(hex: "1B2330"), chassisBottom: Color(hex: "0E141F"),
        chassisHighlight: .white,
        bezel: Color(hex: "080B12"),
        wheelLight: Color(hex: "33405A"), wheelDark: Color(hex: "131A26"), wheelHighlight: Color(hex: "9FB4D6"),
        centerLight: Color(hex: "33405A"), centerDark: Color(hex: "131A26"),
        glyphTint: .white,
        sheen: 0.35
    )
}

enum ThemeType: String, CaseIterable {
    case silver, dark, u2Edition, graphite, productRed, champagneGold, roseGold, oceanBlue, lime, midnight
    
    var theme: PodTheme {
        switch self {
        case .silver: return .silver
        case .dark: return .dark
        case .u2Edition: return .u2Edition
        case .graphite: return .graphite
        case .productRed: return .productRed
        case .champagneGold: return .champagneGold
        case .roseGold: return .roseGold
        case .oceanBlue: return .oceanBlue
        case .lime: return .lime
        case .midnight: return .midnight
        }
    }
}

@MainActor
final class ThemeManager: ObservableObject {
    @Published private(set) var currentTheme: PodTheme
    @AppStorage("currentTheme") private var currentThemeType: ThemeType = .silver

    init() {
        let saved = UserDefaults.standard.string(forKey: "currentTheme").flatMap(ThemeType.init) ?? .silver
        currentThemeType = saved
        currentTheme = saved.theme
    }

    func setTheme(_ themeType: ThemeType) {
        currentThemeType = themeType
        currentTheme = themeType.theme
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
