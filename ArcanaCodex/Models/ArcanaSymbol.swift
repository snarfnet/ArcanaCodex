import SwiftUI

struct ArcanaSymbol: Codable, Identifiable {
    let id: String
    let number: Int
    let nameJa: String
    let nameEn: String
    let arcana: String
    let suit: String?
    let emoji: String
    let hebrewLetter: String?
    let hebrewMeaning: String?
    let planet: String?
    let zodiac: String?
    let element: String?
    let symbolism: String
    let uprightJa: String
    let reversedJa: String
    let uprightKeywords: [String]
    let reversedKeywords: [String]
    let papusInterpretation: String?
    let waiteInterpretation: String?
    let ouspenskyInterpretation: String?
    let historicalQuote: String
    let quoteSource: String
    let color: String
    let imageName: String?

    var isMajor: Bool { arcana == "major" }

    var treeOfLifePath: String? {
        guard isMajor else { return nil }
        return Self.kabbalisticPaths[number]
    }

    var treeOfLifeSephiroth: (String, String)? {
        guard isMajor else { return nil }
        return Self.pathConnections[number]
    }

    // 22 paths on the Tree of Life corresponding to Major Arcana
    static let kabbalisticPaths: [Int: String] = [
        0: "11th Path", 1: "12th Path", 2: "13th Path", 3: "14th Path",
        4: "15th Path", 5: "16th Path", 6: "17th Path", 7: "18th Path",
        8: "19th Path", 9: "20th Path", 10: "21st Path", 11: "22nd Path",
        12: "23rd Path", 13: "24th Path", 14: "25th Path", 15: "26th Path",
        16: "27th Path", 17: "28th Path", 18: "29th Path", 19: "30th Path",
        20: "31st Path", 21: "32nd Path"
    ]

    // Sephiroth connections for each path
    static let pathConnections: [Int: (String, String)] = [
        0: ("ケテル (Crown)", "コクマー (Wisdom)"),
        1: ("ケテル (Crown)", "ビナー (Understanding)"),
        2: ("ケテル (Crown)", "ティファレト (Beauty)"),
        3: ("コクマー (Wisdom)", "ビナー (Understanding)"),
        4: ("コクマー (Wisdom)", "ティファレト (Beauty)"),
        5: ("コクマー (Wisdom)", "ケセド (Mercy)"),
        6: ("ビナー (Understanding)", "ティファレト (Beauty)"),
        7: ("ビナー (Understanding)", "ゲブラー (Severity)"),
        8: ("ケセド (Mercy)", "ゲブラー (Severity)"),
        9: ("ケセド (Mercy)", "ティファレト (Beauty)"),
        10: ("ケセド (Mercy)", "ネツァク (Victory)"),
        11: ("ゲブラー (Severity)", "ティファレト (Beauty)"),
        12: ("ゲブラー (Severity)", "ホド (Splendor)"),
        13: ("ティファレト (Beauty)", "ネツァク (Victory)"),
        14: ("ティファレト (Beauty)", "イェソド (Foundation)"),
        15: ("ティファレト (Beauty)", "ホド (Splendor)"),
        16: ("ネツァク (Victory)", "ホド (Splendor)"),
        17: ("ネツァク (Victory)", "イェソド (Foundation)"),
        18: ("ネツァク (Victory)", "マルクト (Kingdom)"),
        19: ("ホド (Splendor)", "イェソド (Foundation)"),
        20: ("ホド (Splendor)", "マルクト (Kingdom)"),
        21: ("イェソド (Foundation)", "マルクト (Kingdom)")
    ]
}

enum ArcanaSuit: String, CaseIterable {
    case wands, cups, swords, pentacles

    var nameJa: String {
        switch self {
        case .wands: return "ワンド（杖）"
        case .cups: return "カップ（杯）"
        case .swords: return "ソード（剣）"
        case .pentacles: return "ペンタクル（金貨）"
        }
    }

    var element: String {
        switch self {
        case .wands: return "火 Fire"
        case .cups: return "水 Water"
        case .swords: return "風 Air"
        case .pentacles: return "地 Earth"
        }
    }

    var emoji: String {
        switch self {
        case .wands: return "🔥"
        case .cups: return "💧"
        case .swords: return "💨"
        case .pentacles: return "🌍"
        }
    }

    var numerologyMeaning: [Int: String] {
        [
            1: "始まり・純粋なエネルギー",
            2: "二元性・選択・均衡",
            3: "創造・拡張・表現",
            4: "安定・構造・基盤",
            5: "変化・葛藤・自由",
            6: "調和・責任・美",
            7: "内省・探求・神秘",
            8: "力・変容・支配",
            9: "完成・叡智・達成",
            10: "終焉と再生・循環の完結"
        ]
    }
}

// 10 Sephiroth for Tree of Life view
struct Sephirah: Identifiable {
    let id: Int
    let nameHe: String
    let nameJa: String
    let nameEn: String
    let meaning: String
    let position: CGPoint // normalized 0-1

    static let all: [Sephirah] = [
        Sephirah(id: 1, nameHe: "כתר", nameJa: "ケテル", nameEn: "Crown", meaning: "神性の意志・万物の根源", position: CGPoint(x: 0.5, y: 0.05)),
        Sephirah(id: 2, nameHe: "חכמה", nameJa: "コクマー", nameEn: "Wisdom", meaning: "原初の知恵・父性原理", position: CGPoint(x: 0.75, y: 0.15)),
        Sephirah(id: 3, nameHe: "בינה", nameJa: "ビナー", nameEn: "Understanding", meaning: "理解・母性原理・形を与える力", position: CGPoint(x: 0.25, y: 0.15)),
        Sephirah(id: 4, nameHe: "חסד", nameJa: "ケセド", nameEn: "Mercy", meaning: "慈悲・拡張・豊かさ", position: CGPoint(x: 0.75, y: 0.35)),
        Sephirah(id: 5, nameHe: "גבורה", nameJa: "ゲブラー", nameEn: "Severity", meaning: "峻厳・制限・浄化の力", position: CGPoint(x: 0.25, y: 0.35)),
        Sephirah(id: 6, nameHe: "תפארת", nameJa: "ティファレト", nameEn: "Beauty", meaning: "美・調和・太陽の中心", position: CGPoint(x: 0.5, y: 0.45)),
        Sephirah(id: 7, nameHe: "נצח", nameJa: "ネツァク", nameEn: "Victory", meaning: "勝利・永続・感情の力", position: CGPoint(x: 0.75, y: 0.6)),
        Sephirah(id: 8, nameHe: "הוד", nameJa: "ホド", nameEn: "Splendor", meaning: "栄光・知性・分析力", position: CGPoint(x: 0.25, y: 0.6)),
        Sephirah(id: 9, nameHe: "יסוד", nameJa: "イェソド", nameEn: "Foundation", meaning: "基盤・無意識・月の領域", position: CGPoint(x: 0.5, y: 0.75)),
        Sephirah(id: 10, nameHe: "מלכות", nameJa: "マルクト", nameEn: "Kingdom", meaning: "王国・物質世界・顕現", position: CGPoint(x: 0.5, y: 0.92)),
    ]
}
