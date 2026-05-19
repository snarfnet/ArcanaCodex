import SwiftUI

struct CosmicCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .background(AppDesign.cardGlassBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(hex: AppDesign.cyan).opacity(0.2), lineWidth: 1)
            )
    }
}

struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(Color(hex: AppDesign.cyan))
            Text(title)
                .font(.headline)
                .foregroundStyle(Color(hex: AppDesign.goldLight))
        }
    }
}

struct CosmicBackground: View {
    var body: some View {
        ZStack {
            AppDesign.cosmicBackground
                .ignoresSafeArea()
            AppDesign.nebulaGradient
                .ignoresSafeArea()
            StarField()
                .ignoresSafeArea()
        }
    }
}

struct StarField: View {
    var body: some View {
        Canvas { context, size in
            for i in 0..<80 {
                let seed = Double(i)
                let x = (sin(seed * 127.1 + 311.7) * 43758.5453).truncatingRemainder(dividingBy: 1.0).magnitude * size.width
                let y = (sin(seed * 269.5 + 183.3) * 43758.5453).truncatingRemainder(dividingBy: 1.0).magnitude * size.height
                let r = (sin(seed * 78.23) * 43758.5).truncatingRemainder(dividingBy: 1.0).magnitude * 1.5 + 0.3
                let alpha = (sin(seed * 42.17) * 43758.5).truncatingRemainder(dividingBy: 1.0).magnitude * 0.6 + 0.2
                context.fill(
                    Path(ellipseIn: CGRect(x: x, y: y, width: r, height: r)),
                    with: .color(.white.opacity(alpha))
                )
            }
        }
    }
}

struct HebrewBadge: View {
    let letter: String

    var body: some View {
        Text(letter.components(separatedBy: " ").first ?? letter)
            .font(.caption.bold())
            .foregroundStyle(Color(hex: AppDesign.cyan))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(hex: AppDesign.cyan).opacity(0.15))
            .clipShape(Capsule())
    }
}

struct ElementBadge: View {
    let element: String

    var body: some View {
        let (emoji, color) = elementInfo(element)
        HStack(spacing: 2) {
            Text(emoji)
                .font(.caption2)
            Text(element)
                .font(.caption2.bold())
        }
        .foregroundStyle(color)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(color.opacity(0.15))
        .clipShape(Capsule())
    }

    private func elementInfo(_ e: String) -> (String, Color) {
        switch e {
        case "火": return ("🔥", Color.orange)
        case "水": return ("💧", Color.blue)
        case "風": return ("💨", Color(hex: AppDesign.cyan))
        case "地": return ("🌍", Color.green)
        default: return ("✦", Color(hex: AppDesign.violet))
        }
    }
}
