//
//  MathQuizView.swift
//  BabyAlphabetApp
//
//  Shows one equation at a time (e.g. 5 + 2 = ?) with a kid-friendly
//  number pad. Advances on a correct answer; awards a math badge every
//  10 correct answers for the operation.
//

import SwiftUI

struct MathQuizView: View {
    let operation: MathOperation

    @EnvironmentObject var store: ProgressStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var questionIndex = 0
    @State private var answerText = ""
    @State private var feedback: Feedback?
    @State private var shake: CGFloat = 0
    @State private var showConfetti = false
    @State private var deck: [MathQuestion] = []

    private var language: AppLanguage { store.selectedLanguage }
    private var s: L10n { L10n(language) }
    private var questions: [MathQuestion] { deck.isEmpty ? MathQuestionBank.questions(for: operation) : deck }

    private var isPad: Bool { horizontalSizeClass == .regular }

    private enum Feedback {
        case correct
        case wrong
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.purple.opacity(0.08), Color.mint.opacity(0.06), Color(.systemBackground)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            if questionIndex >= questions.count {
                finishedView
            } else {
                quizContent
            }

            if showConfetti {
                ConfettiView(pieceCount: 50)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }

            if let badge = store.justUnlockedBadge {
                CelebrationOverlay(badge: badge, language: language) {
                    store.dismissBadgeCelebration()
                }
                .zIndex(10)
            }
        }
        .navigationTitle(s.mathOperationTitle(operation))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if deck.isEmpty {
                var mixed = MathQuestionBank.questions(for: operation)
                mixed.shuffle()
                deck = mixed
            }
            let done = store.mathCorrectCount(for: operation)
            if done >= questions.count {
                questionIndex = questions.count
            } else {
                questionIndex = done
            }
        }
    }

    private var quizContent: some View {
        let question = questions[questionIndex]
        let correct = store.mathCorrectCount(for: operation)
        let toward = correct % MathQuestionBank.correctPerBadge

        return VStack(spacing: isPad ? 24 : 16) {
            HStack {
                Text(s.mathQuestionOf(questionIndex + 1, total: questions.count))
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                Spacer()
                Text(s.mathBadgeProgress(toward, of: MathQuestionBank.correctPerBadge))
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.purple)
            }
            .padding(.horizontal)

            ProgressView(
                value: Double(toward),
                total: Double(MathQuestionBank.correctPerBadge)
            )
            .tint(.purple)
            .padding(.horizontal)

            Spacer(minLength: 8)

            Text(operation.emoji)
                .font(.system(size: isPad ? 56 : 40))

            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text(question.prompt)
                    .font(.system(size: isPad ? 56 : 40, weight: .heavy, design: .rounded))
                    .foregroundStyle(.primary)
                Text("=")
                    .font(.system(size: isPad ? 56 : 40, weight: .heavy, design: .rounded))
                    .foregroundStyle(.secondary)
                Text(answerText.isEmpty ? "?" : answerText)
                    .font(.system(size: isPad ? 56 : 40, weight: .heavy, design: .rounded))
                    .foregroundStyle(feedback == .wrong ? .red : .purple)
                    .frame(minWidth: isPad ? 80 : 56, alignment: .leading)
            }
            .offset(x: shake)
            .padding(.horizontal)

            if let feedback {
                Text(feedback == .correct ? s.mathCorrect : s.mathTryAgain)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(feedback == .correct ? .green : .red)
            }

            Spacer(minLength: 8)

            numberPad

            Button(action: checkAnswer) {
                Text(s.mathCheck)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .disabled(answerText.isEmpty || feedback == .correct)
            .padding(.horizontal)
            .padding(.bottom, 12)
        }
        .padding(.top, 8)
    }

    private var numberPad: some View {
        let keys: [[String]] = [
            ["1", "2", "3"],
            ["4", "5", "6"],
            ["7", "8", "9"],
            ["⌫", "0", "✓"]
        ]

        return VStack(spacing: 10) {
            ForEach(keys, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(row, id: \.self) { key in
                        Button {
                            handleKey(key)
                        } label: {
                            Text(key)
                                .font(.system(size: isPad ? 28 : 24, weight: .bold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .frame(height: isPad ? 64 : 52)
                                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                        .disabled(feedback == .correct && key != "✓")
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    private var finishedView: some View {
        VStack(spacing: 16) {
            Text("🎉").font(.system(size: 72))
            Text(s.mathAllDone)
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .multilineTextAlignment(.center)
            Text("\(store.mathCorrectCount(for: operation))/\(questions.count)")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
            Button(s.done) { dismiss() }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
        }
        .padding()
    }

    private func handleKey(_ key: String) {
        guard feedback != .correct else {
            if key == "✓" { advance() }
            return
        }
        if feedback == .wrong {
            feedback = nil
        }
        switch key {
        case "⌫":
            if !answerText.isEmpty { answerText.removeLast() }
        case "✓":
            checkAnswer()
        default:
            if answerText.count < 4 {
                answerText.append(key)
            }
        }
    }

    private func checkAnswer() {
        guard !answerText.isEmpty, questionIndex < questions.count else { return }
        let question = questions[questionIndex]
        let ok = store.submitMathAnswer(question: question, answerText: answerText)
        if ok {
            feedback = .correct
            showConfetti = true
            SoundManager.shared.playClapping {
                // Soft celebration; speech optional for the answer.
                SpeechManager.shared.speak(text: "\(question.answer)", language: language)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                showConfetti = false
                advance()
            }
        } else {
            feedback = .wrong
            SoundManager.shared.playMistake()
            withAnimation(.default) { shake = 10 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
                withAnimation(.default) { shake = -10 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.default) { shake = 0 }
            }
        }
    }

    private func advance() {
        answerText = ""
        feedback = nil
        withAnimation {
            questionIndex += 1
        }
    }
}
