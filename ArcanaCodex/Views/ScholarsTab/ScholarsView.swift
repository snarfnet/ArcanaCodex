import SwiftUI

struct ScholarsView: View {
    @ObservedObject var vm: ArcanaViewModel
    @State private var selectedScholar = 0

    private let scholars = [
        ("Papus", "Tarot of the Bohemians (1892)"),
        ("A.E. Waite", "Pictorial Key to the Tarot (1911)"),
        ("P.D. Ouspensky", "Symbolism of the Tarot")
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                CosmicBackground()

                VStack(spacing: 0) {
                    // Scholar picker
                    Picker("Scholar", selection: $selectedScholar) {
                        ForEach(0..<3) { i in
                            Text(scholars[i].0).tag(i)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()

                    // Book title
                    Text(scholars[selectedScholar].1)
                        .font(.caption.italic())
                        .foregroundStyle(Color(hex: AppDesign.gold))
                        .padding(.bottom, 8)

                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(vm.majorArcana) { symbol in
                                scholarCard(symbol: symbol)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("古書の叡智")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private func scholarCard(symbol: ArcanaSymbol) -> some View {
        let interpretation: String? = {
            switch selectedScholar {
            case 0: return symbol.papusInterpretation
            case 1: return symbol.waiteInterpretation
            case 2: return symbol.ouspenskyInterpretation
            default: return nil
            }
        }()

        return CosmicCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(symbol.emoji)
                        .font(.title2)
                    VStack(alignment: .leading) {
                        Text("\(symbol.number). \(symbol.nameJa)")
                            .font(.headline)
                            .foregroundStyle(Color(hex: AppDesign.textPrimary))
                        Text(symbol.nameEn)
                            .font(.caption)
                            .foregroundStyle(Color(hex: AppDesign.textSecondary))
                    }
                    Spacer()
                    if let hebrew = symbol.hebrewLetter {
                        HebrewBadge(letter: hebrew)
                    }
                }

                if let text = interpretation {
                    Text(text)
                        .font(.body)
                        .foregroundStyle(Color(hex: AppDesign.textPrimary).opacity(0.85))
                        .lineSpacing(4)
                } else {
                    Text("この象徴に対する解釈は収録されていません")
                        .font(.body)
                        .foregroundStyle(Color(hex: AppDesign.textSecondary))
                }

                // Quote
                if !symbol.historicalQuote.isEmpty {
                    Divider().overlay(Color(hex: AppDesign.cyan).opacity(0.3))
                    Text(""\(symbol.historicalQuote)"")
                        .font(.caption.italic())
                        .foregroundStyle(Color(hex: AppDesign.goldLight))
                    Text("— \(symbol.quoteSource)")
                        .font(.caption2)
                        .foregroundStyle(Color(hex: AppDesign.textSecondary))
                }
            }
        }
    }
}
