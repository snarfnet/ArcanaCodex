import SwiftUI

enum AppDesign {
    // Celestial palette — Enochian Keys style
    static let backgroundDark     = "#030112"
    static let backgroundCard     = "#0A0824"
    static let backgroundElevated = "#12103A"

    static let nebulaDeep   = "#080430"
    static let nebulaMid    = "#160E50"
    static let nebulaRim    = "#2B1B7E"

    // Cyan-dominant accents (Enochian Keys vibe)
    static let cyan         = "#4DD9E8"
    static let cyanBright   = "#7AEEF8"
    static let cyanDim      = "#1A6A72"

    static let violet       = "#8B5CF6"
    static let violetDeep   = "#5B21B6"
    static let rose         = "#E879A8"
    static let starWhite    = "#EEF0FF"

    // Gold accents for headings
    static let gold         = "#C9A84C"
    static let goldLight    = "#E8C96A"
    static let goldDim      = "#7A6128"

    static let textPrimary   = "#EEF0FF"
    static let textSecondary = "#8B8AAA"

    static var cyanGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: cyanDim), Color(hex: cyan), Color(hex: cyanBright), Color(hex: cyan)],
            startPoint: .leading, endPoint: .trailing
        )
    }

    static var cosmicBackground: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: backgroundDark),
                Color(hex: "060328"),
                Color(hex: "0D0940"),
                Color(hex: backgroundDark)
            ],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    static var cardGlassBackground: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: nebulaMid).opacity(0.6),
                Color(hex: backgroundCard).opacity(0.85)
            ],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    static var nebulaGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: violet).opacity(0.3), Color(hex: cyan).opacity(0.15), .clear],
            startPoint: .topLeading, endPoint: .bottomTrailing
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
