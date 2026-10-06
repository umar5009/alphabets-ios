//
//  StageLetterFlowView.swift
//  BabyAlphabetApp
//

import SwiftUI

struct StageLetterFlowView: View {
    let stage: Stage
    let language: AppLanguage

    @EnvironmentObject var store: ProgressStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var currentIndex: Int = 0

    private var s: L10n { L10n(language) }

    private var letters: [LetterItem] {
        let all = language.letters
        return stage.letterRange.compactMap { $0 < all.count ? all[$0] : nil }
    }

    private var isRegularWidth: Bool {
        horizontalSizeClass == .regular
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color.purple.opacity(0.08),
                        Color.mint.opacity(0.06),
                        Color(.systemBackground)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                if currentIndex < letters.count {
                    VStack(spacing: isRegularWidth ? 16 : 8) {
                        Text(s.letterOf(currentIndex + 1, total: letters.count))
                            .font(.system(size: isRegularWidth ? 16 : 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                            .padding(.top, 4)

                        DrawingCanvasView(
                            target: letters[currentIndex].asTraceTarget(language: language),
                            language: language
                        ) {
                            let finished = letters[currentIndex]
                            store.markLetterCompleted(finished, language: language)
                            advance()
                        }
                        .id(letters[currentIndex].id)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, isRegularWidth ? 24 : 0)
                    .padding(.bottom, isRegularWidth ? 12 : 0)
                } else {
                    stageDoneView
                }

                if let badge = store.justUnlockedBadge {
                    CelebrationOverlay(badge: badge, language: language) {
                        store.dismissBadgeCelebration()
                        if currentIndex >= letters.count {
                            dismiss()
                        }
                    }
                    .transition(.opacity)
                    .zIndex(10)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(s.close) { dismiss() }
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                }
                ToolbarItem(placement: .principal) {
                    Text(stage.localizedTitle(for: language))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .animation(.easeInOut, value: store.justUnlockedBadge)
            .animation(.easeInOut, value: currentIndex)
        }
    }

    private var stageDoneView: some View {
        VStack(spacing: 16) {
            Text("🎉").font(.system(size: isRegularWidth ? 88 : 64))
            Text(s.stageComplete)
                .font(.system(size: isRegularWidth ? 32 : 24, weight: .heavy, design: .rounded))
            Text(s.coinsBadge(stage.badge.coinReward, emoji: stage.badge.emoji, name: s.badgeName(stage.badge)))
                .font(.system(size: isRegularWidth ? 18 : 15, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
            Button(s.done) { dismiss() }
                .buttonStyle(.borderedProminent)
                .controlSize(isRegularWidth ? .large : .regular)
        }
    }

    private func advance() {
        withAnimation {
            currentIndex += 1
        }
    }
}
