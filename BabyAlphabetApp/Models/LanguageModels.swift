//
//  LanguageModels.swift
//  BabyAlphabetApp
//
//  Defines every supported language, its alphabet/character set, and the
//  example word + picture emoji used to teach the letter sound at
//  "school level" standard for that country.
//

import Foundation

/// A single letter (or character, for Chinese) that a child can trace and hear.
struct LetterItem: Identifiable, Codable, Hashable {
    let id: Int          // stable order index within its language, 0-based
    let character: String
    let exampleWord: String   // the word used to teach the sound, e.g. "A is for Apple"
    let exampleEmoji: String  // picture shown on successful trace, e.g. "🍎"
    let ipaHint: String?      // optional phonetic hint shown in the UI (not spoken)

    var displayLabel: String { character.uppercased() }
}

/// A supported teaching language / writing system.
enum AppLanguage: String, CaseIterable, Identifiable, Codable {
    case english
    case spanish
    case german
    case portuguese
    case polish
    case finnish
    case czech
    case arabic
    case chinese

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Español"
        case .german: return "Deutsch"
        case .portuguese: return "Português"
        case .polish: return "Polski"
        case .finnish: return "Suomi"
        case .czech: return "Čeština"
        case .arabic: return "العربية"
        case .chinese: return "中文 (Pinyin)"
        }
    }

    var flagEmoji: String {
        switch self {
        case .english: return "🇬🇧"
        case .spanish: return "🇪🇸"
        case .german: return "🇩🇪"
        case .portuguese: return "🇵🇹"
        case .polish: return "🇵🇱"
        case .finnish: return "🇫🇮"
        case .czech: return "🇨🇿"
        case .arabic: return "🇸🇦"
        case .chinese: return "🇨🇳"
        }
    }

    /// BCP-47 locale identifier used by AVSpeechSynthesizer so pronunciation
    /// matches the country/school standard for that language.
    var speechLocaleIdentifier: String {
        switch self {
        case .english: return "en-GB"
        case .spanish: return "es-ES"
        case .german: return "de-DE"
        case .portuguese: return "pt-PT"
        case .polish: return "pl-PL"
        case .finnish: return "fi-FI"
        case .czech: return "cs-CZ"
        case .arabic: return "ar-SA"
        case .chinese: return "zh-CN"
        }
    }

    var isRightToLeft: Bool { self == .arabic }

    var writingNote: String? {
        switch self {
        case .chinese:
            return "Mandarin has no alphabet. Children here trace the 23 Pinyin initials, the standard first step taught in Chinese primary schools before full characters."
        default:
            return nil
        }
    }

    var letters: [LetterItem] {
        AlphabetData.letters(for: self)
    }
}

/// Static alphabet data for every supported language.
/// Each entry is (character, exampleWord, exampleEmoji).
enum AlphabetData {

    typealias Entry = (String, String, String)

    static func letters(for language: AppLanguage) -> [LetterItem] {
        let raw: [Entry]
        switch language {
        case .english: raw = english
        case .spanish: raw = spanish
        case .german: raw = german
        case .portuguese: raw = portuguese
        case .polish: raw = polish
        case .finnish: raw = finnish
        case .czech: raw = czech
        case .arabic: raw = arabic
        case .chinese: raw = chinesePinyinInitials
        }
        return raw.enumerated().map { index, entry in
            LetterItem(
                id: index,
                character: entry.0,
                exampleWord: entry.1,
                exampleEmoji: entry.2,
                ipaHint: nil
            )
        }
    }

    // MARK: Latin-script languages

    static let english: [Entry] = [
        ("A", "Apple", "🍎"), ("B", "Ball", "⚽️"), ("C", "Cat", "🐱"), ("D", "Dog", "🐶"), ("E", "Elephant", "🐘"),
        ("F", "Fish", "🐟"), ("G", "Goat", "🐐"), ("H", "Hat", "🎩"), ("I", "Igloo", "🏠"), ("J", "Jam", "🍓"),
        ("K", "Kite", "🪁"), ("L", "Lion", "🦁"), ("M", "Moon", "🌙"), ("N", "Nest", "🪺"), ("O", "Orange", "🍊"),
        ("P", "Pig", "🐷"), ("Q", "Queen", "👑"), ("R", "Rabbit", "🐰"), ("S", "Sun", "☀️"), ("T", "Tiger", "🐯"),
        ("U", "Umbrella", "☂️"), ("V", "Van", "🚐"), ("W", "Whale", "🐋"), ("X", "Xylophone", "🎹"), ("Y", "Yak", "🦬"), ("Z", "Zebra", "🦓")
    ]

    static let spanish: [Entry] = [
        ("A", "Árbol", "🌳"), ("B", "Barco", "⛵️"), ("C", "Casa", "🏠"), ("D", "Dedo", "👆"), ("E", "Elefante", "🐘"),
        ("F", "Foca", "🦭"), ("G", "Gato", "🐱"), ("H", "Helado", "🍦"), ("I", "Iglú", "🏠"), ("J", "Jirafa", "🦒"),
        ("K", "Koala", "🐨"), ("L", "León", "🦁"), ("M", "Mano", "✋"), ("N", "Nube", "☁️"), ("Ñ", "Ñandú", "🐦"),
        ("O", "Oso", "🐻"), ("P", "Pato", "🦆"), ("Q", "Queso", "🧀"), ("R", "Ratón", "🐭"), ("S", "Sol", "☀️"),
        ("T", "Tigre", "🐯"), ("U", "Uva", "🍇"), ("V", "Vaca", "🐮"), ("W", "Wifi", "📶"), ("X", "Xilófono", "🎹"), ("Y", "Yoyo", "🪀"), ("Z", "Zapato", "👟")
    ]

    static let german: [Entry] = [
        ("A", "Apfel", "🍎"), ("B", "Ball", "⚽️"), ("C", "Clown", "🤡"), ("D", "Delfin", "🐬"), ("E", "Elefant", "🐘"),
        ("F", "Fisch", "🐟"), ("G", "Giraffe", "🦒"), ("H", "Hut", "🎩"), ("I", "Igel", "🦔"), ("J", "Jojo", "🪀"),
        ("K", "Katze", "🐱"), ("L", "Löwe", "🦁"), ("M", "Maus", "🐭"), ("N", "Nest", "🪺"), ("O", "Orange", "🍊"),
        ("P", "Pinguin", "🐧"), ("Q", "Qualle", "🪼"), ("R", "Rakete", "🚀"), ("S", "Sonne", "☀️"), ("T", "Tiger", "🐯"),
        ("U", "Uhr", "🕐"), ("V", "Vogel", "🐦"), ("W", "Wal", "🐋"), ("X", "Xylophon", "🎹"), ("Y", "Yoga", "🧘"), ("Z", "Zebra", "🦓"),
        ("Ä", "Ärmel", "👕"), ("Ö", "Öl", "🛢️"), ("Ü", "Übung", "💪")
    ]

    static let portuguese: [Entry] = [
        ("A", "Abelha", "🐝"), ("B", "Bola", "⚽️"), ("C", "Casa", "🏠"), ("D", "Dado", "🎲"), ("E", "Elefante", "🐘"),
        ("F", "Foca", "🦭"), ("G", "Gato", "🐱"), ("H", "Hipopótamo", "🦛"), ("I", "Igreja", "⛪"), ("J", "Jacaré", "🐊"),
        ("K", "Kiwi", "🥝"), ("L", "Leão", "🦁"), ("M", "Macaco", "🐵"), ("N", "Nuvem", "☁️"), ("O", "Ovo", "🥚"),
        ("P", "Pato", "🦆"), ("Q", "Queijo", "🧀"), ("R", "Rato", "🐭"), ("S", "Sol", "☀️"), ("T", "Tigre", "🐯"),
        ("U", "Uva", "🍇"), ("V", "Vaca", "🐮"), ("W", "Wi-fi", "📶"), ("X", "Xadrez", "♟️"), ("Y", "Yoga", "🧘"), ("Z", "Zebra", "🦓")
    ]

    static let polish: [Entry] = [
        ("A", "Auto", "🚗"), ("Ą", "Ząb", "🦷"), ("B", "But", "👟"), ("C", "Cebula", "🧅"), ("Ć", "Ćma", "🦋"),
        ("D", "Dom", "🏠"), ("E", "Ekran", "🖥️"), ("Ę", "Gęś", "🪿"), ("F", "Foka", "🦭"), ("G", "Gwiazda", "⭐️"),
        ("H", "Hipopotam", "🦛"), ("I", "Igła", "🪡"), ("J", "Jabłko", "🍎"), ("K", "Kot", "🐱"), ("L", "Lis", "🦊"),
        ("Ł", "Łódka", "🚣"), ("M", "Mama", "👩"), ("N", "Noga", "🦵"), ("Ń", "Koń", "🐴"), ("O", "Osa", "🐝"),
        ("Ó", "Ósmy", "8️⃣"), ("P", "Piłka", "⚽️"), ("R", "Rak", "🦀"), ("S", "Słońce", "☀️"), ("Ś", "Śnieg", "❄️"),
        ("T", "Tygrys", "🐯"), ("U", "Ul", "🐝"), ("W", "Woda", "💧"), ("Y", "Ryba", "🐟"), ("Z", "Zebra", "🦓"),
        ("Ź", "Źrebak", "🐴"), ("Ż", "Żaba", "🐸")
    ]

    static let finnish: [Entry] = [
        ("A", "Auto", "🚗"), ("B", "Banaani", "🍌"), ("C", "Cembalo", "🎹"), ("D", "Delfiini", "🐬"), ("E", "Elefantti", "🐘"),
        ("F", "Feeni", "🔥"), ("G", "Gaselli", "🦌"), ("H", "Hattu", "🎩"), ("I", "Iglu", "🏠"), ("J", "Jäätelö", "🍦"),
        ("K", "Kissa", "🐱"), ("L", "Lintu", "🐦"), ("M", "Mansikka", "🍓"), ("N", "Nalle", "🧸"), ("O", "Omena", "🍎"),
        ("P", "Pallo", "⚽️"), ("Q", "Quokka", "🐹"), ("R", "Ruusu", "🌹"), ("S", "Sammakko", "🐸"), ("T", "Talo", "🏠"),
        ("U", "Uni", "😴"), ("V", "Veturi", "🚂"), ("W", "Waffle", "🧇"), ("X", "Xylofoni", "🎹"), ("Y", "Yö", "🌙"),
        ("Z", "Zebra", "🦓"), ("Å", "Åland", "🏝️"), ("Ä", "Äiti", "👩"), ("Ö", "Öljy", "🛢️")
    ]

    static let czech: [Entry] = [
        ("A", "Auto", "🚗"), ("Á", "Ábeceda", "🔤"), ("B", "Balón", "🎈"), ("C", "Citron", "🍋"), ("Č", "Čáp", "🐦"),
        ("D", "Dům", "🏠"), ("Ď", "Ďábel", "😈"), ("E", "Elefant", "🐘"), ("É", "Éra", "⏳"), ("Ě", "Měsíc", "🌙"),
        ("F", "Fotbal", "⚽️"), ("G", "Gitara", "🎸"), ("H", "Hrad", "🏰"), ("Ch", "Chleba", "🍞"), ("I", "Iglú", "🏠"),
        ("Í", "Íbis", "🦩"), ("J", "Jablko", "🍎"), ("K", "Kočka", "🐱"), ("L", "Liška", "🦊"), ("M", "Máma", "👩"),
        ("N", "Nos", "👃"), ("Ň", "Kůň", "🐴"), ("O", "Ovoce", "🍎"), ("Ó", "Móda", "👗"), ("P", "Pes", "🐶"),
        ("Q", "Quiz", "❓"), ("R", "Ryba", "🐟"), ("Ř", "Řeka", "🏞️"), ("S", "Slunce", "☀️"), ("Š", "Škola", "🏫"),
        ("T", "Tygr", "🐯"), ("Ť", "Labuť", "🦢"), ("U", "Úsměv", "😊"), ("Ú", "Úl", "🐝"), ("Ů", "Kůň", "🐴"),
        ("V", "Voda", "💧"), ("W", "Wifi", "📶"), ("X", "Xylofon", "🎹"), ("Y", "Ryba", "🐟"), ("Ý", "Papoušek", "🦜"),
        ("Z", "Zebra", "🦓"), ("Ž", "Žirafa", "🦒")
    ]

    // MARK: Arabic

    static let arabic: [Entry] = [
        ("ا", "أَسَد", "🦁"), ("ب", "بَطَّة", "🦆"), ("ت", "تُفَّاح", "🍎"), ("ث", "ثَعْلَب", "🦊"), ("ج", "جَمَل", "🐪"),
        ("ح", "حِصَان", "🐴"), ("خ", "خُبْز", "🍞"), ("د", "دُبّ", "🐻"), ("ذ", "ذِئْب", "🐺"), ("ر", "رُمَّان", "🍎"),
        ("ز", "زَرَافَة", "🦒"), ("س", "سَمَك", "🐟"), ("ش", "شَمْس", "☀️"), ("ص", "صَقْر", "🦅"), ("ض", "ضِفْدَع", "🐸"),
        ("ط", "طَائِرَة", "✈️"), ("ظ", "ظَبْي", "🦌"), ("ع", "عَسَل", "🍯"), ("غ", "غَزَال", "🦌"), ("ف", "فِيل", "🐘"),
        ("ق", "قِطَّة", "🐱"), ("ك", "كِتَاب", "📚"), ("ل", "لَيْمُون", "🍋"), ("م", "مَوْز", "🍌"), ("ن", "نَحْلَة", "🐝"),
        ("ه", "هِلَال", "🌙"), ("و", "وَرْدَة", "🌹"), ("ي", "يَد", "✋")
    ]

    // MARK: Chinese — Pinyin initials

    static let chinesePinyinInitials: [Entry] = [
        ("b", "爸爸 (bàba)", "👨"), ("p", "苹果 (píngguǒ)", "🍎"), ("m", "妈妈 (māma)", "👩"), ("f", "飞机 (fēijī)", "✈️"),
        ("d", "蛋糕 (dàngāo)", "🎂"), ("t", "兔子 (tùzi)", "🐰"), ("n", "牛奶 (niúnǎi)", "🥛"), ("l", "老虎 (lǎohǔ)", "🐯"),
        ("g", "狗 (gǒu)", "🐶"), ("k", "开心 (kāixīn)", "😄"), ("h", "花 (huā)", "🌸"),
        ("j", "鸡蛋 (jīdàn)", "🥚"), ("q", "铅笔 (qiānbǐ)", "✏️"), ("x", "西瓜 (xīguā)", "🍉"),
        ("zh", "猪 (zhū)", "🐷"), ("ch", "船 (chuán)", "🚢"), ("sh", "书 (shū)", "📖"), ("r", "热 (rè)", "🔥"),
        ("z", "字 (zì)", "🔤"), ("c", "菜 (cài)", "🥬"), ("s", "三 (sān)", "3️⃣"),
        ("y", "月亮 (yuèliang)", "🌙"), ("w", "娃娃 (wáwa)", "🎎")
    ]
}
