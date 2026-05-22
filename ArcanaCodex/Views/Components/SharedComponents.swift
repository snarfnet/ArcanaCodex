import SwiftUI

struct CosmicCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .background {
                ZStack {
                    AppDesign.cardGlassBackground
                    Image("tarot-ornament")
                        .resizable()
                        .scaledToFill()
                        .opacity(0.055)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color(hex: AppDesign.antiqueGold).opacity(0.62),
                                Color(hex: AppDesign.verdigrisLight).opacity(0.16),
                                Color(hex: AppDesign.antiqueGoldDark).opacity(0.42)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.34), radius: 14, x: 0, y: 8)
    }
}

struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 9) {
            Image(systemName: icon)
                .font(.caption.bold())
                .foregroundStyle(Color(hex: AppDesign.ink))
                .frame(width: 22, height: 22)
                .background(Color(hex: AppDesign.antiqueGold))
                .clipShape(Circle())

            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(Color(hex: AppDesign.antiqueGoldLight))

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: AppDesign.antiqueGold).opacity(0.45),
                            Color(hex: AppDesign.antiqueGoldDark).opacity(0.05)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
        }
    }
}

struct CosmicBackground: View {
    var body: some View {
        ZStack {
            AppDesign.cosmicBackground
                .ignoresSafeArea()

            Image("codex-atelier")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(0.28)
                .overlay(Color(hex: AppDesign.ink).opacity(0.56))
                .blur(radius: 1.2)

            AppDesign.nebulaGradient
                .ignoresSafeArea()

            ManuscriptGrain()
                .ignoresSafeArea()
                .opacity(0.22)
        }
    }
}

struct ManuscriptGrain: View {
    var body: some View {
        Canvas { context, size in
            for i in 0..<130 {
                let seed = Double(i)
                let x = pseudo(seed, 127.1, 311.7) * size.width
                let y = pseudo(seed, 269.5, 183.3) * size.height
                let w = pseudo(seed, 78.23, 91.4) * 2.1 + 0.4
                let alpha = pseudo(seed, 42.17, 17.9) * 0.22 + 0.05
                context.fill(
                    Path(ellipseIn: CGRect(x: x, y: y, width: w, height: w)),
                    with: .color(Color(hex: AppDesign.parchment).opacity(alpha))
                )
            }
        }
    }

    private func pseudo(_ seed: Double, _ a: Double, _ b: Double) -> Double {
        (sin(seed * a + b) * 43758.5453).truncatingRemainder(dividingBy: 1.0).magnitude
    }
}

struct MasterHero: View {
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image("codex-atelier")
                .resizable()
                .scaledToFill()
                .frame(maxHeight: 300)
                .clipped()

            LinearGradient(
                colors: [.clear, Color(hex: AppDesign.ink).opacity(0.92)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 9) {
                Text("ARCANA LIBRARY")
                    .font(.caption.weight(.bold))
                    .tracking(2.4)
                    .foregroundStyle(Color(hex: AppDesign.antiqueGoldLight))

                Text("巨匠の書斎で\nタロットを読む")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(Color(hex: AppDesign.textPrimary))
                    .lineSpacing(2)
                    .minimumScaleFactor(0.82)

                Text("Papus、Waite、Ouspenskyの解釈を、象徴・生命の樹・占星術からたどる。")
                    .font(.subheadline)
                    .foregroundStyle(Color(hex: AppDesign.textSecondary))
                    .lineSpacing(3)
                    .lineLimit(3)
                    .minimumScaleFactor(0.75)
            }
            .padding(18)
        }
        .frame(minHeight: 220, maxHeight: 300)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hex: AppDesign.antiqueGold).opacity(0.55), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.44), radius: 18, x: 0, y: 10)
    }
}

struct ChapterBanner: View {
    let title: String
    let subtitle: String
    let icon: String

    var body: some View {
        CosmicCard {
            HStack(spacing: 14) {
                Image("tarot-ornament")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 62, height: 62)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(hex: AppDesign.antiqueGold).opacity(0.55), lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: 5) {
                    Label(title, systemImage: icon)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color(hex: AppDesign.textPrimary))
                        .minimumScaleFactor(0.8)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color(hex: AppDesign.textSecondary))
                        .lineLimit(3)
                        .minimumScaleFactor(0.75)
                }

                Spacer(minLength: 0)
            }
        }
    }
}

struct HebrewBadge: View {
    let letter: String

    var body: some View {
        Text(letter.components(separatedBy: " ").first ?? letter)
            .font(.caption.bold())
            .foregroundStyle(Color(hex: AppDesign.antiqueGoldLight))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(hex: AppDesign.antiqueGoldDark).opacity(0.28))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color(hex: AppDesign.antiqueGold).opacity(0.35), lineWidth: 1))
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
        .background(color.opacity(0.16))
        .clipShape(Capsule())
        .overlay(Capsule().stroke(color.opacity(0.28), lineWidth: 1))
    }

    private func elementInfo(_ e: String) -> (String, Color) {
        switch e {
        case "火": return ("🔥", Color(hex: "#D7853B"))
        case "水": return ("💧", Color(hex: "#5D8CA8"))
        case "風": return ("💨", Color(hex: AppDesign.verdigrisLight))
        case "地": return ("🌍", Color(hex: "#6DA264"))
        default: return ("✦", Color(hex: AppDesign.antiqueGold))
        }
    }
}
