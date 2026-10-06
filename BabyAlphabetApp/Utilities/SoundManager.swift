//
//  SoundManager.swift
//  BabyAlphabetApp
//
//  Plays celebration audio from bundled files:
//  - clapping.wav  → after every correctly traced alphabet
//  - badge_unlock.mp3 → when a new badge is earned
//  Falls back to short synthesized tones only if a file is missing.
//

import AVFoundation
import AudioToolbox

@MainActor
final class SoundManager: ObservableObject {
    static let shared = SoundManager()

    private var player: AVAudioPlayer?
    private var clapPlayer: AVAudioPlayer?
    private var badgePlayer: AVAudioPlayer?
    private var audioSessionConfigured = false

    /// How long applause plays before the letter TTS starts (full clip is ~18s).
    private let clapLeadInSeconds: TimeInterval = 1.8
    /// Stop / fade applause so it doesn't drown the next letter screen.
    private let clapPlaySeconds: TimeInterval = 3.5

    private init() {
        configureAudioSession()
        clapPlayer = loadPlayer(named: "clapping", extensions: ["wav", "mp3", "m4a", "caf"])
        badgePlayer = loadPlayer(named: "badge_unlock", extensions: ["mp3", "wav", "m4a", "caf"])
    }

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.duckOthers])
            try session.setActive(true)
            audioSessionConfigured = true
        } catch {
            // Players may still work with the existing session.
        }
    }

    /// Soft "oops" when the child draws off the letter.
    func playMistake() {
        configureAudioSession()
        playTone(frequencies: [320, 240], durations: [0.12, 0.16], volume: 0.4)
    }

    /// Auditorium applause after a correct alphabet, then `completion` (letter sound).
    func playClapping(completion: (() -> Void)? = nil) {
        configureAudioSession()

        if clapPlayer == nil {
            clapPlayer = loadPlayer(named: "clapping", extensions: ["wav", "mp3", "m4a", "caf"])
        }

        guard let clapPlayer else {
            playTone(frequencies: [880, 1175], durations: [0.1, 0.15], volume: 0.6)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                completion?()
            }
            return
        }

        clapPlayer.stop()
        clapPlayer.currentTime = 0
        clapPlayer.volume = 1.0
        clapPlayer.numberOfLoops = 0
        clapPlayer.play()

        // Start letter TTS after a short applause lead-in (don't wait for full ~18s clip).
        DispatchQueue.main.asyncAfter(deadline: .now() + clapLeadInSeconds) {
            completion?()
        }

        // Fade out and stop so the next letter isn't covered by long applause.
        DispatchQueue.main.asyncAfter(deadline: .now() + clapPlaySeconds) { [weak self] in
            self?.fadeOutClap()
        }
    }

    /// Coin chime (kept light; badge fanfare is the main reward sound).
    func playCoinReward() {
        configureAudioSession()
        playTone(frequencies: [988, 1319], durations: [0.08, 0.18], volume: 0.45)
    }

    /// Holiday / celebration track when a new badge is unlocked.
    func playBadgeUnlock() {
        configureAudioSession()

        if badgePlayer == nil {
            badgePlayer = loadPlayer(named: "badge_unlock", extensions: ["mp3", "wav", "m4a", "caf"])
        }

        guard let badgePlayer else {
            playTone(frequencies: [523, 659, 784, 1047], durations: [0.1, 0.1, 0.1, 0.22], volume: 0.55)
            return
        }

        // Don't let leftover applause fight the badge music.
        fadeOutClap(immediate: true)

        badgePlayer.stop()
        badgePlayer.currentTime = 0
        badgePlayer.volume = 1.0
        badgePlayer.play()
        self.player = badgePlayer
    }

    /// Plays a bundled animal effect after a successful animal-letter trace.
    func playAnimalSound(for target: TraceTarget, completion: (() -> Void)? = nil) {
        guard let animal = AnimalSoundMapper.sound(for: target) else {
            completion?()
            return
        }
        playAnimalSound(animal, completion: completion)
    }

    func playAnimalSound(_ animal: AnimalSoundID, completion: (() -> Void)? = nil) {
        configureAudioSession()
        fadeOutClap(immediate: false)

        guard let animalPlayer = loadPlayer(named: animal.fileName, extensions: ["wav", "mp3", "m4a", "caf"]) else {
            // Soft fallback chirp so animal letters still feel special.
            playTone(frequencies: [660, 880, 990], durations: [0.08, 0.1, 0.14], volume: 0.4)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                completion?()
            }
            return
        }

        animalPlayer.stop()
        animalPlayer.currentTime = 0
        animalPlayer.volume = 1.0
        animalPlayer.play()
        self.player = animalPlayer

        let delay = max(0.6, animalPlayer.duration + 0.05)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            completion?()
        }
    }

    // MARK: - Bundled file loading

    private func loadPlayer(named name: String, extensions: [String]) -> AVAudioPlayer? {
        for ext in extensions {
            if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                do {
                    let audioPlayer = try AVAudioPlayer(contentsOf: url)
                    audioPlayer.prepareToPlay()
                    return audioPlayer
                } catch {
                    continue
                }
            }
        }
        return nil
    }

    private func fadeOutClap(immediate: Bool = false) {
        guard let clapPlayer, clapPlayer.isPlaying else { return }
        if immediate {
            clapPlayer.stop()
            clapPlayer.currentTime = 0
            return
        }
        // Quick volume fade then stop.
        let steps = 8
        let stepTime = 0.05
        for i in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepTime * Double(i)) {
                clapPlayer.volume = max(0, 1.0 - Float(i) / Float(steps))
                if i == steps {
                    clapPlayer.stop()
                    clapPlayer.currentTime = 0
                    clapPlayer.volume = 1.0
                }
            }
        }
    }

    // MARK: - Tiny synthesized fallbacks

    private func playTone(frequencies: [Double], durations: [Double], volume: Float) {
        guard frequencies.count == durations.count, !frequencies.isEmpty else { return }
        let sampleRate = 22_050.0
        let total = durations.reduce(0, +)
        let sampleCount = Int(sampleRate * total)
        var samples = [Int16](repeating: 0, count: sampleCount)
        var cursor = 0

        for (freq, dur) in zip(frequencies, durations) {
            let n = Int(sampleRate * dur)
            for i in 0..<n {
                guard cursor + i < sampleCount else { break }
                let t = Double(i) / sampleRate
                let envelope = min(1, Double(i) / 400) * min(1, Double(n - i) / 600)
                let value = sin(2 * .pi * freq * t) * envelope * Double(Int16.max) * 0.55
                samples[cursor + i] = Int16(clamping: Int(value))
            }
            cursor += n
        }

        guard let data = wavData(from: samples, sampleRate: Int(sampleRate)) else { return }
        do {
            let audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer.volume = volume
            self.player = audioPlayer
            audioPlayer.play()
        } catch {
            // Ignore tone failures.
        }
    }

    private func wavData(from samples: [Int16], sampleRate: Int) -> Data? {
        let dataSize = samples.count * MemoryLayout<Int16>.size
        var header = Data()

        func appendASCII(_ string: String) {
            header.append(contentsOf: string.utf8)
        }
        func appendUInt32(_ value: UInt32) {
            var v = value.littleEndian
            header.append(Data(bytes: &v, count: 4))
        }
        func appendUInt16(_ value: UInt16) {
            var v = value.littleEndian
            header.append(Data(bytes: &v, count: 2))
        }

        appendASCII("RIFF")
        appendUInt32(UInt32(36 + dataSize))
        appendASCII("WAVE")
        appendASCII("fmt ")
        appendUInt32(16)
        appendUInt16(1)
        appendUInt16(1)
        appendUInt32(UInt32(sampleRate))
        appendUInt32(UInt32(sampleRate * 2))
        appendUInt16(2)
        appendUInt16(16)
        appendASCII("data")
        appendUInt32(UInt32(dataSize))

        var body = Data(capacity: dataSize)
        for sample in samples {
            var s = sample.littleEndian
            body.append(Data(bytes: &s, count: 2))
        }
        header.append(body)
        return header
    }
}
