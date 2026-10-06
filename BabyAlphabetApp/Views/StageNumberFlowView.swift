//
//  StageNumberFlowView.swift
//  BabyAlphabetApp
//

import SwiftUI

struct StageNumberFlowView: View {
    let stage: CountingStage
    let language: AppLanguage

    @EnvironmentObject var store: ProgressStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var currentIndex: Int = 0

    private var s: L10n { L10n(language) }
    private var numbers: [NumberItem] { stage.numbers }

    private var isRegularWidth: Bool {
        horizontalSizeClass == .regular
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color.orange.opacity(0.10),
                        Color.mint.opacity(0.06),
                        Color(.systemBackground)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                if currentIndex < numbers.count {
                    let number = numbers[currentIndex]
                    VStack(spacing: isRegularWidth ? 16 : 8) {
                        Text(s.numberOf(currentIndex + 1, total: numbers.count))
                            .font(.system(size: isRegularWidth ? 16 : 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                            .padding(.top, 4)

                        DrawingCanvasView(
                            target: number.asTraceTarget(language: language),
                            language: language
                        ) {
                            store.markNumberCompleted(number, language: language)
                            advance()
                        }
                        .id(number.id)
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
                        if currentIndex >= numbers.count {
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
