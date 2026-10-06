//
//  RhymeModels.swift
//  BabyAlphabetApp
//
//  Educational nursery-rhyme catalogue for babies/toddlers.
//  Songs are curated for learning: alphabet, phonics, counting, colors,
//  animals, body parts, manners, and classic language rhymes — not just
//  entertainment dances. Each entry embeds a public YouTube video via the
//  official player API.
//

import Foundation

/// What the rhyme is primarily teaching.
enum EducationalTopic: String, Codable, Hashable, CaseIterable {
    case alphabet
    case phonics
    case counting
    case colors
    case animals
    case body
    case manners
    case language
    case nature
    case shapes

    var label: String {
        switch self {
        case .alphabet: return "ABC"
        case .phonics: return "Phonics"
        case .counting: return "Counting"
        case .colors: return "Colors"
        case .animals: return "Animals"
        case .body: return "Body"
        case .manners: return "Manners"
        case .language: return "Words"
        case .nature: return "Nature"
        case .shapes: return "Shapes"
        }
    }

    var systemImage: String {
        switch self {
        case .alphabet: return "textformat.abc"
        case .phonics: return "ear.fill"
        case .counting: return "number"
        case .colors: return "paintpalette.fill"
        case .animals: return "pawprint.fill"
        case .body: return "figure.stand"
        case .manners: return "heart.fill"
        case .language: return "text.book.closed.fill"
        case .nature: return "leaf.fill"
        case .shapes: return "triangle.fill"
        }
    }
}

struct Rhyme: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let language: AppLanguage
    let youtubeVideoID: String
    let topic: EducationalTopic
    let audioFileName: String?
    let thumbnailSystemImage: String

    static func rhymes(for language: AppLanguage) -> [Rhyme] {
        catalogue.filter { $0.language == language }
    }

    static var catalogue: [Rhyme] {
        english + spanish + german + portuguese + polish
            + finnish + czech + arabic + chinese
    }

    private static func r(
        _ id: String,
        _ title: String,
        _ language: AppLanguage,
        _ video: String,
        _ topic: EducationalTopic,
        _ icon: String? = nil
    ) -> Rhyme {
        Rhyme(
            id: id,
            title: title,
            language: language,
            youtubeVideoID: video,
            topic: topic,
            audioFileName: nil,
            thumbnailSystemImage: icon ?? topic.systemImage
        )
    }

    // MARK: English — alphabet, phonics, counting, animals, manners

    static let english: [Rhyme] = [
        r("en01", "The Alphabet Song", .english, "vD98OvvDNEs", .alphabet),
        r("en02", "The ABC Song", .english, "75p-N9YKqNo", .alphabet),
        r("en03", "ABC Song Collection", .english, "71h8MZshGSs", .alphabet),
        r("en04", "ABC Song (Zed Version)", .english, "zKF97IQ4nV0", .alphabet),
        r("en05", "Phonics Song — A for Apple", .english, "hq3yfQnllfQ", .phonics),
        r("en06", "One Little Finger", .english, "eBVqcTEC3zQ", .body),
        r("en07", "Hello! Greeting Song", .english, "tVlcKp3bWH8", .manners),
        r("en08", "Five Little Ducks (Counting)", .english, "LrAtBtQnvCE", .counting),
        r("en09", "Let's Count 5 Little Ducks", .english, "Z_sWD5iSE0w", .counting),
        r("en10", "Five Little Speckled Frogs", .english, "XaJSlYMFHyQ", .counting),
        r("en11", "Five Little Monkeys", .english, "VTmmoaO2M_U", .counting),
        r("en12", "Ten in the Bed (Counting)", .english, "i1yHAg9cpU4", .counting),
        r("en13", "1, 2, It's Time For School", .english, "Maa08M4cApI", .counting),
        r("en14", "Old MacDonald Had a Farm", .english, "lWhqORImND0", .animals),
        r("en15", "Animals on the Farm", .english, "9FcCV286-gA", .animals),
        r("en16", "There's An Animal That I See", .english, "PmpJzVCIisc", .animals),
        r("en17", "Five Little Chicks", .english, "4iKQbtajlII", .animals),
        r("en18", "Baa Baa Black Sheep", .english, "YanYDTGkLH8", .animals),
        r("en19", "Top Animal Learning Songs", .english, "ecVQvgnKDug", .animals),
        r("en20", "Twinkle Twinkle Little Star", .english, "yCjJyiqpAuU", .language),
        r("en21", "Twinkle Twinkle (CoComelon)", .english, "hqzvHfy-Ij0", .language),
        r("en22", "Wheels on the Bus (vocabulary)", .english, "9UasekNr8KI", .language),
        r("en23", "Wheels on the Bus (CoComelon)", .english, "e_04ZrNroTo", .language),
        r("en24", "Put On Your Shoes (routines)", .english, "Hf6oXuf7VbA", .manners),
        r("en25", "Backpack Song — School Ready", .english, "3kEhqNW7-74", .manners),
        r("en26", "Making Friends Song", .english, "3DcELlZBFbk", .manners),
        r("en27", "Playground Sharing Song", .english, "2B2LVuIQ9JU", .manners),
        r("en28", "Fruit Is Yummy (food words)", .english, "DDjOLRNby20", .language),
        r("en29", "Yes Yes Vegetables Song", .english, "ohHYABXMqUQ", .language),
        r("en30", "Yes Yes Fruits Song", .english, "mbPNkDEN3Ps", .language),
        r("en31", "Rain Rain Go Away (weather)", .english, "j3kVbef2Zs4", .nature),
        r("en32", "Spring Songs for Kids", .english, "sMiz_oGY1kA", .nature),
        r("en33", "Summer Nature Songs", .english, "7UoHjPAgmb8", .nature),
        r("en34", "Humpty Dumpty", .english, "0n_J2z-ILXo", .language),
        r("en35", "London Bridge", .english, "Ser69-nsRNs", .language),
        r("en36", "The Grand Old Duke Of York", .english, "esmzngqIr88", .counting),
        r("en37", "Six Little Ducks (counting)", .english, "rznk5RNGjbY", .counting),
        r("en38", "Three Little Kittens", .english, "-pQutVzAm9Y", .animals),
        r("en39", "Peek-A-Boo (object permanence)", .english, "fdPu-wvl3KE", .language),
        r("en40", "Johny Johny Yes Papa (truth)", .english, "D1LDPmYoYm4", .manners),
        r("en41", "Bath Song (routines)", .english, "WRVsOCh907o", .manners),
        r("en42", "Sleeping Bunnies (calm down)", .english, "Vx3RFjQEqt0", .manners),
        r("en43", "Hush Little Baby", .english, "S0cgaoDUggg", .language),
        r("en44", "Bedtime Learning Lullabies", .english, "RIJ4MTjQfFo", .language),
        r("en45", "Colour Sensory Twinkle", .english, "ZjtRA6brbPw", .colors),
        r("en46", "Five Little Ducks (LBB)", .english, "F2OpkQuOjig", .counting),
        r("en47", "Ten Little Buses (counting)", .english, "emC3qoSyfnQ", .counting),
        r("en48", "ABC, Colors & 123 Learning Mix", .english, "TBRdYaYTs18", .alphabet),
        r("en49", "ABC Phonics for Babies", .english, "UQthLMdsQak", .phonics),
        r("en50", "Learn ABCs, Colors & Growing Up", .english, "vkRDOcma9Qk", .alphabet)
    ]

    // MARK: Spanish — letras, números, animales, valores

    static let spanish: [Rhyme] = [
        r("es01", "Estrellita ¿Dónde Estás?", .spanish, "ZM5syHyHDYE", .language),
        r("es02", "Los Pollitos Dicen", .spanish, "S1EAGBz3YfM", .animals),
        r("es03", "Los Pollitos Dicen (Canti Rondas)", .spanish, "kA9voL0edJU", .animals),
        r("es04", "La Vaca Lola (animales)", .spanish, "eNLjdPI9zdE", .animals),
        r("es05", "La Vaca Lola (Toy Cantando)", .spanish, "0dkHZYeIGIk", .animals),
        r("es06", "El Gallo y la Pata", .spanish, "0aZ7lPQ5EXs", .animals),
        r("es07", "La Rana", .spanish, "wsIQq6W4lpo", .animals),
        r("es08", "Las Hormiguitas Van Marchando", .spanish, "vU4j9vzGRUI", .animals),
        r("es09", "Canciones del Zoo (aprender animales)", .spanish, "HFIDxXNLC50", .animals),
        r("es10", "El Baile de los Animales", .spanish, "HRs7Dfxl2-c", .animals),
        r("es11", "Los Tres Chanchitos", .spanish, "fwLWaGcBaRw", .language),
        r("es12", "Hola Don Pepito (saludos)", .spanish, "8tXb_uRe2IM", .manners),
        r("es13", "Susanita", .spanish, "ttyviOjuTMU", .language),
        r("es14", "Johny Johny Sí Papá", .spanish, "sCbYpBOv7EI", .manners),
        r("es15", "Bartolito", .spanish, "ebVVuJN1WFM", .animals),
        r("es16", "Mejores Canciones de la Granja", .spanish, "B1svxwMuLf4", .animals),
        r("es17", "La Granja de Zenón — Lo Mejor", .spanish, "Fy93n4Xvq78", .animals),
        r("es18", "Canciones para Bebés (40 min)", .spanish, "lMZzkxszfWE", .language),
        r("es19", "Especial Bichikids", .spanish, "cMh3UpSzN8U", .animals),
        r("es20", "Clásicos Infantiles", .spanish, "Syd8V713JZ0", .language),
        r("es21", "La Batalla del Movimiento", .spanish, "AlZeLejiuio", .body),
        r("es22", "Alphabet Song (aprender inglés)", .spanish, "vD98OvvDNEs", .alphabet),
        r("es23", "Phonics — A for Apple", .spanish, "hq3yfQnllfQ", .phonics),
        r("es24", "Five Little Ducks (contar)", .spanish, "LrAtBtQnvCE", .counting),
        r("es25", "Let's Count 5 Little Ducks", .spanish, "Z_sWD5iSE0w", .counting),
        r("es26", "One Little Finger", .spanish, "eBVqcTEC3zQ", .body),
        r("es27", "Hello Greeting Song", .spanish, "tVlcKp3bWH8", .manners),
        r("es28", "Animals on the Farm", .spanish, "9FcCV286-gA", .animals),
        r("es29", "Fruit Is Yummy", .spanish, "DDjOLRNby20", .language),
        r("es30", "Yes Yes Vegetables", .spanish, "ohHYABXMqUQ", .language),
        r("es31", "Twinkle Twinkle Little Star", .spanish, "yCjJyiqpAuU", .language),
        r("es32", "Wheels on the Bus", .spanish, "9UasekNr8KI", .language),
        r("es33", "Making Friends Song", .spanish, "3DcELlZBFbk", .manners),
        r("es34", "Put On Your Shoes", .spanish, "Hf6oXuf7VbA", .manners),
        r("es35", "ABC Colors & 123", .spanish, "TBRdYaYTs18", .alphabet),
        r("es36", "ABC Phonics", .spanish, "UQthLMdsQak", .phonics),
        r("es37", "Five Little Speckled Frogs", .spanish, "XaJSlYMFHyQ", .counting),
        r("es38", "There's An Animal That I See", .spanish, "PmpJzVCIisc", .animals),
        r("es39", "Rain Rain Go Away", .spanish, "j3kVbef2Zs4", .nature),
        r("es40", "School Ready Backpack Song", .spanish, "3kEhqNW7-74", .manners),
        r("es41", "Los Pollitos — Gallina Pintadita", .spanish, "qcOiqtMsjes", .animals),
        r("es42", "La Vaca Lola y Más Animales", .spanish, "lwT6hU6Y7uw", .animals),
        r("es43", "Vaca Lola y Su Familia", .spanish, "vpnVxrsVv6M", .animals),
        r("es44", "Pollitos + Más Canciones", .spanish, "iZOoWF2dh1M", .animals),
        r("es45", "Learn ABCs & Colors Mix", .spanish, "vkRDOcma9Qk", .alphabet)
    ]

    // MARK: German — ABC, Zahlen, Farben, Tiere

    static let german: [Rhyme] = [
        r("de01", "Das ABC-Lied", .german, "Hgx0RTx0aFg", .alphabet),
        r("de02", "Alle meine Entchen", .german, "TBT6edKlNj4", .animals),
        r("de03", "Hänschen klein", .german, "estWuexvkqs", .language),
        r("de04", "Grün, grün, grün (Farben)", .german, "AGrsasgsFuQ", .colors),
        r("de05", "Fünf kleine Fische (zählen)", .german, "p51c5g1iNzw", .counting),
        r("de06", "Die Räder vom Bus", .german, "d1hLy1zxHTY", .language),
        r("de07", "Sonnenkäfer-Lied", .german, "gtLyj6SE8h8", .nature),
        r("de08", "Was müssen das für Bäume sein", .german, "fSGSIZAu87w", .nature),
        r("de09", "Wer will fleißige Handwerker sehn", .german, "-jSvfhXl0pQ", .manners),
        r("de10", "Das ist gerade, das ist schief (Formen)", .german, "rJWZhitXWzI", .shapes),
        r("de11", "Bruder Jakob Maxi-Mix", .german, "3Q2j-LOabrg", .language),
        r("de12", "Die Fliege Flo", .german, "JufAu7Vu53k", .animals),
        r("de13", "Lustiges Katzenlied", .german, "3cpBqASDmwE", .animals),
        r("de14", "Guten Appetit", .german, "96Y1zP6Lj34", .manners),
        r("de15", "Der kleine Tausendfüßler", .german, "HIzya5U-Xvc", .animals),
        r("de16", "Kindergarten Mix (lernen & bewegen)", .german, "DBOxXxdg5yQ", .body),
        r("de17", "Hoppe Hoppe & Lernlieder", .german, "Rh3CxT0p0m8", .language),
        r("de18", "Kinderlieder Mix (60 Min)", .german, "R6KqXS4Ilas", .language),
        r("de19", "Sechs Lieder zum Mitsingen", .german, "riF8E7wtZH8", .language),
        r("de20", "Alphabet Song (Englisch ABC)", .german, "vD98OvvDNEs", .alphabet),
        r("de21", "Phonics — A for Apple", .german, "hq3yfQnllfQ", .phonics),
        r("de22", "Five Little Ducks (zählen)", .german, "LrAtBtQnvCE", .counting),
        r("de23", "Let's Count 5 Little Ducks", .german, "Z_sWD5iSE0w", .counting),
        r("de24", "One Little Finger", .german, "eBVqcTEC3zQ", .body),
        r("de25", "Hello Greeting Song", .german, "tVlcKp3bWH8", .manners),
        r("de26", "Animals on the Farm", .german, "9FcCV286-gA", .animals),
        r("de27", "Old MacDonald", .german, "lWhqORImND0", .animals),
        r("de28", "Fruit Is Yummy", .german, "DDjOLRNby20", .language),
        r("de29", "Yes Yes Vegetables", .german, "ohHYABXMqUQ", .language),
        r("de30", "Twinkle Twinkle Little Star", .german, "yCjJyiqpAuU", .language),
        r("de31", "Making Friends Song", .german, "3DcELlZBFbk", .manners),
        r("de32", "Put On Your Shoes", .german, "Hf6oXuf7VbA", .manners),
        r("de33", "ABC Colors & 123", .german, "TBRdYaYTs18", .alphabet),
        r("de34", "ABC Phonics", .german, "UQthLMdsQak", .phonics),
        r("de35", "Five Little Speckled Frogs", .german, "XaJSlYMFHyQ", .counting),
        r("de36", "There's An Animal That I See", .german, "PmpJzVCIisc", .animals),
        r("de37", "Rain Rain Go Away", .german, "j3kVbef2Zs4", .nature),
        r("de38", "School Ready Backpack Song", .german, "3kEhqNW7-74", .manners),
        r("de39", "Hänschen klein (Liederkiste)", .german, "FuBEvX5yWPA", .language),
        r("de40", "Mitmachlied — Konzentration", .german, "PxeXIWrxZOw", .body),
        r("de41", "Familie Blubber-Pudding Stop", .german, "9jWNq_o-KDk", .manners),
        r("de42", "Learn ABCs & Colors Mix", .german, "vkRDOcma9Qk", .alphabet),
        r("de43", "Five Little Monkeys (zählen)", .german, "VTmmoaO2M_U", .counting),
        r("de44", "Baa Baa Black Sheep", .german, "YanYDTGkLH8", .animals),
        r("de45", "Colour Sensory Twinkle", .german, "ZjtRA6brbPw", .colors)
    ]

    // MARK: Portuguese — alfabeto, contagem, animais, rotinas

    static let portuguese: [Rhyme] = [
        r("pt01", "Ciranda Cirandinha", .portuguese, "qzEcHMqqcuE", .language),
        r("pt02", "As Rodas do Ônibus (vocabulário)", .portuguese, "DIHj_jWp_28", .language),
        r("pt03", "Pombinha Branca", .portuguese, "x18-bbbTASQ", .animals),
        r("pt04", "Pintinho Amarelinho", .portuguese, "59GM_xjPhco", .animals),
        r("pt05", "Coelhinho", .portuguese, "nS-yJupHhOc", .animals),
        r("pt06", "Upa Cavalinho", .portuguese, "Fn9adh4HWUU", .animals),
        r("pt07", "Alecrim Dourado", .portuguese, "NAL4isDM4D0", .nature),
        r("pt08", "Mariana (contar)", .portuguese, "orxxp-3gBiE", .counting),
        r("pt09", "Se Essa Rua Fosse Minha", .portuguese, "IuZf_xTt_JU", .language),
        r("pt10", "Galinha Pintadinha 1 — Álbum", .portuguese, "5P8GcCpmGYQ", .language),
        r("pt11", "Galinha Pintadinha Original", .portuguese, "1i7p0vTGcBk", .language),
        r("pt12", "Galinha Pintadinha 2", .portuguese, "H2PQFsj-Lho", .language),
        r("pt13", "Parabéns da Galinha Pintadinha", .portuguese, "ei2-RjJDBHc", .manners),
        r("pt14", "Alphabet Song (ABC)", .portuguese, "vD98OvvDNEs", .alphabet),
        r("pt15", "Phonics — A for Apple", .portuguese, "hq3yfQnllfQ", .phonics),
        r("pt16", "Five Little Ducks (contar)", .portuguese, "LrAtBtQnvCE", .counting),
        r("pt17", "Let's Count 5 Little Ducks", .portuguese, "Z_sWD5iSE0w", .counting),
        r("pt18", "One Little Finger", .portuguese, "eBVqcTEC3zQ", .body),
        r("pt19", "Hello Greeting Song", .portuguese, "tVlcKp3bWH8", .manners),
        r("pt20", "Animals on the Farm", .portuguese, "9FcCV286-gA", .animals),
        r("pt21", "Old MacDonald", .portuguese, "lWhqORImND0", .animals),
        r("pt22", "Fruit Is Yummy", .portuguese, "DDjOLRNby20", .language),
        r("pt23", "Yes Yes Vegetables", .portuguese, "ohHYABXMqUQ", .language),
        r("pt24", "Twinkle Twinkle Little Star", .portuguese, "yCjJyiqpAuU", .language),
        r("pt25", "Wheels on the Bus", .portuguese, "9UasekNr8KI", .language),
        r("pt26", "Making Friends Song", .portuguese, "3DcELlZBFbk", .manners),
        r("pt27", "Put On Your Shoes", .portuguese, "Hf6oXuf7VbA", .manners),
        r("pt28", "ABC Colors & 123", .portuguese, "TBRdYaYTs18", .alphabet),
        r("pt29", "ABC Phonics", .portuguese, "UQthLMdsQak", .phonics),
        r("pt30", "Five Little Speckled Frogs", .portuguese, "XaJSlYMFHyQ", .counting),
        r("pt31", "There's An Animal That I See", .portuguese, "PmpJzVCIisc", .animals),
        r("pt32", "Rain Rain Go Away", .portuguese, "j3kVbef2Zs4", .nature),
        r("pt33", "School Ready Backpack Song", .portuguese, "3kEhqNW7-74", .manners),
        r("pt34", "Johny Johny Yes Papa", .portuguese, "D1LDPmYoYm4", .manners),
        r("pt35", "Learn ABCs & Colors Mix", .portuguese, "vkRDOcma9Qk", .alphabet),
        r("pt36", "Five Little Monkeys", .portuguese, "VTmmoaO2M_U", .counting),
        r("pt37", "Baa Baa Black Sheep", .portuguese, "YanYDTGkLH8", .animals),
        r("pt38", "Colour Sensory Twinkle", .portuguese, "ZjtRA6brbPw", .colors),
        r("pt39", "ABC Song Collection", .portuguese, "71h8MZshGSs", .alphabet),
        r("pt40", "Ten Little Buses (contar)", .portuguese, "emC3qoSyfnQ", .counting),
        r("pt41", "Careca do Vovô", .portuguese, "agSvWFCXZdY", .language),
        r("pt42", "Para o Papai", .portuguese, "zSeIUjMJgoM", .manners),
        r("pt43", "Tumbalacatumba", .portuguese, "ZRhNGBeQ1pg", .language),
        r("pt44", "Five Little Chicks", .portuguese, "4iKQbtajlII", .animals),
        r("pt45", "Sleeping Bunnies (acalmar)", .portuguese, "Vx3RFjQEqt0", .manners)
    ]

    // MARK: Polish — abecadło, liczenie, zwierzęta

    static let polish: [Rhyme] = [
        r("pl01", "Wlazł Kotek Na Płotek", .polish, "HIlQi7YIKkY", .animals),
        r("pl02", "Stary Niedźwiedź Mocno Śpi", .polish, "GYOM-j9Ztbg", .language),
        r("pl03", "Była Sobie Żabka Mała", .polish, "u0sql4bx4PI", .language),
        r("pl04", "Kaczuszki", .polish, "ivRF0VJQeZ4", .animals),
        r("pl05", "5 Małych Kaczątek (liczenie)", .polish, "m9GNb50gmlk", .counting),
        r("pl06", "Koła Autobusu po polsku", .polish, "NngttVvlUUI", .language),
        r("pl07", "Błyskaj Błyskaj Gwiazdko", .polish, "7e3qQ6yFhio", .language),
        r("pl08", "Jedzie pociąg z daleka", .polish, "N2RcySctK9E", .language),
        r("pl09", "Idą lisy dwa", .polish, "s4miMHASFyE", .animals),
        r("pl10", "Jadą Jadą Misie", .polish, "2RxtxuJCtuQ", .animals),
        r("pl11", "Idziemy na Jagody", .polish, "ACz9SosBxaE", .nature),
        r("pl12", "Jestem Sobie Przedszkolaczek", .polish, "xsS4IenewiQ", .manners),
        r("pl13", "Kółko Graniaste (kształty)", .polish, "Fq0m3AWitCQ", .shapes),
        r("pl14", "Mam Chusteczkę Haftowaną", .polish, "hXhg359KMTk", .manners),
        r("pl15", "Aaa kotki dwa", .polish, "SogW3o8N7Dc", .animals),
        r("pl16", "Alphabet Song (ABC)", .polish, "vD98OvvDNEs", .alphabet),
        r("pl17", "Phonics — A for Apple", .polish, "hq3yfQnllfQ", .phonics),
        r("pl18", "Five Little Ducks (liczenie)", .polish, "LrAtBtQnvCE", .counting),
        r("pl19", "Let's Count 5 Little Ducks", .polish, "Z_sWD5iSE0w", .counting),
        r("pl20", "One Little Finger", .polish, "eBVqcTEC3zQ", .body),
        r("pl21", "Hello Greeting Song", .polish, "tVlcKp3bWH8", .manners),
        r("pl22", "Animals on the Farm", .polish, "9FcCV286-gA", .animals),
        r("pl23", "Old MacDonald", .polish, "lWhqORImND0", .animals),
        r("pl24", "Fruit Is Yummy", .polish, "DDjOLRNby20", .language),
        r("pl25", "Yes Yes Vegetables", .polish, "ohHYABXMqUQ", .language),
        r("pl26", "Twinkle Twinkle Little Star", .polish, "yCjJyiqpAuU", .language),
        r("pl27", "Making Friends Song", .polish, "3DcELlZBFbk", .manners),
        r("pl28", "Put On Your Shoes", .polish, "Hf6oXuf7VbA", .manners),
        r("pl29", "ABC Colors & 123", .polish, "TBRdYaYTs18", .alphabet),
        r("pl30", "ABC Phonics", .polish, "UQthLMdsQak", .phonics),
        r("pl31", "Five Little Speckled Frogs", .polish, "XaJSlYMFHyQ", .counting),
        r("pl32", "There's An Animal That I See", .polish, "PmpJzVCIisc", .animals),
        r("pl33", "Rain Rain Go Away", .polish, "j3kVbef2Zs4", .nature),
        r("pl34", "School Ready Backpack Song", .polish, "3kEhqNW7-74", .manners),
        r("pl35", "Learn ABCs & Colors Mix", .polish, "vkRDOcma9Qk", .alphabet),
        r("pl36", "Five Little Monkeys", .polish, "VTmmoaO2M_U", .counting),
        r("pl37", "Baa Baa Black Sheep", .polish, "YanYDTGkLH8", .animals),
        r("pl38", "Colour Sensory Twinkle", .polish, "ZjtRA6brbPw", .colors),
        r("pl39", "Ta Dorotka", .polish, "fh2iFzwrw-c", .language),
        r("pl40", "Koła Autobusu (1 godzina)", .polish, "LXcBiimjZpA", .language),
        r("pl41", "Błyskaj Gwiazdko Ma", .polish, "vQ8s2fuaweA", .language),
        r("pl42", "WLAZŁ KOTEK — Śpiewanki", .polish, "oFIcur948JY", .animals),
        r("pl43", "ABC Song Collection", .polish, "71h8MZshGSs", .alphabet),
        r("pl44", "Ten Little Buses", .polish, "emC3qoSyfnQ", .counting),
        r("pl45", "Five Little Chicks", .polish, "4iKQbtajlII", .animals)
    ]

    // MARK: Finnish — aakkoset, laskeminen, värit, eläimet

    static let finnish: [Rhyme] = [
        r("fi01", "Värilaulu (värit)", .finnish, "vYZn6Fl6b2k", .colors),
        r("fi02", "Viisi pientä sammakkoa (laskeminen)", .finnish, "BXKer7Sca_0", .counting),
        r("fi03", "Kolme pientä possua", .finnish, "FZSCTPxZRqE", .animals),
        r("fi04", "Hämä-hämähäkki / eläinlauluja", .finnish, "Jim3sAJI_ic", .animals),
        r("fi05", "Bussin pyörät (Wheels on the Bus)", .finnish, "9UasekNr8KI", .language),
        r("fi06", "Yhdessä on hauskempaa (ystävyys)", .finnish, "oJzyQX4f2Ew", .manners),
        r("fi07", "Ensimmäinen Koulupäivä", .finnish, "8xAetvTJ_OE", .manners),
        r("fi08", "Saku Sammakko + Lastenlauluja", .finnish, "Jim3sAJI_ic", .language),
        r("fi09", "Maalaistalon Rakensin", .finnish, "uBTwnxl4CDo", .animals),
        r("fi10", "Alphabet Song (ABC)", .finnish, "vD98OvvDNEs", .alphabet),
        r("fi11", "Phonics — A for Apple", .finnish, "hq3yfQnllfQ", .phonics),
        r("fi12", "Five Little Ducks (laskeminen)", .finnish, "LrAtBtQnvCE", .counting),
        r("fi13", "Let's Count 5 Little Ducks", .finnish, "Z_sWD5iSE0w", .counting),
        r("fi14", "One Little Finger", .finnish, "eBVqcTEC3zQ", .body),
        r("fi15", "Hello Greeting Song", .finnish, "tVlcKp3bWH8", .manners),
        r("fi16", "Animals on the Farm", .finnish, "9FcCV286-gA", .animals),
        r("fi17", "Old MacDonald", .finnish, "lWhqORImND0", .animals),
        r("fi18", "Fruit Is Yummy", .finnish, "DDjOLRNby20", .language),
        r("fi19", "Yes Yes Vegetables", .finnish, "ohHYABXMqUQ", .language),
        r("fi20", "Twinkle Twinkle Little Star", .finnish, "yCjJyiqpAuU", .language),
        r("fi21", "Wheels on the Bus", .finnish, "9UasekNr8KI", .language),
        r("fi22", "Making Friends Song", .finnish, "3DcELlZBFbk", .manners),
        r("fi23", "Put On Your Shoes", .finnish, "Hf6oXuf7VbA", .manners),
        r("fi24", "ABC Colors & 123", .finnish, "TBRdYaYTs18", .alphabet),
        r("fi25", "ABC Phonics", .finnish, "UQthLMdsQak", .phonics),
        r("fi26", "Five Little Speckled Frogs", .finnish, "XaJSlYMFHyQ", .counting),
        r("fi27", "There's An Animal That I See", .finnish, "PmpJzVCIisc", .animals),
        r("fi28", "Rain Rain Go Away", .finnish, "j3kVbef2Zs4", .nature),
        r("fi29", "School Ready Backpack Song", .finnish, "3kEhqNW7-74", .manners),
        r("fi30", "Learn ABCs & Colors Mix", .finnish, "vkRDOcma9Qk", .alphabet),
        r("fi31", "Five Little Monkeys", .finnish, "VTmmoaO2M_U", .counting),
        r("fi32", "Baa Baa Black Sheep", .finnish, "YanYDTGkLH8", .animals),
        r("fi33", "Colour Sensory Twinkle", .finnish, "ZjtRA6brbPw", .colors),
        r("fi34", "ABC Song Collection", .finnish, "71h8MZshGSs", .alphabet),
        r("fi35", "Ten Little Buses", .finnish, "emC3qoSyfnQ", .counting),
        r("fi36", "Five Little Chicks", .finnish, "4iKQbtajlII", .animals),
        r("fi37", "Johny Johny Yes Papa", .finnish, "D1LDPmYoYm4", .manners),
        r("fi38", "Sleeping Bunnies", .finnish, "Vx3RFjQEqt0", .manners),
        r("fi39", "Hush Little Baby", .finnish, "S0cgaoDUggg", .language),
        r("fi40", "Spring Songs for Kids", .finnish, "sMiz_oGY1kA", .nature),
        r("fi41", "Summer Nature Songs", .finnish, "7UoHjPAgmb8", .nature),
        r("fi42", "Top Animal Learning Songs", .finnish, "ecVQvgnKDug", .animals),
        r("fi43", "The ABC Song", .finnish, "75p-N9YKqNo", .alphabet),
        r("fi44", "Six Little Ducks", .finnish, "rznk5RNGjbY", .counting),
        r("fi45", "Playground Sharing Song", .finnish, "2B2LVuIQ9JU", .manners)
    ]

    // MARK: Czech — abeceda, počítání, zvířata

    static let czech: [Rhyme] = [
        r("cs01", "Kočka leze dírou", .czech, "NhpuRtHNNNQ", .animals),
        r("cs02", "Kočka Leze Dírou (HeyKids)", .czech, "hROd7e-lCYo", .animals),
        r("cs03", "Štístko a Poupěnka — Kočka leze dírou", .czech, "gQQgxetMWck", .animals),
        r("cs04", "Písničky pro děti a nejmenší", .czech, "hqukPkgqkv8", .language),
        r("cs05", "Já mám koně / Skákal pes", .czech, "pHgBU06CwII", .animals),
        r("cs06", "Alphabet Song (ABC)", .czech, "vD98OvvDNEs", .alphabet),
        r("cs07", "Phonics — A for Apple", .czech, "hq3yfQnllfQ", .phonics),
        r("cs08", "Five Little Ducks (počítání)", .czech, "LrAtBtQnvCE", .counting),
        r("cs09", "Let's Count 5 Little Ducks", .czech, "Z_sWD5iSE0w", .counting),
        r("cs10", "One Little Finger", .czech, "eBVqcTEC3zQ", .body),
        r("cs11", "Hello Greeting Song", .czech, "tVlcKp3bWH8", .manners),
        r("cs12", "Animals on the Farm", .czech, "9FcCV286-gA", .animals),
        r("cs13", "Old MacDonald", .czech, "lWhqORImND0", .animals),
        r("cs14", "Fruit Is Yummy", .czech, "DDjOLRNby20", .language),
        r("cs15", "Yes Yes Vegetables", .czech, "ohHYABXMqUQ", .language),
        r("cs16", "Twinkle Twinkle Little Star", .czech, "yCjJyiqpAuU", .language),
        r("cs17", "Wheels on the Bus", .czech, "9UasekNr8KI", .language),
        r("cs18", "Making Friends Song", .czech, "3DcELlZBFbk", .manners),
        r("cs19", "Put On Your Shoes", .czech, "Hf6oXuf7VbA", .manners),
        r("cs20", "ABC Colors & 123", .czech, "TBRdYaYTs18", .alphabet),
        r("cs21", "ABC Phonics", .czech, "UQthLMdsQak", .phonics),
        r("cs22", "Five Little Speckled Frogs", .czech, "XaJSlYMFHyQ", .counting),
        r("cs23", "There's An Animal That I See", .czech, "PmpJzVCIisc", .animals),
        r("cs24", "Rain Rain Go Away", .czech, "j3kVbef2Zs4", .nature),
        r("cs25", "School Ready Backpack Song", .czech, "3kEhqNW7-74", .manners),
        r("cs26", "Learn ABCs & Colors Mix", .czech, "vkRDOcma9Qk", .alphabet),
        r("cs27", "Five Little Monkeys", .czech, "VTmmoaO2M_U", .counting),
        r("cs28", "Baa Baa Black Sheep", .czech, "YanYDTGkLH8", .animals),
        r("cs29", "Colour Sensory Twinkle", .czech, "ZjtRA6brbPw", .colors),
        r("cs30", "ABC Song Collection", .czech, "71h8MZshGSs", .alphabet),
        r("cs31", "Ten Little Buses", .czech, "emC3qoSyfnQ", .counting),
        r("cs32", "Five Little Chicks", .czech, "4iKQbtajlII", .animals),
        r("cs33", "Johny Johny Yes Papa", .czech, "D1LDPmYoYm4", .manners),
        r("cs34", "Sleeping Bunnies", .czech, "Vx3RFjQEqt0", .manners),
        r("cs35", "The ABC Song", .czech, "75p-N9YKqNo", .alphabet),
        r("cs36", "Spring Songs for Kids", .czech, "sMiz_oGY1kA", .nature),
        r("cs37", "Top Animal Learning Songs", .czech, "ecVQvgnKDug", .animals),
        r("cs38", "Playground Sharing Song", .czech, "2B2LVuIQ9JU", .manners),
        r("cs39", "Six Little Ducks", .czech, "rznk5RNGjbY", .counting),
        r("cs40", "London Bridge", .czech, "Ser69-nsRNs", .language),
        r("cs41", "Humpty Dumpty", .czech, "0n_J2z-ILXo", .language),
        r("cs42", "Hush Little Baby", .czech, "S0cgaoDUggg", .language),
        r("cs43", "Bath Song (routines)", .czech, "WRVsOCh907o", .manners),
        r("cs44", "Yes Yes Fruits Song", .czech, "mbPNkDEN3Ps", .language),
        r("cs45", "Three Little Kittens", .czech, "-pQutVzAm9Y", .animals)
    ]

    // MARK: Arabic — الحروف، الأرقام، الحيوانات

    static let arabic: [Rhyme] = [
        r("ar01", "أنشودة الحروف العربية", .arabic, "BNJvJaLzJXA", .alphabet),
        r("ar02", "الحروف مع الحيوانات", .arabic, "Z1nHxBdgak4", .alphabet),
        r("ar03", "ألف أرنب — أنشودة الحروف", .arabic, "_hnX1yLxMMo", .alphabet),
        r("ar04", "Arabic Alphabet Song with Zaky", .arabic, "6e145BWP7ng", .alphabet),
        r("ar05", "Alif Arnab Alphabet Song", .arabic, "-cJu5dlnlYM", .alphabet),
        r("ar06", "Arabic Alphabet Flash Cards", .arabic, "lHaPOryRuLY", .alphabet),
        r("ar07", "Arabic Alphabet with Princess Fatimah", .arabic, "umFBj0wZ1Vw", .alphabet),
        r("ar08", "BEST Arabic Alphabet Song", .arabic, "0xYy3D6zYgY", .alphabet),
        r("ar09", "Alifun Ba Arabic Alphabet Nasheed", .arabic, "_ZUxN0DWhkA", .alphabet),
        r("ar10", "Arabic Alphabet Song Episode 2", .arabic, "_ApgTIYyJTM", .alphabet),
        r("ar11", "Alif Baa Taa Song", .arabic, "TEX6QSoqYig", .alphabet),
        r("ar12", "Arabic Alphabet Phonics Kids Song", .arabic, "hp2z-X67cjY", .phonics),
        r("ar13", "Alphabet Song (English ABC)", .arabic, "vD98OvvDNEs", .alphabet),
        r("ar14", "Phonics — A for Apple", .arabic, "hq3yfQnllfQ", .phonics),
        r("ar15", "Five Little Ducks (counting)", .arabic, "LrAtBtQnvCE", .counting),
        r("ar16", "Let's Count 5 Little Ducks", .arabic, "Z_sWD5iSE0w", .counting),
        r("ar17", "One Little Finger", .arabic, "eBVqcTEC3zQ", .body),
        r("ar18", "Hello Greeting Song", .arabic, "tVlcKp3bWH8", .manners),
        r("ar19", "Animals on the Farm", .arabic, "9FcCV286-gA", .animals),
        r("ar20", "Old MacDonald", .arabic, "lWhqORImND0", .animals),
        r("ar21", "Fruit Is Yummy", .arabic, "DDjOLRNby20", .language),
        r("ar22", "Yes Yes Vegetables", .arabic, "ohHYABXMqUQ", .language),
        r("ar23", "Twinkle Twinkle Little Star", .arabic, "yCjJyiqpAuU", .language),
        r("ar24", "Wheels on the Bus", .arabic, "9UasekNr8KI", .language),
        r("ar25", "Making Friends Song", .arabic, "3DcELlZBFbk", .manners),
        r("ar26", "Put On Your Shoes", .arabic, "Hf6oXuf7VbA", .manners),
        r("ar27", "ABC Colors & 123", .arabic, "TBRdYaYTs18", .alphabet),
        r("ar28", "ABC Phonics", .arabic, "UQthLMdsQak", .phonics),
        r("ar29", "Five Little Speckled Frogs", .arabic, "XaJSlYMFHyQ", .counting),
        r("ar30", "There's An Animal That I See", .arabic, "PmpJzVCIisc", .animals),
        r("ar31", "Rain Rain Go Away", .arabic, "j3kVbef2Zs4", .nature),
        r("ar32", "School Ready Backpack Song", .arabic, "3kEhqNW7-74", .manners),
        r("ar33", "Learn ABCs & Colors Mix", .arabic, "vkRDOcma9Qk", .alphabet),
        r("ar34", "Five Little Monkeys", .arabic, "VTmmoaO2M_U", .counting),
        r("ar35", "Baa Baa Black Sheep", .arabic, "YanYDTGkLH8", .animals),
        r("ar36", "Colour Sensory Twinkle", .arabic, "ZjtRA6brbPw", .colors),
        r("ar37", "ABC Song Collection", .arabic, "71h8MZshGSs", .alphabet),
        r("ar38", "Ten Little Buses", .arabic, "emC3qoSyfnQ", .counting),
        r("ar39", "Five Little Chicks", .arabic, "4iKQbtajlII", .animals),
        r("ar40", "Johny Johny Yes Papa", .arabic, "D1LDPmYoYm4", .manners),
        r("ar41", "Sleeping Bunnies", .arabic, "Vx3RFjQEqt0", .manners),
        r("ar42", "The ABC Song", .arabic, "75p-N9YKqNo", .alphabet),
        r("ar43", "Top Animal Learning Songs", .arabic, "ecVQvgnKDug", .animals),
        r("ar44", "Playground Sharing Song", .arabic, "2B2LVuIQ9JU", .manners),
        r("ar45", "Yes Yes Fruits Song", .arabic, "mbPNkDEN3Ps", .language)
    ]

    // MARK: Chinese — 字母、数字、动物、习惯

    static let chinese: [Rhyme] = [
        r("zh01", "两只老虎", .chinese, "RApHGXfBKO0", .animals),
        r("zh02", "小星星 + 经典儿歌合集", .chinese, "g-EWTkp_gIQ", .language),
        r("zh03", "两只老虎 + 更多儿歌", .chinese, "zPF7SYdca_w", .animals),
        r("zh04", "拔萝卜 + 经典儿歌", .chinese, "4lF-qPWIy8o", .language),
        r("zh05", "小毛驴 + 拔萝卜合集", .chinese, "nT5YkLSiyJ4", .animals),
        r("zh06", "我叫贝乐虎 + 更多", .chinese, "E5zToxE0h0g", .language),
        r("zh07", "超级汽车儿歌合集 (交通工具)", .chinese, "MEjd4u4Wfrk", .language),
        r("zh08", "Alphabet Song (ABC)", .chinese, "vD98OvvDNEs", .alphabet),
        r("zh09", "Phonics — A for Apple", .chinese, "hq3yfQnllfQ", .phonics),
        r("zh10", "Five Little Ducks (数数)", .chinese, "LrAtBtQnvCE", .counting),
        r("zh11", "Let's Count 5 Little Ducks", .chinese, "Z_sWD5iSE0w", .counting),
        r("zh12", "One Little Finger", .chinese, "eBVqcTEC3zQ", .body),
        r("zh13", "Hello Greeting Song", .chinese, "tVlcKp3bWH8", .manners),
        r("zh14", "Animals on the Farm", .chinese, "9FcCV286-gA", .animals),
        r("zh15", "Old MacDonald", .chinese, "lWhqORImND0", .animals),
        r("zh16", "Fruit Is Yummy", .chinese, "DDjOLRNby20", .language),
        r("zh17", "Yes Yes Vegetables", .chinese, "ohHYABXMqUQ", .language),
        r("zh18", "Twinkle Twinkle Little Star", .chinese, "yCjJyiqpAuU", .language),
        r("zh19", "Wheels on the Bus", .chinese, "9UasekNr8KI", .language),
        r("zh20", "Making Friends Song", .chinese, "3DcELlZBFbk", .manners),
        r("zh21", "Put On Your Shoes", .chinese, "Hf6oXuf7VbA", .manners),
        r("zh22", "ABC Colors & 123", .chinese, "TBRdYaYTs18", .alphabet),
        r("zh23", "ABC Phonics", .chinese, "UQthLMdsQak", .phonics),
        r("zh24", "Five Little Speckled Frogs", .chinese, "XaJSlYMFHyQ", .counting),
        r("zh25", "There's An Animal That I See", .chinese, "PmpJzVCIisc", .animals),
        r("zh26", "Rain Rain Go Away", .chinese, "j3kVbef2Zs4", .nature),
        r("zh27", "School Ready Backpack Song", .chinese, "3kEhqNW7-74", .manners),
        r("zh28", "Learn ABCs & Colors Mix", .chinese, "vkRDOcma9Qk", .alphabet),
        r("zh29", "Five Little Monkeys", .chinese, "VTmmoaO2M_U", .counting),
        r("zh30", "Baa Baa Black Sheep", .chinese, "YanYDTGkLH8", .animals),
        r("zh31", "Colour Sensory Twinkle", .chinese, "ZjtRA6brbPw", .colors),
        r("zh32", "ABC Song Collection", .chinese, "71h8MZshGSs", .alphabet),
        r("zh33", "Ten Little Buses", .chinese, "emC3qoSyfnQ", .counting),
        r("zh34", "Five Little Chicks", .chinese, "4iKQbtajlII", .animals),
        r("zh35", "Johny Johny Yes Papa", .chinese, "D1LDPmYoYm4", .manners),
        r("zh36", "Sleeping Bunnies", .chinese, "Vx3RFjQEqt0", .manners),
        r("zh37", "The ABC Song", .chinese, "75p-N9YKqNo", .alphabet),
        r("zh38", "Top Animal Learning Songs", .chinese, "ecVQvgnKDug", .animals),
        r("zh39", "Playground Sharing Song", .chinese, "2B2LVuIQ9JU", .manners),
        r("zh40", "Yes Yes Fruits Song", .chinese, "mbPNkDEN3Ps", .language),
        r("zh41", "Spring Songs for Kids", .chinese, "sMiz_oGY1kA", .nature),
        r("zh42", "Summer Nature Songs", .chinese, "7UoHjPAgmb8", .nature),
        r("zh43", "Six Little Ducks", .chinese, "rznk5RNGjbY", .counting),
        r("zh44", "London Bridge", .chinese, "Ser69-nsRNs", .language),
        r("zh45", "Hush Little Baby", .chinese, "S0cgaoDUggg", .language)
    ]
}
