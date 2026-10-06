//
//  NumberModels.swift
//  BabyAlphabetApp
//
//  Numbers 1–100 and counting stages (groups of 10), parallel to alphabet stages.
//

import Foundation

struct NumberItem: Identifiable, Hashable {
    /// The integer value 1…100 (also used as progress id).
    let id: Int

    var character: String { "\(id)" }
    var displayLabel: String { "\(id)" }

    var exampleEmoji: String {
        switch id {
        case 1: return "1️⃣"
        case 2: return "2️⃣"
        case 3: return "3️⃣"
        case 4: return "4️⃣"
        case 5: return "5️⃣"
        case 6: return "6️⃣"
        case 7: return "7️⃣"
        case 8: return "8️⃣"
        case 9: return "9️⃣"
        case 10: return "🔟"
        default: return "🔢"
        }
    }

    func spokenName(for language: AppLanguage) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        formatter.locale = Locale(identifier: language.speechLocaleIdentifier)
        return formatter.string(from: NSNumber(value: id)) ?? "\(id)"
    }

    static let all: [NumberItem] = (1...100).map { NumberItem(id: $0) }

    static func item(id: Int) -> NumberItem? {
        guard (1...100).contains(id) else { return nil }
        return NumberItem(id: id)
    }
}

/// Counting stages: ten groups of ten numbers (1–10, 11–20, …, 91–100).
struct CountingStage: Identifiable, Hashable {
    let id: Int
    let title: String
    let numberRange: ClosedRange<Int>
    let badge: Badge

    var numbers: [NumberItem] {
        numberRange.map { NumberItem(id: $0) }
    }

    static func stages() -> [CountingStage] {
        (0..<10).map { index in
            let start = index * 10 + 1
            let end = start + 9
            let title: String
            if index == 0 {
                title = "Stage 1 · Count to 10"
            } else {
                title = "Stage \(index + 1) · \(start)–\(end)"
            }
            return CountingStage(
                id: index,
                title: title,
                numberRange: start...end,
                badge: Badge.countingBadge(forStageIndex: index)
            )
        }
    }
}

extension Badge {
    static func countingBadge(forStageIndex index: Int) -> Badge {
        let template = sequence[index % sequence.count]
        return Badge(
            id: "count-\(template.id)-stage-\(index)",
            name: "\(template.name) Count \(index + 1)",
            emoji: template.emoji,
            coinReward: template.coinReward
        )
    }
}
