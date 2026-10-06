//
//  RewardsView.swift
//  BabyAlphabetApp
//

import SwiftUI

struct RewardsView: View {
    @EnvironmentObject var store: ProgressStore

    private var language: AppLanguage { store.selectedLanguage }
    private var s: L10n { L10n(language) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    coinWallet

                    let progress = store.profile.progress(for: language)
                    let letterBadges = earnedLetterBadges(from: progress, language: language)
                    let countingBadges = earnedCountingBadges(from: progress)
                    let mathBadges = MathBadge.all.filter { store.hasMathBadge($0) }

                    if !letterBadges.isEmpty || !countingBadges.isEmpty {
                        badgeSection(
                            title: "\(language.flagEmoji) \(language.displayName)",
                            badges: letterBadges + countingBadges
                        )
                    }

                    if !mathBadges.isEmpty {
                        mathBadgeSection(mathBadges)
                    }

                    if store.profile.totalBadges == 0 {
                        emptyState
                    }
                }
                .padding()
            }
            .navigationTitle(s.myRewards)
        }
    }

    private var coinWallet: some View {
        HStack(spacing: 12) {
            Image(systemName: "dollarsign.circle.fill")
                .font(.system(size: 40))
                .foregroundStyle(.yellow)
            VStack(alignment: .leading) {
                Text(s.coinsCount(store.profile.totalCoins))
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                Text(s.earnCoinsHint)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(
            LinearGradient(colors: [.yellow.opacity(0.25), .orange.opacity(0.15)], startPoint: .leading, endPoint: .trailing),
            in: RoundedRectangle(cornerRadius: 20)
        )
    }

    private func badgeSection(title: String, badges: [Badge]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 16, weight: .bold, design: .rounded))

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 90))], spacing: 12) {
                ForEach(badges) { badge in
                    VStack(spacing: 6) {
                        Text(badge.emoji).font(.system(size: 40))
                        Text(s.badgeName(badge))
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                        Text("+\(badge.coinReward)")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundStyle(.orange)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(.background, in: RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                }
            }
        }
    }

    private func mathBadgeSection(_ badges: [MathBadge]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("🧮 \(s.tabMath)")
                .font(.system(size: 16, weight: .bold, design: .rounded))

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 90))], spacing: 12) {
                ForEach(badges) { badge in
                    VStack(spacing: 6) {
                        Text(badge.emoji).font(.system(size: 40))
                        Text(s.mathBadgeName(badge))
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                        Text("+\(badge.coinReward)")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundStyle(.orange)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(.background, in: RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                }
            }
        }
    }

    private func earnedLetterBadges(from progress: LanguageProgress, language: AppLanguage) -> [Badge] {
        let stageBadges = Stage.stages(for: language).map(\.badge)
        return progress.unlockedBadgeIDs.compactMap { id in
            stageBadges.first(where: { $0.id == id })
                ?? Badge.sequence.first(where: { $0.id == id })
        }
    }

    private func earnedCountingBadges(from progress: LanguageProgress) -> [Badge] {
        let stageBadges = CountingStage.stages().map(\.badge)
        return progress.unlockedCountingBadgeIDs.compactMap { id in
            stageBadges.first(where: { $0.id == id })
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Text("🎈").font(.system(size: 48))
            Text(s.noBadgesYet)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 40)
    }
}
