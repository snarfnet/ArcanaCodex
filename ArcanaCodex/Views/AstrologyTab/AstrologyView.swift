import SwiftUI

struct AstrologyView: View {
    @ObservedObject var vm: ArcanaViewModel
    @State private var selectedTab = 0
    @State private var selectedSymbol: ArcanaSymbol?

    var body: some View {
        NavigationStack {
            ZStack {
                CosmicBackground()

                VStack(spacing: 0) {
                    Picker("Category", selection: $selectedTab) {
                        Text("十二星座").tag(0)
                        Text("惑星").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding()

                    ScrollView {
                        LazyVStack(spacing: 12) {
                            if selectedTab == 0 {
                                zodiacSection
                            } else {
                                planetSection
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("天体と占星術")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(item: $selectedSymbol) { symbol in
                SymbolDetailView(symbol: symbol)
            }
        }
    }

    private var zodiacSection: some View {
        ForEach(vm.zodiacMapping, id: \.zodiac) { item in
            CosmicCard {
                HStack(spacing: 14) {
                    Text(item.symbol)
                        .font(.system(size: 36))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.zodiac)
                            .font(.headline)
                            .foregroundStyle(Color(hex: AppDesign.textPrimary))

                        if let arcana = item.arcana {
                            HStack(spacing: 4) {
                                Text(arcana.emoji)
                                Text("\(arcana.number). \(arcana.nameJa)")
                                    .font(.subheadline)
                                    .foregroundStyle(Color(hex: AppDesign.cyan))
                            }
                            Text(arcana.nameEn)
                                .font(.caption)
                                .foregroundStyle(Color(hex: AppDesign.textSecondary))
                        }
                    }

                    Spacer()

                    if let arcana = item.arcana {
                        if let element = arcana.element {
                            ElementBadge(element: element)
                        }
                    }
                }
            }
            .onTapGesture {
                if let arcana = item.arcana {
                    selectedSymbol = arcana
                }
            }
        }
    }

    private var planetSection: some View {
        ForEach(vm.planetMapping, id: \.planet) { item in
            CosmicCard {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(item.symbol)
                            .font(.system(size: 30))
                        Text(item.planet)
                            .font(.title3.bold())
                            .foregroundStyle(Color(hex: AppDesign.textPrimary))
                        Spacer()
                    }

                    ForEach(item.arcana) { arcana in
                        HStack(spacing: 8) {
                            Text(arcana.emoji)
                            Text("\(arcana.number). \(arcana.nameJa)")
                                .font(.subheadline)
                                .foregroundStyle(Color(hex: AppDesign.cyan))
                            Text(arcana.nameEn)
                                .font(.caption)
                                .foregroundStyle(Color(hex: AppDesign.textSecondary))
                            Spacer()
                            if let hebrew = arcana.hebrewLetter {
                                HebrewBadge(letter: hebrew)
                            }
                        }
                        .onTapGesture { selectedSymbol = arcana }
                    }
                }
            }
        }
    }
}
