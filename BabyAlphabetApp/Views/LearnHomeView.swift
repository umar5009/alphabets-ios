//
//  LearnHomeView.swift
//  BabyAlphabetApp
//
//  Main Learn tab: alphabet stages + counting stages for the child's
//  chosen language (set once at onboarding).
//

import SwiftUI

struct LearnHomeView: View {
    @EnvironmentObject var store: ProgressStore
    @State private var activeLetterStage: Stage?
    @State private var activeCountingStage: CountingStage?
    @State private var showLanguagePicker = false

    private var language: AppLanguage { store.selectedLanguage }
    private var s: L10n { L10n(language) }

    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 14)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    greeting

                    languageBanner

                    if let note = language.writingNote {
                        Text(note)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                    }

                    sectionHeader(s.alphabets, systemImage: "textformat.abc")

                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(store.stages(for: language)) { stage in
                            StageGridCard(
                                stage: stage,
                                language: language,
                                isUnlocked: store.isStageUnlocked(stage, language: language),
                                isCompleted: store.isStageCompleted(stage, language: language),
                                hasBadge: store.hasBadge(stage.badge, language: language)
                            ) {
                                activeLetterStage = stage
                            }
                        }
                    }
                    .padding(.horizontal)

                    sectionHeader(s.counting, systemImage: "number")

                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(store.countingStages()) { stage in
                            CountingStageGridCard(
                                stage: stage,
                                language: language,
                                isUnlocked: store.isCountingStageUnlocked(stage, language: language),
                                isCompleted: store.isCountingStageCompleted(stage, language: language),
                                hasBadge: store.hasCountingBadge(stage.badge, language: language)
                            ) {
                                activeCountingStage = stage
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle(s.appTitle)
            .fullScreenCover(item: $activeLetterStage) { stage in
                StageLetterFlowView(stage: stage, language: language)
                    .environmentObject(store)
            }
            .fullScreenCover(item: $activeCountingStage) { stage in
                StageNumberFlowView(stage: stage, language: language)
                    .environmentObject(store)
            }
            .sheet(isPresented: $showLanguagePicker) {
                LanguageOnboardingView()
                    .environmentObject(store)
            }
        }
    }

    private var greeting: some View {
        HStack(spacing: 14) {
            Text(store.profile.avatarEmoji).font(.system(size: 48))
            VStack(alignment: .leading, spacing: 2) {
                Text(s.hiName(store.profile.name))
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                HStack(spacing: 10) {
                    Label("\(store.profile.totalBadges)", systemImage: "seal.fill")
                    Label("\(store.profile.totalCoins)", systemImage: "circlebadge.fill")
                }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal)
    }

    private var languageBanner: some View {
        HStack {
            Text("\(language.flagEmoji) \(language.displayName)")
                .font(.system(size: 17, weight: .bold, design: .rounded))
            Spacer()
            Button(s.change) { showLanguagePicker = true }
                .font(.system(size: 14, weight: .semibold, design: .rounded))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.purple.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal)
    }

    private func sectionHeader(_ title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(.system(size: 18, weight: .bold, design: .rounded))
            .padding(.horizontal)
    }
}

struct StageGridCard: View {
    let stage: Stage
    let language: AppLanguage
    let isUnlocked: Bool
    let isCompleted: Bool
    let hasBadge: Bool
    let action: () -> Void

    private var s: L10n { L10n(language) }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(isCompleted ? Color.green.opacity(0.2) : Color.purple.opacity(0.15))
                        .frame(width: 56, height: 56)
                    Text(stage.badge.emoji)
                        .font(.system(size: 28))
                        .opacity(isUnlocked ? 1 : 0.35)
                }

                Text(stage.localizedTitle(for: language))
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)

                Text(letterPreview)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                if hasBadge {
                    Label(s.earned, systemImage: "checkmark.seal.fill")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(.green)
                } else {
                    Image(systemName: isUnlocked ? "play.circle.fill" : "lock.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(isUnlocked ? .purple : .gray)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 160)
            .background(.background, in: RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
        }
        .disabled(!isUnlocked)
        .opacity(isUnlocked ? 1 : 0.55)
        .buttonStyle(.plain)
    }

    private var letterPreview: String {
        let letters = language.letters
        let slice = stage.letterRange.compactMap { idx in idx < letters.count ? letters[idx].character : nil }
        return slice.joined(separator: " ")
    }
}

struct CountingStageGridCard: View {
    let stage: CountingStage
    let language: AppLanguage
    let isUnlocked: Bool
    let isCompleted: Bool
    let hasBadge: Bool
    let action: () -> Void

    private var s: L10n { L10n(language) }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(isCompleted ? Color.green.opacity(0.2) : Color.orange.opacity(0.18))
                        .frame(width: 56, height: 56)
                    Text(stage.badge.emoji)
                        .font(.system(size: 28))
                        .opacity(isUnlocked ? 1 : 0.35)
                }

                Text(stage.localizedTitle(for: language))
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)

                Text("\(stage.numberRange.lowerBound)–\(stage.numberRange.upperBound)")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)

                if hasBadge {
                    Label(s.earned, systemImage: "checkmark.seal.fill")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(.green)
                } else {
                    Image(systemName: isUnlocked ? "play.circle.fill" : "lock.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(isUnlocked ? .orange : .gray)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 160)
            .background(.background, in: RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
        }
        .disabled(!isUnlocked)
        .opacity(isUnlocked ? 1 : 0.55)
        .buttonStyle(.plain)
    }
}
