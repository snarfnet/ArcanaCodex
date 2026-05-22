import SwiftUI

struct SymbolsListView: View {
    @ObservedObject var vm: ArcanaViewModel
    @State private var selectedSymbol: ArcanaSymbol?

    var body: some View {
        NavigationStack {
            ZStack {
                CosmicBackground()

                ScrollView {
                    LazyVStack(spacing: 12) {
                        MasterHero()
                            .padding(.bottom, 8)

                        ForEach(vm.filteredSymbols.filter { $0.isMajor }.sorted { $0.number < $1.number }) { symbol in
                            SymbolRow(symbol: symbol)
                                .onTapGesture { selectedSymbol = symbol }
                        }
                    }
                    .padding()
                    .searchable(text: $vm.searchText, prompt: "カード、天体、元素を検索")
                }
            }
            .navigationTitle("Arcana Library")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(item: $selectedSymbol) { symbol in
                SymbolDetailView(symbol: symbol)
            }
        }
    }
}

struct SymbolRow: View {
    let symbol: ArcanaSymbol

    var body: some View {
        CosmicCard {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color(hex: AppDesign.ink).opacity(0.62))
                        .frame(width: 54, height: 54)
                    Circle()
                        .stroke(Color(hex: AppDesign.antiqueGold).opacity(0.52), lineWidth: 1)
                        .frame(width: 54, height: 54)
                    Text("\(symbol.number)")
                        .font(.title2.bold())
                        .foregroundStyle(Color(hex: AppDesign.antiqueGoldLight))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(symbol.nameJa)
                        .font(.headline)
                        .foregroundStyle(Color(hex: AppDesign.textPrimary))
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                    Text(symbol.nameEn)
                        .font(.subheadline)
                        .foregroundStyle(Color(hex: AppDesign.textSecondary))
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)

                    HStack(spacing: 6) {
                        if let hebrew = symbol.hebrewLetter {
                            HebrewBadge(letter: hebrew)
                        }
                        if let element = symbol.element {
                            ElementBadge(element: element)
                        }
                        if let planet = symbol.planet {
                            Text(planet)
                                .font(.caption2)
                                .foregroundStyle(Color(hex: AppDesign.rose))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color(hex: AppDesign.rose).opacity(0.15))
                                .clipShape(Capsule())
                        }
                    }
                }

                Spacer()

                Text(symbol.emoji)
                    .font(.title2)
                    .frame(width: 42, height: 54)
                    .background(Color(hex: AppDesign.backgroundDark).opacity(0.42))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}

struct SymbolDetailView: View {
    let symbol: ArcanaSymbol
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                CosmicBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header
                        headerSection

                        // Correspondences
                        correspondencesSection

                        // Symbolism
                        sectionCard(title: "象徴解説", icon: "eye", content: symbol.symbolism)

                        // Tree of Life
                        if let path = symbol.treeOfLifePath, let sephiroth = symbol.treeOfLifeSephiroth {
                            treePathSection(path: path, from: sephiroth.0, to: sephiroth.1)
                        }

                        // Keywords
                        keywordsSection

                        // Three Scholars
                        scholarsSection

                        // Historical Quote
                        quoteSection
                    }
                    .padding()
                }
            }
            .navigationTitle(symbol.nameJa)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") { dismiss() }
                        .foregroundStyle(Color(hex: AppDesign.cyan))
                }
            }
        }
    }

    private var headerSection: some View {
        CosmicCard {
            VStack(spacing: 12) {
                Text(symbol.emoji)
                    .font(.system(size: 60))
                Text(symbol.nameJa)
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(Color(hex: AppDesign.textPrimary))
                    .minimumScaleFactor(0.7)
                Text("\(symbol.number) — \(symbol.nameEn)")
                    .font(.title3)
                    .foregroundStyle(Color(hex: AppDesign.antiqueGoldLight))
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var correspondencesSection: some View {
        CosmicCard {
            VStack(alignment: .leading, spacing: 10) {
                SectionHeader(title: "対応表", icon: "link")
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    if let hebrew = symbol.hebrewLetter {
                        correspondenceItem("ヘブライ文字", hebrew)
                    }
                    if let meaning = symbol.hebrewMeaning {
                        correspondenceItem("文字の意味", meaning)
                    }
                    if let planet = symbol.planet {
                        correspondenceItem("天体", planet)
                    }
                    if let element = symbol.element {
                        correspondenceItem("元素", element)
                    }
                    if let path = symbol.treeOfLifePath {
                        correspondenceItem("生命の樹", path)
                    }
                }
            }
        }
    }

    private func correspondenceItem(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundStyle(Color(hex: AppDesign.textSecondary))
            Text(value)
                .font(.subheadline.bold())
                .foregroundStyle(Color(hex: AppDesign.textPrimary))
                .lineLimit(2)
                .minimumScaleFactor(0.75)
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: AppDesign.ink).opacity(0.48))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func sectionCard(title: String, icon: String, content: String) -> some View {
        CosmicCard {
            VStack(alignment: .leading, spacing: 8) {
                SectionHeader(title: title, icon: icon)
                Text(content)
                    .font(.body)
                    .foregroundStyle(Color(hex: AppDesign.textPrimary).opacity(0.9))
                    .lineSpacing(4)
            }
        }
    }

    private func treePathSection(path: String, from: String, to: String) -> some View {
        CosmicCard {
            VStack(alignment: .leading, spacing: 8) {
                SectionHeader(title: "カバラ生命の樹", icon: "point.3.connected.trianglepath.dotted")
                HStack {
                    Text(from)
                        .font(.caption.bold())
                        .foregroundStyle(Color(hex: AppDesign.antiqueGoldLight))
                    Image(systemName: "arrow.right")
                        .foregroundStyle(Color(hex: AppDesign.gold))
                    Text(to)
                        .font(.caption.bold())
                        .foregroundStyle(Color(hex: AppDesign.antiqueGoldLight))
                }
                Text(path)
                    .font(.subheadline)
                    .foregroundStyle(Color(hex: AppDesign.textSecondary))
            }
        }
    }

    private var keywordsSection: some View {
        CosmicCard {
            VStack(alignment: .leading, spacing: 10) {
                SectionHeader(title: "象徴キーワード", icon: "tag")
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

    private var scholarsSection: some View {
        VStack(spacing: 12) {
            if let papus = symbol.papusInterpretation {
                sectionCard(title: "Papus (1892)", icon: "book.closed", content: papus)
            }
            if let waite = symbol.waiteInterpretation {
                sectionCard(title: "A.E. Waite (1911)", icon: "book.closed", content: waite)
            }
            if let ouspensky = symbol.ouspenskyInterpretation {
                sectionCard(title: "P.D. Ouspensky", icon: "book.closed", content: ouspensky)
            }
        }
    }

    private var quoteSection: some View {
        CosmicCard {
            VStack(spacing: 8) {
                Text("\"\(symbol.historicalQuote)\"")
                    .font(.body.italic())
                    .foregroundStyle(Color(hex: AppDesign.goldLight))
                    .multilineTextAlignment(.center)
                Text("— \(symbol.quoteSource)")
                    .font(.caption)
                    .foregroundStyle(Color(hex: AppDesign.textSecondary))
            }
            .frame(maxWidth: .infinity)
        }
    }
}
