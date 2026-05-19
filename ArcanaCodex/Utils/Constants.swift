import SwiftUI

enum AppDesign {
    static let backgroundDark = "#090B08"
    static let backgroundCard = "#15130D"
    static let backgroundElevated = "#211D14"

    static let ink = "#070806"
    static let obsidian = "#0D100C"
    static let verdigris = "#1E5A4E"
    static let verdigrisLight = "#3E8B75"
    static let burgundy = "#6E2830"
    static let parchment = "#E8D6A8"
    static let parchmentDim = "#A99563"
    static let antiqueGold = "#C8A653"
    static let antiqueGoldLight = "#E4C76A"
    static let antiqueGoldDark = "#6C5522"

    static let cyan = verdigrisLight
    static let cyanBright = "#72BDA7"
    static let cyanDim = "#173D36"
    static let violet = burgundy
    static let violetDeep = "#3F151D"
    static let rose = "#A44C58"
    static let gold = antiqueGold
    static let goldLight = antiqueGoldLight
    static let goldDim = antiqueGoldDark

    static let textPrimary = "#F4E9C7"
    static let textSecondary = "#B8A77A"

    static var cyanGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: antiqueGoldDark), Color(hex: antiqueGold), Color(hex: antiqueGoldLight)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    static var cosmicBackground: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: ink),
                Color(hex: obsidian),
                Color(hex: "#11170F"),
                Color(hex: ink)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var cardGlassBackground: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: backgroundElevated).opacity(0.88),
                Color(hex: backgroundCard).opacity(0.96)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var nebulaGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: verdigris).opacity(0.20),
                Color(hex: burgundy).opacity(0.10),
                .clear
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255.0
        let g = Double((int >> 8) & 0xFF) / 255.0
        let b = Double(int & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
