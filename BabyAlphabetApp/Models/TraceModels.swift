//
//  TraceModels.swift
//  BabyAlphabetApp
//
//  Shared model for anything the child can finger-trace (letters or numbers).
//

import Foundation

/// One drawable item shown on the tracing canvas.
struct TraceTarget: Identifiable, Hashable {
    enum Kind: String, Hashable {
        case letter
        case number
    }

    let id: String
    let kind: Kind
    let character: String
    let displayLabel: String
    let subtitle: String
    let exampleWord: String
    let exampleEmoji: String
    let hearPhrase: String
    let soundPhrase: String
    let outlineNoun: String
}

extension LetterItem {
    func asTraceTarget(language: AppLanguage) -> TraceTarget {
        let s = L10n(language)
        let word = spokenExampleWord
        return TraceTarget(
            id: "letter-\(language.rawValue)-\(id)",
            kind: .letter,
            character: character,
            displayLabel: displayLabel,
            subtitle: s.letterIsFor(character, word: exampleWord),
            exampleWord: exampleWord,
            exampleEmoji: exampleEmoji,
            hearPhrase: s.hearLetterPhrase(character, word: word),
            soundPhrase: s.soundLetter(character),
            outlineNoun: s.letterNoun
        )
    }

    private var spokenExampleWord: String {
        let raw = exampleWord
        if let open = raw.firstIndex(of: "("), let close = raw.firstIndex(of: ")") {
            let inside = raw[raw.index(after: open)..<close].trimmingCharacters(in: .whitespaces)
            if !inside.isEmpty { return String(inside) }
        }
        return raw
            .replacingOccurrences(of: #"\s*\(.*?\)"#, with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespaces)
    }
}

extension NumberItem {
    func asTraceTarget(language: AppLanguage) -> TraceTarget {
        let s = L10n(language)
        let spoken = spokenName(for: language)
        return TraceTarget(
            id: "number-\(language.rawValue)-\(id)",
            kind: .number,
            character: character,
            displayLabel: displayLabel,
            subtitle: s.numberLabel(id, spoken: spoken),
            exampleWord: spoken,
            exampleEmoji: exampleEmoji,
            hearPhrase: s.hearNumberPhrase(spoken, n: id),
            soundPhrase: s.soundNumber(spoken),
            outlineNoun: s.numberNoun
        )
    }
}
