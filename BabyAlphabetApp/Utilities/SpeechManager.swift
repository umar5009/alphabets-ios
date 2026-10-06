//
//  SpeechManager.swift
//  BabyAlphabetApp
//
//  Speaks letter/number sounds with clearly different Normal / Slow /
//  Slower rates for toddlers.
//

import AVFoundation
import SwiftUI

enum SpeechPace: String, CaseIterable, Identifiable {
    case normal
    case slow
    case slower

    var id: String { rawValue }

    var title: String {
        title(for: .english)
    }

    func title(for language: AppLanguage) -> String {
        let s = L10n(language)
        switch self {
        case .normal: return s.paceNormal
        case .slow: return s.paceSlow
        case .slower: return s.paceSlower
        }
    }

    /// Absolute AVSpeech rates (0…1). Spaced far apart so kids/parents
    /// can hear a clear difference when switching.
    var speechRate: Float {
        switch self {
        case .normal: return 0.50
        case .slow: return 0.32
        case .slower: return 0.16
        }
    }
}

@MainActor
final class SpeechManager: NSObject, ObservableObject {
    static let shared = SpeechManager()

    private let synthesizer = AVSpeechSynthesizer()
    @Published var isSpeaking = false
    @Published var pace: SpeechPace = .slow {
        didSet {
            guard oldValue != pace else { return }
            UserDefaults.standard.set(pace.rawValue, forKey: paceKey)
        }
    }

    private let paceKey = "com.babyalphabetapp.speechPace"
    private var audioSessionConfigured = false
    /// Last spoken text so changing speed can immediately replay.
    private var lastSpokenText: String?
    private var lastSpokenLanguage: AppLanguage?

    private override init() {
        super.init()
        synthesizer.delegate = self
        if let raw = UserDefaults.standard.string(forKey: paceKey),
           let saved = SpeechPace(rawValue: raw) {
            pace = saved
        }
        configureAudioSession()
    }

    func setPace(_ newPace: SpeechPace, replay: Bool = true) {
        let changed = pace != newPace
        pace = newPace
        if changed, replay, let text = lastSpokenText, let language = lastSpokenLanguage {
            speak(text: text, language: language)
        }
    }

    func speakTarget(_ target: TraceTarget, language: AppLanguage, completion: (() -> Void)? = nil) {
        stop()
        configureAudioSession()
        speak(text: target.hearPhrase, language: language, completion: completion)
    }

    func speakSound(_ target: TraceTarget, language: AppLanguage, completion: (() -> Void)? = nil) {
        stop()
        configureAudioSession()
        speak(text: target.soundPhrase, language: language, completion: completion)
    }

    func speakLetter(_ letter: LetterItem, language: AppLanguage, completion: (() -> Void)? = nil) {
        speakTarget(letter.asTraceTarget(language: language), language: language, completion: completion)
    }

    func speakSound(_ letter: LetterItem, language: AppLanguage, completion: (() -> Void)? = nil) {
        speakSound(letter.asTraceTarget(language: language), language: language, completion: completion)
    }

    func speak(text: String, language: AppLanguage, completion: (() -> Void)? = nil) {
        lastSpokenText = text
        lastSpokenLanguage = language

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = bestVoice(for: language)
        let minRate = AVSpeechUtteranceMinimumSpeechRate
        let maxRate = AVSpeechUtteranceMaximumSpeechRate
        utterance.rate = min(max(pace.speechRate, minRate), maxRate)
        utterance.pitchMultiplier = 1.05
        utterance.volume = 1.0
        // Longer pauses when slower so words don't blur together.
        switch pace {
        case .normal:
            utterance.preUtteranceDelay = 0.08
            utterance.postUtteranceDelay = 0.12
        case .slow:
            utterance.preUtteranceDelay = 0.15
            utterance.postUtteranceDelay = 0.25
        case .slower:
            utterance.preUtteranceDelay = 0.22
            utterance.postUtteranceDelay = 0.40
        }
        pendingCompletion = completion
        isSpeaking = true
        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
    }

    // MARK: - Voice / session helpers

    private func configureAudioSession() {
        guard !audioSessionConfigured else { return }
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers, .mixWithOthers])
            try session.setActive(true, options: [])
            audioSessionConfigured = true
        } catch {
            // Still attempt speech even if session setup fails.
        }
    }

    private func bestVoice(for language: AppLanguage) -> AVSpeechSynthesisVoice {
        let locale = language.speechLocaleIdentifier
        let voices = AVSpeechSynthesisVoice.speechVoices().filter {
            $0.language.lowercased().hasPrefix(locale.lowercased().prefix(2))
                || $0.language.caseInsensitiveCompare(locale) == .orderedSame
        }

        let exact = voices.filter { $0.language.caseInsensitiveCompare(locale) == .orderedSame }
        let pool = exact.isEmpty ? voices : exact

        if let enhanced = pool.first(where: { $0.quality == .enhanced }) {
            return enhanced
        }
        if #available(iOS 17.0, *) {
            if let premium = pool.first(where: { $0.quality == .premium }) {
                return premium
            }
        }
        if let voice = AVSpeechSynthesisVoice(language: locale)
            ?? AVSpeechSynthesisVoice(language: "en-US") {
            return voice
        }
        return AVSpeechSynthesisVoice.speechVoices().first
            ?? AVSpeechSynthesisVoice(language: "en-GB")!
    }

    private var pendingCompletion: (() -> Void)?
}

extension SpeechManager: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            isSpeaking = false
            pendingCompletion?()
            pendingCompletion = nil
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            isSpeaking = false
        }
    }
}
