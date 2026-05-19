import SwiftUI

struct ElementsView: View {
    @ObservedObject var vm: ArcanaViewModel
    @State private var selectedSuit: ArcanaSuit = .wands
    @State private var selectedSymbol: ArcanaSymbol?

    var body: some View {
        NavigationStack {
            ZStack {
                CosmicBackground()

                VStack(spacing: 0) {
                    // Suit picker
                    Picker("Suit", selection: $selectedSuit) {
                        ForEach(ArcanaSuit.allCases, id: \.self) { suit in
                            Text("\(suit.emoji) \(suit.nameJa)").tag(suit)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()

                    ChapterBanner(
                        title: selectedSuit.element,
                        subtitle: "\(selectedSuit.nameJa)の数秘と小アルカナを読む。",
                        icon: "flame"
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 8)

                    ScrollView {
                        LazyVStack(spacing: 12) {
                            // Numerology section
                            ForEach(vm.minorBySuit(selectedSuit)) { symbol in
                                minorCard(symbol: symbol)
                                    .onTapGesture { selectedSymbol = symbol }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("四元素と小アルカナ")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(item: $selectedSymbol) { symbol in
                minorDetailSheet(symbol: symbol)
            }
        }
    }

    private func minorCard(symbol: ArcanaSymbol) -> some View {
        CosmicCard {
            HStack(spacing: 12) {
                Text(symbol.emoji)
                    .font(.title2)

                VStack(alignment: .leading, spacing: 3) {
                    Text(symbol.nameJa)
                        .font(.subheadline.bold())
                        .foregroundStyle(Color(hex: AppDesign.textPrimary))
                    Text(symbol.nameEn)
                        .font(.caption)
                        .foregroundStyle(Color(hex: AppDesign.textSecondary))

                    // Numerology meaning
                    if let meaning = selectedSuit.numerologyMeaning[symbol.number] {
                        Text("数秘: \(meaning)")
                            .font(.caption2)
                            .foregroundStyle(Color(hex: AppDesign.goldLight))
                    }
                }

                Spacer()

                // Keywords
                VStack(alignment: .trailing, spacing: 2) {
                    ForEach(symbol.uprightKeywords.prefix(2), id: \.self) { kw in
                        Text(kw)
                            .font(.caption2)
                            .foregroundStyle(Color(hex: AppDesign.antiqueGoldLight))
                    }
                }
            }
        }
    }

    private func minorDetailSheet(symbol: ArcanaSymbol) -> some View {
        NavigationStack {
            ZStack {
                CosmicBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        CosmicCard {
                            VStack(spacing: 8) {
                                Text(symbol.emoji).font(.system(size: 50))
                                Text(symbol.nameJa).font(.title.bold())
                                    .foregroundStyle(Color(hex: AppDesign.textPrimary))
                                Text(symbol.nameEn).font(.subheadline)
                                    .foregroundStyle(Color(hex: AppDesign.antiqueGoldLight))
                            }
                            .frame(maxWidth: .infinity)
                        }

                        CosmicCard {
                            VStack(alignment: .leading, spacing: 8) {
                                SectionHeader(title: "象徴", icon: "eye")
                                Text(symbol.symbolism)
                                    .font(.body)
                                    .foregroundStyle(Color(hex: AppDesign.textPrimary).opacity(0.9))
                                    .lineSpacing(4)
                            }
                        }

                        CosmicCard {
                            VStack(alignment: .leading, spacing: 8) {
                                SectionHeader(title: "キーワード", icon: "tag")
                                FlowLayout(spacing: 6) {
                                    ForEach(symbol.uprightKeywords, id: \.self) { kw in
                                        Text(kw)
                                            .font(.caption.bold())
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(Color(hex: AppDesign.verdigris).opacity(0.28))
                                            .foregroundStyle(Color(hex: AppDesign.antiqueGoldLight))
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(symbol.nameJa)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(proposal: proposal, subviews: subviews)
        for (index, origin) in result.origins.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + origin.x, y: bounds.minY + origin.y), proposal: .unspecified)
        }
    }

    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, origins: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var origins: [CGPoint] = []
        var x: CGFloat = 0; var y: CGFloat = 0; var rowHeight: CGFloat = 0
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0; y += rowHeight + spacing; rowHeight = 0
            }
            origins.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }
        return (CGSize(width: maxWidth, height: y + rowHeight), origins)
    }
}
