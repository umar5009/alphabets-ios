//
//  MathHomeView.swift
//  BabyAlphabetApp
//
//  Math hub: pick Addition / Subtraction / Multiplication / Division.
//

import SwiftUI

struct MathHomeView: View {
    @EnvironmentObject var store: ProgressStore

    private var language: AppLanguage { store.selectedLanguage }
    private var s: L10n { L10n(language) }

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 14)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text(s.mathSubtitle)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)

                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(MathOperation.allCases) { operation in
                            NavigationLink {
                                MathQuizView(operation: operation)
                                    .environmentObject(store)
                            } label: {
                                MathOperationCard(
                                    operation: operation,
                                    title: s.mathOperationTitle(operation),
                                    correct: store.mathCorrectCount(for: operation),
                                    total: MathQuestionBank.questionsPerOperation,
                                    badgesEarned: MathBadge.badges(for: operation).filter { store.hasMathBadge($0) }.count,
                                    badgeLabel: s.mathBadgesLabel,
                                    towardNext: towardNextBadge(for: operation),
                                    progressHint: s.mathBadgeProgress(
                                        towardNextBadge(for: operation).current,
                                        of: MathQuestionBank.correctPerBadge
                                    )
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle(s.tabMath)
        }
    }

    private func towardNextBadge(for operation: MathOperation) -> (current: Int, remaining: Int) {
        let correct = store.mathCorrectCount(for: operation)
        let inTier = correct % MathQuestionBank.correctPerBadge
        if correct >= MathQuestionBank.questionsPerOperation {
            return (MathQuestionBank.correctPerBadge, 0)
        }
        let remaining = MathQuestionBank.correctPerBadge - inTier
        return (inTier, remaining == MathQuestionBank.correctPerBadge && correct > 0 ? 0 : remaining)
    }
}

private struct MathOperationCard: View {
    let operation: MathOperation
    let title: String
    let correct: Int
    let total: Int
    let badgesEarned: Int
    let badgeLabel: String
    let towardNext: (current: Int, remaining: Int)
    let progressHint: String

    var body: some View {
        VStack(spacing: 10) {
            Text(operation.emoji)
                .font(.system(size: 36))

            Text(title)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)

            Text("\(operation.symbol)")
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundStyle(.purple)

            Text("\(correct)/\(total)")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)

            ProgressView(
                value: Double(towardNext.current),
                total: Double(MathQuestionBank.correctPerBadge)
            )
            .tint(.purple)

            Text(progressHint)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if badgesEarned > 0 {
                Label("\(badgesEarned) \(badgeLabel)", systemImage: "checkmark.seal.fill")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(.green)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 200)
        .background(.background, in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
    }
}
