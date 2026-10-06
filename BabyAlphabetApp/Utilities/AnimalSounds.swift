//
//  AnimalSounds.swift
//  BabyAlphabetApp
//
//  Maps traced letter example animals (by emoji / word) to bundled
//  animal_*.wav celebration sounds.
//

import Foundation

enum AnimalSoundID: String, CaseIterable {
    case cat, dog, elephant, lion, tiger, bird, cow, pig, horse
    case duck, frog, bee, mouse, goat, wolf, bear, monkey, whale
    case seal, fish, rabbit, zebra, giraffe, fox, camel, crocodile
    case dolphin, hedgehog, penguin, yak, hippo

    var fileName: String { "animal_\(rawValue)" }
}

enum AnimalSoundMapper {

    /// Resolve an animal sound for a traced letter/number target, if any.
    static func sound(for target: TraceTarget) -> AnimalSoundID? {
        if target.kind != .letter { return nil }
        if let byEmoji = sound(forEmoji: target.exampleEmoji) {
            return byEmoji
        }
        return sound(forWord: target.exampleWord)
    }

    static func sound(forEmoji emoji: String) -> AnimalSoundID? {
        // Normalize variation selectors / presentation.
        let key = emoji.unicodeScalars
            .filter { $0.value != 0xFE0F }
            .map { String($0) }
            .joined()

        switch key {
        case "🐱", "🐈": return .cat
        case "🐶", "🐕": return .dog
        case "🐘": return .elephant
        case "🦁": return .lion
        case "🐯", "🐅": return .tiger
        case "🐦", "🐤", "🐥", "🦅", "🦜", "🦢", "🦩", "🦉": return .bird
        case "🐮", "🐄", "🐂": return .cow
        case "🐷", "🐖": return .pig
        case "🐴", "🐎": return .horse
        case "🦆": return .duck
        case "🐸": return .frog
        case "🐝": return .bee
        case "🐭", "🐁", "🐀": return .mouse
        case "🐐", "🐑": return .goat
        case "🐺": return .wolf
        case "🐻", "🧸": return .bear
        case "🐵", "🐒", "🦍": return .monkey
        case "🐋", "🐳": return .whale
        case "🦭": return .seal
        case "🐟", "🐠", "🐡": return .fish
        case "🐰", "🐇": return .rabbit
        case "🦓": return .zebra
        case "🦒": return .giraffe
        case "🦊": return .fox
        case "🐪", "🐫": return .camel
        case "🐊": return .crocodile
        case "🐬": return .dolphin
        case "🦔": return .hedgehog
        case "🐧": return .penguin
        case "🦬": return .yak
        case "🦛": return .hippo
        case "🦌", "🦌": return .goat // soft fallback
        case "🐹": return .mouse
        case "🦀": return .fish
        case "🪿": return .bird
        default: return nil
        }
    }

    static func sound(forWord raw: String) -> AnimalSoundID? {
        let word = normalize(raw)
        guard !word.isEmpty else { return nil }

        let table: [(AnimalSoundID, [String])] = [
            (.cat, ["cat", "gato", "katze", "kissa", "kocka", "kot", "قط"]),
            (.dog, ["dog", "perro", "hund", "cão", "cao", "pies", "koira", "pes", "كلب", "狗", "gǒu", "gou"]),
            (.elephant, ["elephant", "elefante", "elefant", "elefantti", "فيل", "فيل"]),
            (.lion, ["lion", "leon", "león", "löwe", "lowe", "leão", "leao", "lew", "اسد", "أسد"]),
            (.tiger, ["tiger", "tigre", "tygrys", "tygr", "老虎", "lǎohǔ", "laohu"]),
            (.bird, ["bird", "vogel", "lintu", "pájaro", "pajaro", "oiseau", "طائر", "cap", "ibis"]),
            (.cow, ["cow", "vaca", "kuh", "بقرة"]),
            (.pig, ["pig", "cerdo", "schwein", "porco", "猪", "zhū", "zhu"]),
            (.horse, ["horse", "caballo", "pferd", "koń", "kon", "kůň", "kun", "حصان", "źrebak", "zrebak"]),
            (.duck, ["duck", "pato", "ente", "بطة", "بطة"]),
            (.frog, ["frog", "rana", "frosch", "żaba", "zaba", "sammakko", "ضفدع"]),
            (.bee, ["bee", "abeille", "biene", "abelha", "nube", "نحلة", "osa"]),
            (.mouse, ["mouse", "raton", "ratón", "maus", "rato", "får", "فأر"]),
            (.goat, ["goat", "cabra", "ziege", "gazelli", "غزال", "ظبي"]),
            (.wolf, ["wolf", "lobo", "wolf", "ذئب"]),
            (.bear, ["bear", "oso", "bär", "bar", "دُب", "دب", "nalle"]),
            (.monkey, ["monkey", "mono", "affe", "macaco"]),
            (.whale, ["whale", "ballena", "wal", "baleia"]),
            (.seal, ["seal", "foca", "robbe"]),
            (.fish, ["fish", "pez", "fisch", "peixe", "ryba", "سمك"]),
            (.rabbit, ["rabbit", "conejo", "hase", "coelho", "兔子", "tùzi", "tuzi"]),
            (.zebra, ["zebra", "cebra"]),
            (.giraffe, ["giraffe", "jirafa", "żyrafa", "zyrafa", "زرافة"]),
            (.fox, ["fox", "zorro", "fuchs", "lis", "liška", "liska", "ثعلب"]),
            (.camel, ["camel", "camello", "جمل"]),
            (.crocodile, ["crocodile", "crocodilo", "jacaré", "jacare", "تمساح"]),
            (.dolphin, ["dolphin", "delfin", "delfín", "delfiini", "delfín"]),
            (.hedgehog, ["hedgehog", "igel", "erizo"]),
            (.penguin, ["penguin", "pinguin", "pingüino", "pinguino"]),
            (.yak, ["yak"]),
            (.hippo, ["hippo", "hipopotamo", "hipopótamo", "nilpferd"]),
        ]

        for (id, keys) in table {
            for key in keys where word.contains(key) || key.contains(word) {
                return id
            }
        }
        return nil
    }

    private static func normalize(_ raw: String) -> String {
        var s = raw
        if let open = s.firstIndex(of: "(") {
            s = String(s[..<open])
        }
        s = s.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
        s = s.lowercased()
        let allowed = CharacterSet.alphanumerics.union(.whitespaces)
        s = String(s.unicodeScalars.filter { allowed.contains($0) })
        return s.trimmingCharacters(in: .whitespaces)
    }
}
