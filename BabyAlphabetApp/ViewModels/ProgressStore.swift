//
//  ProgressStore.swift
//  BabyAlphabetApp
//
//  Single source of truth for the child's saved progress, badges and
//  coins. Persists to UserDefaults as JSON — swap for SwiftData/CloudKit
//  if you want cross-device sync later.
//

import Foundation
import SwiftUI

@MainActor
final class ProgressStore: ObservableObject {
    static let shared = ProgressStore()

    @Published private(set) var profile: ChildProfile
    @Published private(set) var selectedLanguage: AppLanguage = .english

    /// Set right after a badge is unlocked so the UI can show the
    /// celebration overlay (confetti + clapping) exactly once.
    @Published var justUnlockedBadge: Badge?

    private let defaultsKey = "com.babyalphabetapp.childProfile"

    private init() {
        if let data = UserDefaults.standard.data(forKey: "com.babyalphabetapp.childProfile"),
           let decoded = try? JSONDecoder().decode(ChildProfile.self, from: data) {
            self.profile = decoded
        } else {
            self.profile = ChildProfile()
        }
        if let language = profile.selectedLanguage {
            selectedLanguage = language
        } else if let raw = profile.progressByLanguage.keys.sorted().first,
                  let migrated = AppLanguage(rawValue: raw) {
            // Existing installs that already traced letters skip the welcome screen.
            selectedLanguage = migrated
            profile.selectedLanguageRaw = migrated.rawValue
            save()
        }
    }

    var hasSelectedLanguage: Bool { profile.hasSelectedLanguage }

    // MARK: - Language setup

    func selectLanguage(_ language: AppLanguage) {
        selectedLanguage = language
        profile.selectedLanguageRaw = language.rawValue
        save()
    }

    // MARK: - Reading progress

    func stages(for language: AppLanguage) -> [Stage] {
        Stage.stages(for: language)
    }

    func countingStages() -> [CountingStage] {
        CountingStage.stages()
    }

    func isLetterCompleted(_ letter: LetterItem, language: AppLanguage) -> Bool {
        profile.progress(for: language).completedLetterIDs.contains(letter.id)
    }

    func isNumberCompleted(_ number: NumberItem, language: AppLanguage) -> Bool {
        profile.progress(for: language).completedNumberIDs.contains(number.id)
    }

    func isStageUnlocked(_ stage: Stage, language: AppLanguage) -> Bool {
        stage.id == 0 || profile.progress(for: language).currentStageIndex >= stage.id
    }

    func isCountingStageUnlocked(_ stage: CountingStage, language: AppLanguage) -> Bool {
        stage.id == 0 || profile.progress(for: language).currentCountingStageIndex >= stage.id
    }

    func isStageCompleted(_ stage: Stage, language: AppLanguage) -> Bool {
        let progress = profile.progress(for: language)
        return stage.letterRange.allSatisfy { progress.completedLetterIDs.contains($0) }
    }

    func isCountingStageCompleted(_ stage: CountingStage, language: AppLanguage) -> Bool {
        let progress = profile.progress(for: language)
        return stage.numberRange.allSatisfy { progress.completedNumberIDs.contains($0) }
    }

    func hasBadge(_ badge: Badge, language: AppLanguage) -> Bool {
        profile.progress(for: language).unlockedBadgeIDs.contains(badge.id)
    }

    func hasCountingBadge(_ badge: Badge, language: AppLanguage) -> Bool {
        profile.progress(for: language).unlockedCountingBadgeIDs.contains(badge.id)
    }

    // MARK: - Recording progress

    /// Call when the child successfully traces a letter.
    func markLetterCompleted(_ letter: LetterItem, language: AppLanguage) {
        var progress = profile.progress(for: language)
        progress.completedLetterIDs.insert(letter.id)
        profile.progressByLanguage[language.rawValue] = progress
        save()

        checkForStageCompletion(language: language)
    }

    func markNumberCompleted(_ number: NumberItem, language: AppLanguage) {
        var progress = profile.progress(for: language)
        progress.completedNumberIDs.insert(number.id)
        profile.progressByLanguage[language.rawValue] = progress
        save()

        checkForCountingStageCompletion(language: language)
    }

    // MARK: - Math

    func mathCorrectCount(for operation: MathOperation) -> Int {
        profile.mathProgress.correctCount(for: operation)
    }

    func hasMathBadge(_ badge: MathBadge) -> Bool {
        profile.mathProgress.unlockedBadgeIDs.contains(badge.id)
    }

    /// Returns true when the answer is correct (and progress was updated).
    @discardableResult
    func submitMathAnswer(question: MathQuestion, answerText: String) -> Bool {
        guard let value = Int(answerText.trimmingCharacters(in: .whitespacesAndNewlines)),
              value == question.answer else {
            return false
        }

        var math = profile.mathProgress
        let key = question.operation.rawValue
        let newCount = (math.correctCounts[key] ?? 0) + 1
        math.correctCounts[key] = newCount

        var newlyUnlocked: MathBadge?
        for badge in MathBadge.badges(for: question.operation) {
            if newCount >= badge.threshold, !math.unlockedBadgeIDs.contains(badge.id) {
                math.unlockedBadgeIDs.append(badge.id)
                newlyUnlocked = badge
            }
        }

        profile.mathProgress = math
        save()

        if let mathBadge = newlyUnlocked {
            let name = L10n(selectedLanguage).mathBadgeName(mathBadge)
            justUnlockedBadge = Badge(
                id: mathBadge.id,
                name: name,
                emoji: mathBadge.emoji,
                coinReward: mathBadge.coinReward
            )
            SoundManager.shared.playBadgeUnlock()
        }

        return true
    }

    private func checkForStageCompletion(language: AppLanguage) {
        let stages = stages(for: language)
        var progress = profile.progress(for: language)
        var didChange = false
        var newlyUnlocked: Badge?

        for stage in stages where isStageCompleted(stage, language: language) {
            let nextIndex = stage.id + 1
            if progress.currentStageIndex < nextIndex {
                progress.currentStageIndex = nextIndex
                didChange = true
            }

            if !progress.unlockedBadgeIDs.contains(stage.badge.id) {
                progress.unlockedBadgeIDs.append(stage.badge.id)
                newlyUnlocked = stage.badge
                didChange = true
            }
        }

        if didChange {
            profile.progressByLanguage[language.rawValue] = progress
            save()
        }

        if let badge = newlyUnlocked {
            justUnlockedBadge = badge
            SoundManager.shared.playBadgeUnlock()
        }
    }

    private func checkForCountingStageCompletion(language: AppLanguage) {
        let stages = countingStages()
        var progress = profile.progress(for: language)
        var didChange = false
        var newlyUnlocked: Badge?

        for stage in stages where isCountingStageCompleted(stage, language: language) {
            let nextIndex = stage.id + 1
            if progress.currentCountingStageIndex < nextIndex {
                progress.currentCountingStageIndex = nextIndex
                didChange = true
            }

            if !progress.unlockedCountingBadgeIDs.contains(stage.badge.id) {
                progress.unlockedCountingBadgeIDs.append(stage.badge.id)
                newlyUnlocked = stage.badge
                didChange = true
            }
        }

        if didChange {
            profile.progressByLanguage[language.rawValue] = progress
            save()
        }

        if let badge = newlyUnlocked {
            justUnlockedBadge = badge
            SoundManager.shared.playBadgeUnlock()
        }
    }

    func dismissBadgeCelebration() {
        justUnlockedBadge = nil
    }

    func updateProfile(name: String, avatarEmoji: String) {
        profile.name = name
        profile.avatarEmoji = avatarEmoji
        save()
    }

    // MARK: - Leaderboard

    /// Local leaderboard: the real child profile plus a handful of
    /// friendly mock rivals so the board never looks empty. Replace the
    /// mock entries with a real backend/GameKit leaderboard when ready.
    func leaderboardEntries() -> [LeaderboardEntry] {
        let me = LeaderboardEntry(
            name: profile.name,
            avatarEmoji: profile.avatarEmoji,
            totalCoins: profile.totalCoins,
            totalBadges: profile.totalBadges,
            lettersTraced: profile.totalLettersTraced
        )
        let mockRivals: [LeaderboardEntry] = [
            LeaderboardEntry(name: "Mia", avatarEmoji: "🦁", totalCoins: 40, totalBadges: 6, lettersTraced: 28),
            LeaderboardEntry(name: "Noah", avatarEmoji: "🐼", totalCoins: 25, totalBadges: 4, lettersTraced: 19),
            LeaderboardEntry(name: "Zara", avatarEmoji: "🐰", totalCoins: 15, totalBadges: 2, lettersTraced: 11),
            LeaderboardEntry(name: "Omar", avatarEmoji: "🐯", totalCoins: 10, totalBadges: 1, lettersTraced: 6)
        ]
        return (mockRivals + [me]).sorted { $0.totalCoins > $1.totalCoins }
    }

    // MARK: - Persistence

    private func save() {
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: defaultsKey)
        }
    }

    /// Debug/testing helper to wipe all progress.
    func resetAllProgress() {
        profile = ChildProfile()
        selectedLanguage = .english
        save()
    }
}
