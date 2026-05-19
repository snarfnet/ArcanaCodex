import SwiftUI

@MainActor
class ArcanaViewModel: ObservableObject {
    @Published var symbols: [ArcanaSymbol] = []
    @Published var searchText = ""

    var majorArcana: [ArcanaSymbol] {
        symbols.filter { $0.isMajor }.sorted { $0.number < $1.number }
    }

    var minorArcana: [ArcanaSymbol] {
        symbols.filter { !$0.isMajor }
    }

    func minorBySuit(_ suit: ArcanaSuit) -> [ArcanaSymbol] {
        minorArcana.filter { $0.suit == suit.rawValue }.sorted { $0.number < $1.number }
    }

    var filteredSymbols: [ArcanaSymbol] {
        guard !searchText.isEmpty else { return symbols }
        let q = searchText.lowercased()
        return symbols.filter {
            $0.nameJa.lowercased().contains(q) ||
            $0.nameEn.lowercased().contains(q) ||
            ($0.hebrewLetter?.lowercased().contains(q) ?? false) ||
            ($0.element?.lowercased().contains(q) ?? false) ||
            ($0.planet?.lowercased().contains(q) ?? false)
        }
    }

    // Zodiac -> Major Arcana mapping
    var zodiacMapping: [(zodiac: String, symbol: String, arcana: ArcanaSymbol?)] {
        let map: [(String, String, Int)] = [
            ("牡羊座", "♈", 4),    // The Emperor
            ("牡牛座", "♉", 5),    // The Hierophant
            ("双子座", "♊", 6),    // The Lovers
            ("蟹座", "♋", 7),     // The Chariot
            ("獅子座", "♌", 8),    // Strength
            ("乙女座", "♍", 9),    // The Hermit
            ("天秤座", "♎", 11),   // Justice
            ("蠍座", "♏", 13),    // Death
            ("射手座", "♐", 14),   // Temperance
            ("山羊座", "♑", 15),   // The Devil
            ("水瓶座", "♒", 17),   // The Star
            ("魚座", "♓", 18),    // The Moon
        ]
        return map.map { (z, s, n) in
            (z, s, majorArcana.first { $0.number == n })
        }
    }

    // Planet -> Major Arcana mapping
    var planetMapping: [(planet: String, symbol: String, arcana: [ArcanaSymbol])] {
        let planets = ["水星", "金星", "月", "太陽", "火星", "木星", "土星", "天王星", "海王星", "冥王星"]
        let symbols = ["☿", "♀", "☽", "☉", "♂", "♃", "♄", "♅", "♆", "♇"]
        return zip(planets, symbols).map { (p, s) in
            (p, s, majorArcana.filter { $0.planet == p })
        }.filter { !$0.arcana.isEmpty }
    }

    init() {
        loadData()
    }

    private func loadData() {
        guard let url = Bundle.main.url(forResource: "arcana_symbols", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([ArcanaSymbol].self, from: data)
        else { return }
        symbols = decoded
    }
}
