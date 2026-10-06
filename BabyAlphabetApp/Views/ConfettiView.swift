//
//  ConfettiView.swift
//  BabyAlphabetApp
//
//  Lightweight confetti burst shown together with the clapping sound at
//  the end of a successful trace / stage completion.
//

import SwiftUI

struct ConfettiView: View {
    @State private var pieces: [ConfettiPiece] = []
    let pieceCount: Int

    init(pieceCount: Int = 80) {
        self.pieceCount = pieceCount
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(pieces) { piece in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(piece.color)
                        .frame(width: piece.size, height: piece.size * 0.4)
                        .rotationEffect(.degrees(piece.rotation))
                        .position(x: piece.x, y: piece.y)
                        .opacity(piece.opacity)
                }
            }
            .onAppear {
                generate(in: geo.size)
                animate(in: geo.size)
            }
        }
        .allowsHitTesting(false)
    }

    private func generate(in size: CGSize) {
        pieces = (0..<pieceCount).map { _ in
            ConfettiPiece(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: -size.height...0),
                size: CGFloat.random(in: 6...14),
                color: ConfettiPiece.palette.randomElement() ?? .pink,
                rotation: Double.random(in: 0...360),
                opacity: 1
            )
        }
    }

    private func animate(in size: CGSize) {
        withAnimation(.easeIn(duration: Double.random(in: 1.6...2.4))) {
            for index in pieces.indices {
                pieces[index].y = size.height + 40
                pieces[index].rotation += Double.random(in: 180...720)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation(.easeOut(duration: 0.4)) {
                for index in pieces.indices {
                    pieces[index].opacity = 0
                }
            }
        }
    }
}

private struct ConfettiPiece: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var color: Color
    var rotation: Double
    var opacity: Double

    static let palette: [Color] = [.pink, .yellow, .green, .blue, .purple, .orange, .mint, .red]
}

/// Full-screen celebration overlay: confetti + big badge/coins summary.
/// Call `SoundManager.shared.playClapping()` when presenting this.
struct CelebrationOverlay: View {
    let badge: Badge
    var language: AppLanguage = .english
    let onDismiss: () -> Void

    private var s: L10n { L10n(language) }

    var body: some View {
        ZStack {
            Color.black.opacity(0.35).ignoresSafeArea()
            ConfettiView()
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Text(badge.emoji)
                    .font(.system(size: 96))
                    .scaleEffect(1.0)
                    .accessibilityHidden(true)

                Text(s.greatJob)
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)

                Text(s.earnedBadge(s.badgeName(badge)))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                HStack(spacing: 6) {
                    Image(systemName: "circlebadge.fill")
                        .foregroundStyle(.yellow)
                    Text(s.plusCoins(badge.coinReward))
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(.yellow)
                }
                .padding(.top, 4)

                Button(action: onDismiss) {
                    Text(s.keepGoingCta)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .padding(.horizontal, 28)
                        .padding(.vertical, 14)
                        .background(Capsule().fill(Color.pink))
                        .foregroundStyle(.white)
                }
                .padding(.top, 12)
            }
            .padding(32)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28))
            .padding(40)
        }
    }
}

/// Big success pop-up after a letter/number is traced correctly.
struct LetterRewardOverlay: View {
    let target: TraceTarget
    var language: AppLanguage = .english
    @State private var bounce = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    init(target: TraceTarget, language: AppLanguage = .english) {
        self.target = target
        self.language = language
    }

    init(letter: LetterItem) {
        self.target = letter.asTraceTarget(language: .english)
        self.language = .english
    }

    private var isPad: Bool { horizontalSizeClass == .regular }
    private var s: L10n { L10n(language) }

    var body: some View {
        ZStack {
            Color.black.opacity(0.40)
                .ignoresSafeArea()

            VStack(spacing: isPad ? 28 : 20) {
                Text(target.exampleEmoji)
                    .font(.system(size: isPad ? 220 : 160))
                    .scaleEffect(bounce ? 1.08 : 0.5)
                    .rotationEffect(.degrees(bounce ? 0 : -10))
                    .shadow(color: .black.opacity(0.18), radius: 16, y: 8)
                    .accessibilityLabel(target.exampleWord)

                Text(target.character)
                    .font(.system(size: isPad ? 72 : 56, weight: .black, design: .rounded))
                    .foregroundStyle(.purple)

                Text(target.exampleWord)
                    .font(.system(size: isPad ? 40 : 32, weight: .heavy, design: .rounded))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.7)
                    .padding(.horizontal, 12)

                Text(s.youFoundIt)
                    .font(.system(size: isPad ? 24 : 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, isPad ? 56 : 36)
            .padding(.vertical, isPad ? 48 : 36)
            .frame(maxWidth: isPad ? 560 : 360)
            .frame(minHeight: isPad ? 420 : 320)
            .background(
                RoundedRectangle(cornerRadius: 40, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .purple.opacity(0.28), radius: 32, y: 14)
            )
            .padding(.horizontal, isPad ? 48 : 20)
            .scaleEffect(bounce ? 1 : 0.82)
            .opacity(bounce ? 1 : 0)
        }
        .allowsHitTesting(false)
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.62)) {
                bounce = true
            }
            withAnimation(.easeInOut(duration: 0.55).repeatCount(2, autoreverses: true).delay(0.55)) {
                bounce = true
            }
        }
    }
}
