//
//  MathModels.swift
//  BabyAlphabetApp
//
//  Basic arithmetic practice: 50+ questions each for +, −, ×, ÷.
//  A mathematics badge is earned every 10 correct answers per operation.
//

import Foundation

enum MathOperation: String, CaseIterable, Identifiable, Codable {
    case addition
    case subtraction
    case multiplication
    case division

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .addition: return "+"
        case .subtraction: return "−"
        case .multiplication: return "×"
        case .division: return "÷"
        }
    }

    var emoji: String {
        switch self {
        case .addition: return "➕"
        case .subtraction: return "➖"
        case .multiplication: return "✖️"
        case .division: return "➗"
        }
    }
}

struct MathQuestion: Identifiable, Hashable {
    let id: String
    let operation: MathOperation
    let left: Int
    let right: Int
    let answer: Int

    var prompt: String {
        "\(left) \(operation.symbol) \(right)"
    }
}

enum MathQuestionBank {
    static let questionsPerOperation = 55
    static let correctPerBadge = 10

    static func questions(for operation: MathOperation) -> [MathQuestion] {
        switch operation {
        case .addition: return addition
        case .subtraction: return subtraction
        case .multiplication: return multiplication
        case .division: return division
        }
    }

    /// Fisher–Yates with a fixed seed so order is mixed (not 1+1, 1+2…)
    /// but stable across launches for progress by index.
    private static func shuffled(_ input: [MathQuestion], seed: UInt64) -> [MathQuestion] {
        var list = input
        var state = seed == 0 ? 1 : seed
        func next() -> UInt64 {
            state = state &* 6364136223846793005 &+ 1
            return state
        }
        if list.count < 2 { return list }
        for i in stride(from: list.count - 1, through: 1, by: -1) {
            let j = Int(next() % UInt64(i + 1))
            list.swapAt(i, j)
        }
        return list
    }

    /// Build then shuffle so kids never see sequential patterns.
    static let addition: [MathQuestion] = {
        var list: [MathQuestion] = []
        for a in 1...12 {
            for b in 1...12 {
                list.append(MathQuestion(
                    id: "add-\(a)+\(b)",
                    operation: .addition,
                    left: a,
                    right: b,
                    answer: a + b
                ))
            }
        }
        var extra = 1
        while list.count < questionsPerOperation + 20 {
            let a = 13 + (extra % 8)
            let b = 1 + (extra % 10)
            list.append(MathQuestion(id: "add-\(a)+\(b)", operation: .addition, left: a, right: b, answer: a + b))
            extra += 1
        }
        return Array(shuffled(list, seed: 0xADD1_C001).prefix(questionsPerOperation))
    }()

    static let subtraction: [MathQuestion] = {
        var list: [MathQuestion] = []
        for a in 2...20 {
            for b in 1..<a {
                list.append(MathQuestion(
                    id: "sub-\(a)-\(b)",
                    operation: .subtraction,
                    left: a,
                    right: b,
                    answer: a - b
                ))
            }
        }
        return Array(shuffled(list, seed: 0x51B7_C001).prefix(questionsPerOperation))
    }()

    static let multiplication: [MathQuestion] = {
        var list: [MathQuestion] = []
        for a in 1...10 {
            for b in 1...10 {
                list.append(MathQuestion(
                    id: "mul-\(a)*\(b)",
                    operation: .multiplication,
                    left: a,
                    right: b,
                    answer: a * b
                ))
            }
        }
        return Array(shuffled(list, seed: 0xA117_C001).prefix(questionsPerOperation))
    }()

    static let division: [MathQuestion] = {
        var list: [MathQuestion] = []
        var seen = Set<String>()
        for divisor in 1...10 {
            for quotient in 1...12 {
                let dividend = divisor * quotient
                let id = "div-\(dividend)/\(divisor)"
                guard seen.insert(id).inserted else { continue }
                list.append(MathQuestion(
                    id: id,
                    operation: .division,
                    left: dividend,
                    right: divisor,
                    answer: quotient
                ))
            }
        }
        return Array(shuffled(list, seed: 0xD171_C001).prefix(questionsPerOperation))
    }()
}

struct MathBadge: Identifiable, Hashable {
    let id: String
    let operation: MathOperation
    let tier: Int
    let coinReward: Int

    var emoji: String { operation.emoji }
    var threshold: Int { tier * MathQuestionBank.correctPerBadge }

    static func badge(operation: MathOperation, tier: Int) -> MathBadge {
        MathBadge(
            id: "math-\(operation.rawValue)-tier-\(tier)",
            operation: operation,
            tier: tier,
            coinReward: 5
        )
    }

    static func badges(for operation: MathOperation) -> [MathBadge] {
        let maxTiers = MathQuestionBank.questionsPerOperation / MathQuestionBank.correctPerBadge
        return (1...maxTiers).map { badge(operation: operation, tier: $0) }
    }

    static var all: [MathBadge] {
        MathOperation.allCases.flatMap { badges(for: $0) }
    }
}

/// Persisted math progress (shared across languages).
struct MathProgress: Codable, Hashable {
    var correctCounts: [String: Int] = [:]
    var unlockedBadgeIDs: [String] = []

    enum CodingKeys: String, CodingKey {
        case correctCounts, unlockedBadgeIDs
    }

    init() {}

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        correctCounts = try c.decodeIfPresent([String: Int].self, forKey: .correctCounts) ?? [:]
        unlockedBadgeIDs = try c.decodeIfPresent([String].self, forKey: .unlockedBadgeIDs) ?? []
    }

    func correctCount(for operation: MathOperation) -> Int {
        correctCounts[operation.rawValue] ?? 0
    }

    var coinsEarned: Int { unlockedBadgeIDs.count * 5 }
    var totalBadges: Int { unlockedBadgeIDs.count }
}
