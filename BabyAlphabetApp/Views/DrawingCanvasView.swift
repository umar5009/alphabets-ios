//
//  DrawingCanvasView.swift
//  BabyAlphabetApp
//
//  The core tracing screen: a light, extra-bold letter guide is shown,
//  the child traces it with a finger (or Apple Pencil), the drawn stroke
//  renders as a bright rainbow line on top, and once enough of the guide
//  has been covered accurately the letter is marked complete — triggering
//  the clapping sound, that letter's spoken sound, and a confetti pop.
//
//  Random / off-path scribbles are rejected with clear feedback. If the
//  child struggles, an animated "Show me" helper draws the letter first.
//

import SwiftUI

struct DrawingCanvasView: View {
    let target: TraceTarget
    let language: AppLanguage
    let onCompleted: () -> Void

    init(target: TraceTarget, language: AppLanguage, onCompleted: @escaping () -> Void) {
        self.target = target
        self.language = language
        self.onCompleted = onCompleted
    }

    init(letter: LetterItem, language: AppLanguage, onCompleted: @escaping () -> Void) {
        self.target = letter.asTraceTarget(language: language)
        self.language = language
        self.onCompleted = onCompleted
    }

    @State private var drawnPoints: [CGPoint] = []
    @State private var currentStrokePoints: [CGPoint] = []
    @State private var previousStrokes: [[CGPoint]] = []
    @State private var guideStrokes: [Path] = []
    @State private var guideSamplePoints: [CGPoint] = []
    @State private var helperSegments: [[CGPoint]] = []
    @State private var canvasSize: CGSize = .zero
    @State private var coverage: Double = 0
    @State private var accuracy: Double = 0
    @State private var isCompleted = false
    @State private var showLetterPopConfetti = false
    @State private var showWordReward = false
    @State private var failedAttempts = 0
    @State private var showMistakeFeedback = false
    @State private var mistakeMessage = ""
    @State private var canvasShake: CGFloat = 0
    @State private var showHelper = false
    @State private var helperProgress: CGFloat = 0
    @State private var helperAnimating = false
    @State private var idleTask: Task<Void, Never>?
    @ObservedObject private var speech = SpeechManager.shared
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var s: L10n { L10n(language) }

    /// Single centerline guide — one solid stroke, not a hollow outline.
    private var guideLineWidth: CGFloat { 22 * sizeScale }
    private var helperLineWidth: CGFloat { 14 * sizeScale }
    private var drawLineWidth: CGFloat { 20 * sizeScale }

    /// Toddler-friendly thresholds — finger tracing over the guide stroke.
    private let baseCoverageNeeded: Double = 0.48
    private let baseAccuracyNeeded: Double = 0.38
    private let baseTolerance: CGFloat = 48
    private let minLengthRatio: CGFloat = 0.20

    private var isPadLayout: Bool {
        horizontalSizeClass == .regular
    }

    /// Wider guide + stroke on iPad.
    private var sizeScale: CGFloat {
        isPadLayout ? 1.45 : 1.0
    }

    /// Ease further after failed attempts so kids don't get stuck.
    private var coverageNeeded: Double {
        max(0.38, baseCoverageNeeded - Double(min(failedAttempts, 5)) * 0.035)
    }

    private var accuracyNeeded: Double {
        max(0.30, baseAccuracyNeeded - Double(min(failedAttempts, 5)) * 0.03)
    }

    private var tolerance: CGFloat {
        let characterBoost: CGFloat = target.character.count > 1 ? 10 : 0
        return (baseTolerance + characterBoost + CGFloat(min(failedAttempts, 5)) * 5)
            * (isPadLayout ? 1.45 : 1.0)
    }

    var body: some View {
        VStack(spacing: isPadLayout ? 18 : 12) {
            header

            GeometryReader { geo in
                let rect = CGRect(origin: .zero, size: geo.size)

                ZStack {
                    RoundedRectangle(cornerRadius: isPadLayout ? 36 : 28)
                        .fill(Color(.secondarySystemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: isPadLayout ? 36 : 28)
                                .stroke(showMistakeFeedback ? Color.red.opacity(0.55) : Color.clear, lineWidth: 3)
                        )

                    // Single purple centerline per handwriting stroke.
                    ForEach(Array(guideStrokes.enumerated()), id: \.offset) { _, stroke in
                        stroke
                            .stroke(
                                Color.purple.opacity(0.42),
                                style: StrokeStyle(
                                    lineWidth: guideLineWidth,
                                    lineCap: .round,
                                    lineJoin: .round
                                )
                            )
                    }

                    // Animated helper — one thin line per stroke, no doubled contours.
                    if showHelper, !helperSegments.isEmpty {
                        helperStrokePath
                            .stroke(
                                Color.mint,
                                style: StrokeStyle(
                                    lineWidth: helperLineWidth,
                                    lineCap: .round,
                                    lineJoin: .round
                                )
                            )
                            .shadow(color: .mint.opacity(0.45), radius: 4)

                        if let tip = helperTipPoint {
                            Circle()
                                .fill(Color.mint)
                                .frame(width: 18 * sizeScale, height: 18 * sizeScale)
                                .shadow(color: .mint.opacity(0.5), radius: 6)
                                .position(tip)
                        }
                    }

                    // The child's drawn stroke, in a bright rainbow gradient.
                    Path { path in
                        guard let first = currentStrokePoints.first else { return }
                        path.move(to: first)
                        for point in currentStrokePoints.dropFirst() {
                            path.addLine(to: point)
                        }
                    }
                    .stroke(
                        AngularGradient(colors: [.pink, .orange, .yellow, .green, .blue, .purple, .pink], center: .center),
                        style: StrokeStyle(lineWidth: drawLineWidth, lineCap: .round, lineJoin: .round)
                    )

                    ForEach(Array(previousStrokes.enumerated()), id: \.offset) { _, stroke in
                        Path { path in
                            guard let first = stroke.first else { return }
                            path.move(to: first)
                            for point in stroke.dropFirst() { path.addLine(to: point) }
                        }
                        .stroke(
                            AngularGradient(colors: [.pink, .orange, .yellow, .green, .blue, .purple, .pink], center: .center),
                            style: StrokeStyle(lineWidth: drawLineWidth, lineCap: .round, lineJoin: .round)
                        )
                    }

                    if showLetterPopConfetti {
                        ConfettiView(pieceCount: 40)
                    }

                    if showWordReward {
                        LetterRewardOverlay(target: target, language: language)
                            .transition(.scale.combined(with: .opacity))
                            .zIndex(5)
                    }

                    if drawnPoints.isEmpty && !showHelper && !showWordReward {
                        Image(systemName: "hand.point.up.left.fill")
                            .font(.system(size: isPadLayout ? 56 : 40))
                            .foregroundStyle(.purple.opacity(0.6))
                            .offset(x: 40, y: 40)
                            .transition(.opacity)
                    }

                    if showMistakeFeedback {
                        VStack {
                            Spacer()
                            Label(mistakeMessage, systemImage: "exclamationmark.triangle.fill")
                                .font(.system(size: isPadLayout ? 18 : 14, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(Color.red.opacity(0.88), in: Capsule())
                                .padding(.bottom, 16)
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    } else if showHelper && !isCompleted {
                        VStack {
                            Spacer()
                            Text(helperAnimating ? s.watchCarefully : s.nowYouTry)
                                .font(.system(size: isPadLayout ? 20 : 15, weight: .bold, design: .rounded))
                                .foregroundStyle(.mint)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(.ultraThinMaterial, in: Capsule())
                                .padding(.bottom, 16)
                        }
                    }
                }
                .offset(x: canvasShake)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            guard !isCompleted else { return }
                            resetIdleTimer()
                            if showMistakeFeedback {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    showMistakeFeedback = false
                                }
                            }
                            if helperAnimating {
                                stopHelperAnimation(keepVisible: true)
                            }
                            // Interpolate between last point and current so fast
                            // finger swipes still leave a continuous trail.
                            let point = value.location
                            if let last = currentStrokePoints.last {
                                let gap = hypot(point.x - last.x, point.y - last.y)
                                if gap > 8 {
                                    let steps = min(6, Int(gap / 6))
                                    for i in 1..<steps {
                                        let t = CGFloat(i) / CGFloat(steps)
                                        let mid = CGPoint(
                                            x: last.x + (point.x - last.x) * t,
                                            y: last.y + (point.y - last.y) * t
                                        )
                                        currentStrokePoints.append(mid)
                                        drawnPoints.append(mid)
                                    }
                                }
                            }
                            currentStrokePoints.append(point)
                            drawnPoints.append(point)
                            if drawnPoints.count % 4 == 0 {
                                updateProgressOnly()
                            }
                        }
                        .onEnded { _ in
                            guard !isCompleted else { return }
                            previousStrokes.append(currentStrokePoints)
                            currentStrokePoints = []
                            evaluateAttempt()
                            scheduleIdleHelp()
                        }
                )
                .onAppear {
                    rebuildGuide(in: rect)
                }
                .onChange(of: geo.size) { _, newSize in
                    guard newSize.width > 8, newSize.height > 8 else { return }
                    if abs(newSize.width - canvasSize.width) > 1
                        || abs(newSize.height - canvasSize.height) > 1
                        || guideSamplePoints.isEmpty {
                        rebuildGuide(in: CGRect(origin: .zero, size: newSize))
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, isPadLayout ? 8 : 16)

            progressBar

            VStack(spacing: 10) {
                speechPacePicker

                HStack(spacing: isPadLayout ? 20 : 12) {
                    Button(action: clear) {
                        Label(s.clear, systemImage: "arrow.counterclockwise")
                            .font(.system(size: isPadLayout ? 18 : 15, weight: .semibold, design: .rounded))
                    }
                    .buttonStyle(.bordered)
                    .controlSize(isPadLayout ? .large : .regular)
                    .disabled(isCompleted)

                    Button(action: { speech.speakTarget(target, language: language) }) {
                        Label(s.hearIt, systemImage: "speaker.wave.2.fill")
                            .font(.system(size: isPadLayout ? 18 : 15, weight: .semibold, design: .rounded))
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(isPadLayout ? .large : .regular)

                    Button(action: { startHelperDemo(fromUser: true) }) {
                        Label(s.showMe, systemImage: "wand.and.stars")
                            .font(.system(size: isPadLayout ? 18 : 15, weight: .semibold, design: .rounded))
                    }
                    .buttonStyle(.bordered)
                    .controlSize(isPadLayout ? .large : .regular)
                    .tint(.mint)
                    .disabled(isCompleted || helperSegments.isEmpty || helperAnimating)
                }
            }
            .padding(.bottom, isPadLayout ? 16 : 8)
        }
        .onAppear {
            speech.speakTarget(target, language: language)
            scheduleIdleHelp()
        }
        .onDisappear {
            idleTask?.cancel()
            idleTask = nil
        }
        .onChange(of: target.id) { _, _ in
            resetForNewLetter()
        }
        .environment(\.layoutDirection, language.isRightToLeft ? .rightToLeft : .leftToRight)
    }

    // MARK: - Subviews

    private var header: some View {
        VStack(spacing: 6) {
            HStack(spacing: isPadLayout ? 16 : 10) {
                Text(target.displayLabel)
                    .font(.system(size: isPadLayout ? 44 : 30, weight: .black, design: .rounded))
                    .foregroundStyle(.purple)

                Text(target.exampleEmoji)
                    .font(.system(size: isPadLayout ? 40 : 28))
                    .accessibilityHidden(true)
            }
            Text(target.subtitle)
                .font(.system(size: isPadLayout ? 22 : 16, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.top, isPadLayout ? 12 : 8)
    }

    private var speechPacePicker: some View {
        HStack(spacing: 8) {
            Image(systemName: "tortoise.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)
            Picker("Speed", selection: Binding(
                get: { speech.pace },
                set: { speech.setPace($0, replay: !isCompleted) }
            )) {
                ForEach(SpeechPace.allCases) { pace in
                    Text(pace.title(for: language)).tag(pace)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: isPadLayout ? 360 : 280)
        }
        .padding(.horizontal, 16)
    }

    private var progressBar: some View {
        VStack(spacing: 4) {
            ProgressView(value: min(max(coverage, accuracy == 0 ? coverage : min(coverage, accuracy)) / coverageNeeded, 1))
                .tint(showMistakeFeedback ? .red : .green)
                .padding(.horizontal, 24)
            Text(progressLabel)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(showMistakeFeedback ? .red : .secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }

    private var progressLabel: String {
        if isCompleted { return s.traced }
        if showMistakeFeedback { return mistakeMessage }
        if showHelper && helperAnimating { return s.followGlow }
        if failedAttempts >= 2 { return s.stayOnOutline(target.outlineNoun) }
        return s.traceCarefully(target.outlineNoun)
    }

    private var helperStrokePath: Path {
        let flat = helperSegments.flatMap { $0 }
        guard !flat.isEmpty else { return Path() }

        let targetCount = max(1, Int(CGFloat(flat.count) * helperProgress))
        var path = Path()
        var drawn = 0

        for segment in helperSegments {
            var isFirstInSegment = true
            for point in segment {
                if drawn >= targetCount { return path }
                if isFirstInSegment {
                    path.move(to: point)
                    isFirstInSegment = false
                } else {
                    path.addLine(to: point)
                }
                drawn += 1
            }
        }
        return path
    }

    private var helperTipPoint: CGPoint? {
        let flat = helperSegments.flatMap { $0 }
        guard !flat.isEmpty else { return nil }
        let index = min(
            flat.count - 1,
            max(0, Int(CGFloat(flat.count - 1) * helperProgress))
        )
        return flat[index]
    }

    // MARK: - Guide / recognition

    private func rebuildGuide(in rect: CGRect) {
        canvasSize = rect.size
        let inset = rect.insetBy(dx: 28, dy: 28)
        guideStrokes = TracingGuide.strokePaths(for: target.character, in: inset)
        guideSamplePoints = TracingGuide.scoringPoints(from: guideStrokes)
        helperSegments = TracingGuide.tutorialSegments(from: guideStrokes)
    }

    private func currentScore() -> TraceScore {
        TracingGuide.score(
            guidePoints: guideSamplePoints,
            drawnPoints: drawnPoints,
            tolerance: tolerance
        )
    }

    private func updateProgressOnly() {
        guard !guideSamplePoints.isEmpty, !isCompleted else { return }
        let score = currentScore()
        coverage = score.coverage
        accuracy = score.accuracy
    }

    private func evaluateAttempt() {
        guard !guideSamplePoints.isEmpty, !isCompleted else { return }

        // Ignore tiny taps — not a real attempt yet.
        if drawnPoints.count < 8 {
            coverage = 0
            accuracy = 0
            return
        }

        let score = currentScore()
        coverage = score.coverage
        accuracy = score.accuracy

        if score.isPassing(
            coverageNeeded: coverageNeeded,
            accuracyNeeded: accuracyNeeded,
            minLengthRatio: minLengthRatio
        ) {
            complete()
            return
        }

        // Flag the mistake clearly instead of silently advancing.
        failedAttempts += 1
        flagMistake(for: score)

        if failedAttempts >= 2 && !showHelper {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                guard !isCompleted else { return }
                startHelperDemo(fromUser: false)
            }
        }
    }

    private func flagMistake(for score: TraceScore) {
        let noun = target.outlineNoun
        if score.accuracy < accuracyNeeded && score.coverage < coverageNeeded * 0.5 {
            mistakeMessage = s.oopsDraw(noun)
        } else if score.accuracy < accuracyNeeded {
            mistakeMessage = s.stayOnTryAgain(noun)
        } else if score.coverage < coverageNeeded {
            mistakeMessage = s.keepGoing(noun)
        } else {
            mistakeMessage = s.almost
        }

        SoundManager.shared.playMistake()

        withAnimation(.spring(response: 0.35, dampingFraction: 0.55)) {
            showMistakeFeedback = true
        }
        shakeCanvas()

        // Auto-hide the banner so the child can try again.
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation(.easeOut(duration: 0.25)) {
                if showMistakeFeedback { showMistakeFeedback = false }
            }
        }
    }

    private func shakeCanvas() {
        withAnimation(.default) { canvasShake = 10 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
            withAnimation(.default) { canvasShake = -10 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            withAnimation(.default) { canvasShake = 6 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            withAnimation(.default) { canvasShake = 0 }
        }
    }

    private func complete() {
        guard !isCompleted else { return }
        isCompleted = true
        showMistakeFeedback = false
        idleTask?.cancel()
        stopHelperAnimation(keepVisible: false)
        showLetterPopConfetti = true

        withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
            showWordReward = true
        }

        // Stop any talking so clapping is audible, then clap → letter → animal.
        speech.stop()
        SoundManager.shared.playClapping { [target, language] in
            SpeechManager.shared.speakSound(target, language: language) {
                SoundManager.shared.playAnimalSound(for: target)
            }
        }

        // Wait for applause + letter sound (+ animal if any) before advancing.
        let advanceDelay: TimeInterval = AnimalSoundMapper.sound(for: target) == nil ? 3.4 : 5.2
        DispatchQueue.main.asyncAfter(deadline: .now() + advanceDelay) {
            onCompleted()
        }
    }

    private func clear() {
        drawnPoints = []
        currentStrokePoints = []
        previousStrokes = []
        coverage = 0
        accuracy = 0
        showMistakeFeedback = false
        scheduleIdleHelp()
    }

    private func resetForNewLetter() {
        idleTask?.cancel()
        drawnPoints = []
        currentStrokePoints = []
        previousStrokes = []
        coverage = 0
        accuracy = 0
        isCompleted = false
        showLetterPopConfetti = false
        showWordReward = false
        failedAttempts = 0
        showMistakeFeedback = false
        mistakeMessage = ""
        showHelper = false
        helperProgress = 0
        helperAnimating = false
        if canvasSize.width > 8 {
            rebuildGuide(in: CGRect(origin: .zero, size: canvasSize))
        }
        speech.speakTarget(target, language: language)
        scheduleIdleHelp()
    }

    // MARK: - Struggle help

    private func scheduleIdleHelp() {
        idleTask?.cancel()
        guard !isCompleted else { return }
        idleTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 10_000_000_000)
            guard !Task.isCancelled, !isCompleted, !helperAnimating else { return }
            if drawnPoints.isEmpty || failedAttempts >= 1 {
                startHelperDemo(fromUser: false)
            }
        }
    }

    private func resetIdleTimer() {
        idleTask?.cancel()
        scheduleIdleHelp()
    }

    private func startHelperDemo(fromUser: Bool) {
        guard !isCompleted, !helperSegments.isEmpty else { return }
        idleTask?.cancel()
        showMistakeFeedback = false
        showHelper = true
        helperAnimating = true
        helperProgress = 0

        if fromUser || failedAttempts >= 2 {
            speech.speakTarget(target, language: language)
        }

        withAnimation(.easeInOut(duration: 2.4)) {
            helperProgress = 1
        }

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_600_000_000)
            guard !Task.isCancelled else { return }
            helperAnimating = false
            scheduleIdleHelp()
        }
    }

    private func stopHelperAnimation(keepVisible: Bool) {
        helperAnimating = false
        if !keepVisible {
            showHelper = false
            helperProgress = 0
        } else if helperProgress < 1 {
            helperProgress = 1
        }
    }
}

#Preview {
    DrawingCanvasView(
        target: AppLanguage.english.letters[0].asTraceTarget(language: .english),
        language: .english,
        onCompleted: {}
    )
}
