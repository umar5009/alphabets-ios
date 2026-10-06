//
//  ProgressModels.swift
//  BabyAlphabetApp
//
//  Stage, badge, coin and leaderboard models plus the persisted
//  per-child progress store.
//

import Foundation

/// A badge earned by clearing a stage. Stage 1 always awards the Unicorn
/// badge; later stages award a themed badge from `Badge.icon`.
struct Badge: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let emoji: String
    let coinReward: Int

    static let unicorn = Badge(id: "unicorn", name: "Unicorn Hero", emoji: "🦄", coinReward: 5)
    static let star = Badge(id: "star", name: "Star Learner", emoji: "⭐️", coinReward: 5)
    static let rocket = Badge(id: "rocket", name: "Rocket Reader", emoji: "🚀", coinReward: 5)
    static let rainbow = Badge(id: "rainbow", name: "Rainbow Writer", emoji: "🌈", coinReward: 5)
    static let crown = Badge(id: "crown", name: "Alphabet Crown", emoji: "👑", coinReward: 5)
    static let trophy = Badge(id: "trophy", name: "Champion Trophy", emoji: "🏆", coinReward: 5)

    /// Ordered badge sequence: stage 1 -> unicorn, then one new badge
    /// every subsequent 5-letter group. Longer alphabets cycle themes
    /// but keep unique ids so each stage still awards coins.
    static let sequence: [Badge] = [.unicorn, .star, .rocket, .rainbow, .crown, .trophy]

    static func badge(forStageIndex index: Int) -> Badge {
        let template = sequence[index % sequence.count]
        if index < sequence.count {
            return template
        }
        // Unique id per stage so ProgressStore can award coins every time.
        return Badge(
            id: "\(template.id)-stage-\(index)",
            name: "\(template.name) \(index + 1)",
            emoji: template.emoji,
            coinReward: template.coinReward
        )
    }
}

/// A stage groups letters together. Stage 0 ("Getting Started") is a single
/// hero-intro stage covering the first letter only, per the product spec:
/// "user should start from stage 1 as a hero in making [the first] label."
/// Stage 1 onward splits the remaining alphabet into chunks of 5 letters.
struct Stage: Identifiable, Hashable {
    let id: Int
    let title: String
    let letterRange: Range<Int>   // indices into AppLanguage.letters
    let badge: Badge

    static func stages(for language: AppLanguage) -> [Stage] {
        let total = language.letters.count
        guard total > 0 else { return [] }

        var stages: [Stage] = []

        // Stage 0: the very first letter only — the "hero" onboarding stage.
        stages.append(Stage(id: 0, title: "Stage 1 · Be a Hero!", letterRange: 0..<1, badge: .badge(forStageIndex: 0)))

        // Remaining letters, chunked 5 at a time.
        var start = 1
        var stageNumber = 2
        var badgeIndex = 1
        while start < total {
            let end = min(start + 5, total)
            stages.append(Stage(id: stageNumber - 1,
                                 title: "Stage \(stageNumber) · \(total - start > 0 ? "Letters \(start + 1)–\(end)" : "")",
                                 letterRange: start..<end,
                                 badge: .badge(forStageIndex: badgeIndex)))
            start = end
            stageNumber += 1
            badgeIndex += 1
        }
        return stages
    }
}

/// One child's saved progress for a single language.
struct LanguageProgress: Codable, Hashable {
    var completedLetterIDs: Set<Int> = []
    var unlockedBadgeIDs: [String] = []
    var currentStageIndex: Int = 0
    var completedNumberIDs: Set<Int> = []
    var unlockedCountingBadgeIDs: [String] = []
    var currentCountingStageIndex: Int = 0

    enum CodingKeys: String, CodingKey {
        case completedLetterIDs, unlockedBadgeIDs, currentStageIndex
        case completedNumberIDs, unlockedCountingBadgeIDs, currentCountingStageIndex
    }

    init() {}

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        completedLetterIDs = try c.decodeIfPresent(Set<Int>.self, forKey: .completedLetterIDs) ?? []
        unlockedBadgeIDs = try c.decodeIfPresent([String].self, forKey: .unlockedBadgeIDs) ?? []
        currentStageIndex = try c.decodeIfPresent(Int.self, forKey: .currentStageIndex) ?? 0
        completedNumberIDs = try c.decodeIfPresent(Set<Int>.self, forKey: .completedNumberIDs) ?? []
        unlockedCountingBadgeIDs = try c.decodeIfPresent([String].self, forKey: .unlockedCountingBadgeIDs) ?? []
        currentCountingStageIndex = try c.decodeIfPresent(Int.self, forKey: .currentCountingStageIndex) ?? 0
    }

    var coinsEarned: Int {
        let letterCoins = unlockedBadgeIDs.reduce(0) { total, id in
            total + coinReward(forBadgeID: id)
        }
        let countingCoins = unlockedCountingBadgeIDs.reduce(0) { total, id in
            total + coinReward(forBadgeID: id)
        }
        return letterCoins + countingCoins
    }

    private func coinReward(forBadgeID id: String) -> Int {
        if let known = Badge.sequence.first(where: { $0.id == id }) {
            return known.coinReward
        }
        return Badge.sequence.first?.coinReward ?? 5
    }
}

/// One row of the leaderboard (supports local multi-profile play, e.g.
/// siblings sharing a device, or a mocked "friends" leaderboard).
struct LeaderboardEntry: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var avatarEmoji: String
    var totalCoins: Int
    var totalBadges: Int
    var lettersTraced: Int

    init(id: UUID = UUID(), name: String, avatarEmoji: String, totalCoins: Int, totalBadges: Int, lettersTraced: Int) {
        self.id = id
        self.name = name
        self.avatarEmoji = avatarEmoji
        self.totalCoins = totalCoins
        self.totalBadges = totalBadges
        self.lettersTraced = lettersTraced
    }
}

/// The full persisted state for the signed-in child profile.
struct ChildProfile: Codable {
    var name: String = "Little Learner"
    var avatarEmoji: String = "🧒"
    var progressByLanguage: [String: LanguageProgress] = [:]  // keyed by AppLanguage.rawValue
    /// Set once during first-launch language onboarding.
    var selectedLanguageRaw: String? = nil
    var mathProgress: MathProgress = MathProgress()

    enum CodingKeys: String, CodingKey {
        case name, avatarEmoji, progressByLanguage, selectedLanguageRaw, mathProgress
    }

    init() {}

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        name = try c.decodeIfPresent(String.self, forKey: .name) ?? "Little Learner"
        avatarEmoji = try c.decodeIfPresent(String.self, forKey: .avatarEmoji) ?? "🧒"
        progressByLanguage = try c.decodeIfPresent([String: LanguageProgress].self, forKey: .progressByLanguage) ?? [:]
        selectedLanguageRaw = try c.decodeIfPresent(String.self, forKey: .selectedLanguageRaw)
        mathProgress = try c.decodeIfPresent(MathProgress.self, forKey: .mathProgress) ?? MathProgress()
    }

    var selectedLanguage: AppLanguage? {
        guard let raw = selectedLanguageRaw else { return nil }
        return AppLanguage(rawValue: raw)
    }

    var hasSelectedLanguage: Bool { selectedLanguage != nil }

    func progress(for language: AppLanguage) -> LanguageProgress {
        progressByLanguage[language.rawValue] ?? LanguageProgress()
    }

    var totalCoins: Int {
        progressByLanguage.values.reduce(0) { $0 + $1.coinsEarned } + mathProgress.coinsEarned
    }

    var totalBadges: Int {
        progressByLanguage.values.reduce(0) { $0 + $1.unlockedBadgeIDs.count + $1.unlockedCountingBadgeIDs.count }
            + mathProgress.totalBadges
    }

    var totalLettersTraced: Int {
        progressByLanguage.values.reduce(0) {
            $0 + $1.completedLetterIDs.count + $1.completedNumberIDs.count
        }
    }
}
