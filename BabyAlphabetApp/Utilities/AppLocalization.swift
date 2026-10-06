//
//  AppLocalization.swift
//  BabyAlphabetApp
//
//  All user-facing labels and TTS phrase templates, keyed by the child's
//  selected learning language.
//

import Foundation

struct L10n {
    let language: AppLanguage

    init(_ language: AppLanguage) {
        self.language = language
    }

    // MARK: - Tabs

    var tabLearn: String { t("tab.learn") }
    var tabMath: String { t("tab.math") }
    var tabRhymes: String { t("tab.rhymes") }
    var tabRewards: String { t("tab.rewards") }
    var tabLeaderboard: String { t("tab.leaderboard") }

    // MARK: - Math

    var mathSubtitle: String { t("math.subtitle") }
    var mathBadgesLabel: String { t("math.badges") }
    var mathCheck: String { t("math.check") }
    var mathCorrect: String { t("math.correct") }
    var mathTryAgain: String { t("math.tryAgain") }
    var mathAllDone: String { t("math.allDone") }
    func mathOperationTitle(_ op: MathOperation) -> String {
        switch op {
        case .addition: return t("math.addition")
        case .subtraction: return t("math.subtraction")
        case .multiplication: return t("math.multiplication")
        case .division: return t("math.division")
        }
    }
    func mathQuestionOf(_ current: Int, total: Int) -> String {
        t("math.questionOf", "\(current)", "\(total)")
    }
    func mathBadgeProgress(_ current: Int, of goal: Int) -> String {
        t("math.badgeProgress", "\(current)", "\(goal)")
    }
    func mathBadgeName(_ badge: MathBadge) -> String {
        t("math.badgeName", mathOperationTitle(badge.operation), "\(badge.tier)")
    }

    // MARK: - Learn home

    var appTitle: String { t("app.title") }
    func hiName(_ name: String) -> String { t("home.hi", name) }
    var change: String { t("home.change") }
    var alphabets: String { t("home.alphabets") }
    var counting: String { t("home.counting") }
    var earned: String { t("home.earned") }

    // MARK: - Onboarding

    var welcome: String { t("onboard.welcome") }
    var welcomeBody: String { t("onboard.welcomeBody") }
    var changeLanguage: String { t("onboard.changeLanguage") }
    var changeLanguageBody: String { t("onboard.changeLanguageBody") }
    var chooseLanguage: String { t("onboard.chooseLanguage") }
    func lettersAndCounting(_ letterCount: Int) -> String {
        t("onboard.lettersCount", "\(letterCount)")
    }

    // MARK: - Stages

    var stageBeAHero: String { t("stage.beAHero") }
    func stageLetters(_ stage: Int, start: Int, end: Int) -> String {
        t("stage.letters", "\(stage)", "\(start)", "\(end)")
    }
    func stageCountTo10() -> String { t("stage.countTo10") }
    func stageNumbers(_ stage: Int, start: Int, end: Int) -> String {
        t("stage.numbers", "\(stage)", "\(start)", "\(end)")
    }
    func letterOf(_ current: Int, total: Int) -> String {
        t("stage.letterOf", "\(current)", "\(total)")
    }
    func numberOf(_ current: Int, total: Int) -> String {
        t("stage.numberOf", "\(current)", "\(total)")
    }
    var stageComplete: String { t("stage.complete") }
    var close: String { t("common.close") }
    var done: String { t("common.done") }
    func coinsBadge(_ coins: Int, emoji: String, name: String) -> String {
        t("stage.coinsBadge", "\(coins)", emoji, name)
    }

    // MARK: - Drawing canvas

    var clear: String { t("draw.clear") }
    var hearIt: String { t("draw.hearIt") }
    var showMe: String { t("draw.showMe") }
    var paceNormal: String { t("pace.normal") }
    var paceSlow: String { t("pace.slow") }
    var paceSlower: String { t("pace.slower") }
    var traced: String { t("draw.traced") }
    var watchCarefully: String { t("draw.watchCarefully") }
    var nowYouTry: String { t("draw.nowYouTry") }
    var followGlow: String { t("draw.followGlow") }
    var letterNoun: String { t("draw.letter") }
    var numberNoun: String { t("draw.number") }
    func stayOnOutline(_ noun: String) -> String { t("draw.stayOutline", noun) }
    func traceCarefully(_ noun: String) -> String { t("draw.traceCarefully", noun) }
    func oopsDraw(_ noun: String) -> String { t("draw.oops", noun) }
    func stayOnTryAgain(_ noun: String) -> String { t("draw.stayTry", noun) }
    func keepGoing(_ noun: String) -> String { t("draw.keepGoing", noun) }
    var almost: String { t("draw.almost") }
    func letterIsFor(_ letter: String, word: String) -> String {
        t("draw.isFor", letter, word)
    }
    func numberLabel(_ n: Int, spoken: String) -> String {
        t("draw.numberLabel", "\(n)", spoken)
    }
    func hearLetterPhrase(_ letter: String, word: String) -> String {
        t("speech.letterPhrase", letter, word)
    }
    func hearNumberPhrase(_ spoken: String, n: Int) -> String {
        t("speech.numberPhrase", spoken, "\(n)")
    }
    func soundLetter(_ letter: String) -> String {
        t("speech.letterSound", letter)
    }
    func soundNumber(_ spoken: String) -> String {
        t("speech.numberSound", spoken)
    }

    // MARK: - Celebration

    var greatJob: String { t("celeb.greatJob") }
    func earnedBadge(_ name: String) -> String { t("celeb.earnedBadge", name) }
    func plusCoins(_ n: Int) -> String { t("celeb.plusCoins", "\(n)") }
    var keepGoingCta: String { t("celeb.keepGoing") }
    var youFoundIt: String { t("celeb.youFoundIt") }

    // MARK: - Rhymes

    var rhymeTime: String { t("rhyme.title") }
    func moreRhymesSoon(_ language: String) -> String { t("rhyme.soon", language) }
    func educationalSongs(_ count: Int) -> String { t("rhyme.count", "\(count)") }
    var rhymeTopics: String { t("rhyme.topics") }
    func teaches(_ topic: String) -> String { t("rhyme.teaches", topic) }
    var audioOnlyMode: String { t("rhyme.audioOnlyMode") }
    var audioOnly: String { t("rhyme.audioOnly") }
    func songOf(_ current: Int, total: Int) -> String {
        t("rhyme.songOf", "\(current)", "\(total)")
    }
    var autoPlayNext: String { t("rhyme.autoPlay") }
    func nextUp(_ title: String) -> String { t("rhyme.nextUp", title) }
    var lastSong: String { t("rhyme.lastSong") }
    var noRhymes: String { t("rhyme.none") }

    // MARK: - Rewards / leaderboard

    var myRewards: String { t("rewards.title") }
    func coinsCount(_ n: Int) -> String { t("rewards.coins", "\(n)") }
    var earnCoinsHint: String { t("rewards.hint") }
    var noBadgesYet: String { t("rewards.empty") }
    var leaderboard: String { t("lead.title") }
    var share: String { t("lead.share") }
    var alphabetChampions: String { t("lead.champions") }
    func badgesAndLetters(_ badges: Int, letters: Int) -> String {
        t("lead.stats", "\(badges)", "\(letters)")
    }

    // MARK: - Topics

    func topic(_ topic: EducationalTopic) -> String {
        switch topic {
        case .alphabet: return t("topic.alphabet")
        case .phonics: return t("topic.phonics")
        case .counting: return t("topic.counting")
        case .colors: return t("topic.colors")
        case .animals: return t("topic.animals")
        case .body: return t("topic.body")
        case .manners: return t("topic.manners")
        case .language: return t("topic.language")
        case .nature: return t("topic.nature")
        case .shapes: return t("topic.shapes")
        }
    }

    // MARK: - Badges

    func badgeName(_ badge: Badge) -> String {
        let base = badge.id
            .replacingOccurrences(of: #"^count-"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"-stage-\d+$"#, with: "", options: .regularExpression)
        switch base {
        case "unicorn": return t("badge.unicorn")
        case "star": return t("badge.star")
        case "rocket": return t("badge.rocket")
        case "rainbow": return t("badge.rainbow")
        case "crown": return t("badge.crown")
        case "trophy": return t("badge.trophy")
        default:
            if badge.id.hasPrefix("math-"),
               let math = MathBadge.all.first(where: { $0.id == badge.id }) {
                return mathBadgeName(math)
            }
            return badge.name
        }
    }

    // MARK: - Engine

    private func t(_ key: String, _ args: String...) -> String {
        var result = Self.table[key]?[language]
            ?? Self.table[key]?[.english]
            ?? key
        for (index, arg) in args.enumerated() {
            result = result.replacingOccurrences(of: "%\(index + 1)$@", with: arg)
        }
        return result
    }

    private static let table: [String: [AppLanguage: String]] = buildTable()

    private static func buildTable() -> [String: [AppLanguage: String]] {
        var t: [String: [AppLanguage: String]] = [:]

        func put(_ key: String,
                 en: String, es: String, de: String, pt: String,
                 pl: String, fi: String, cs: String, ar: String, zh: String) {
            t[key] = [
                .english: en, .spanish: es, .german: de, .portuguese: pt,
                .polish: pl, .finnish: fi, .czech: cs, .arabic: ar, .chinese: zh
            ]
        }

        // Tabs
        put("tab.learn",
            en: "Learn", es: "Aprender", de: "Lernen", pt: "Aprender",
            pl: "Ucz się", fi: "Opi", cs: "Učit se", ar: "تعلّم", zh: "学习")
        put("tab.math",
            en: "Math", es: "Mate", de: "Mathe", pt: "Matemática",
            pl: "Matematyka", fi: "Matikka", cs: "Matika", ar: "رياضيات", zh: "数学")
        put("tab.rhymes",
            en: "Rhymes", es: "Rimas", de: "Reime", pt: "Rimas",
            pl: "Rymowanki", fi: "Lorut", cs: "Říkanky", ar: "أناشيد", zh: "儿歌")

        // Math
        put("math.subtitle",
            en: "Solve equations and earn a math badge every 10 correct answers!",
            es: "¡Resuelve cuentas y gana una insignia cada 10 aciertos!",
            de: "Löse Aufgaben und verdiene alle 10 richtigen Antworten ein Mathe-Abzeichen!",
            pt: "Resolve contas e ganha um distintivo a cada 10 acertos!",
            pl: "Rozwiązuj działania i zdobywaj odznakę co 10 poprawnych odpowiedzi!",
            fi: "Ratkaise laskuja ja ansaitse merkki joka 10. oikeasta vastauksesta!",
            cs: "Počítej příklady a získej odznak za každých 10 správných odpovědí!",
            ar: "حل المسائل واحصل على شارة كل 10 إجابات صحيحة!",
            zh: "解题练习，每答对 10 题获得一枚数学徽章！")
        put("math.addition",
            en: "Addition", es: "Suma", de: "Addition", pt: "Adição",
            pl: "Dodawanie", fi: "Yhteenlasku", cs: "Sčítání", ar: "جمع", zh: "加法")
        put("math.subtraction",
            en: "Subtraction", es: "Resta", de: "Subtraktion", pt: "Subtração",
            pl: "Odejmowanie", fi: "Vähennyslasku", cs: "Odčítání", ar: "طرح", zh: "减法")
        put("math.multiplication",
            en: "Multiplication", es: "Multiplicación", de: "Multiplikation", pt: "Multiplicação",
            pl: "Mnożenie", fi: "Kertolasku", cs: "Násobení", ar: "ضرب", zh: "乘法")
        put("math.division",
            en: "Division", es: "División", de: "Division", pt: "Divisão",
            pl: "Dzielenie", fi: "Jakolasku", cs: "Dělení", ar: "قسمة", zh: "除法")
        put("math.badges",
            en: "badges", es: "insignias", de: "Abzeichen", pt: "distintivos",
            pl: "odznaki", fi: "merkkiä", cs: "odznaky", ar: "شارات", zh: "徽章")
        put("math.check",
            en: "Check", es: "Comprobar", de: "Prüfen", pt: "Verificar",
            pl: "Sprawdź", fi: "Tarkista", cs: "Zkontrolovat", ar: "تحقق", zh: "检查")
        put("math.correct",
            en: "Correct! ✨", es: "¡Correcto! ✨", de: "Richtig! ✨", pt: "Correto! ✨",
            pl: "Dobrze! ✨", fi: "Oikein! ✨", cs: "Správně! ✨", ar: "صحيح! ✨", zh: "正确！✨")
        put("math.tryAgain",
            en: "Try again", es: "Inténtalo otra vez", de: "Nochmals versuchen", pt: "Tenta outra vez",
            pl: "Spróbuj ponownie", fi: "Yritä uudelleen", cs: "Zkus znovu", ar: "حاول مرة أخرى", zh: "再试一次")
        put("math.allDone",
            en: "You finished all questions!", es: "¡Terminaste todas las preguntas!", de: "Alle Aufgaben geschafft!", pt: "Terminaste todas as perguntas!",
            pl: "Ukończyłeś wszystkie pytania!", fi: "Sait kaikki kysymykset valmiiksi!", cs: "Dokončil jsi všechny otázky!", ar: "أنهيت كل الأسئلة!", zh: "你完成了全部题目！")
        put("math.questionOf",
            en: "Question %1$@ of %2$@", es: "Pregunta %1$@ de %2$@", de: "Aufgabe %1$@ von %2$@", pt: "Pergunta %1$@ de %2$@",
            pl: "Pytanie %1$@ z %2$@", fi: "Kysymys %1$@ / %2$@", cs: "Otázka %1$@ z %2$@", ar: "السؤال %1$@ من %2$@", zh: "第 %1$@ / %2$@ 题")
        put("math.badgeProgress",
            en: "%1$@ / %2$@ to next badge", es: "%1$@ / %2$@ para la siguiente insignia", de: "%1$@ / %2$@ bis zum nächsten Abzeichen", pt: "%1$@ / %2$@ para o próximo distintivo",
            pl: "%1$@ / %2$@ do kolejnej odznaki", fi: "%1$@ / %2$@ seuraavaan merkkiin", cs: "%1$@ / %2$@ do dalšího odznaku", ar: "%1$@ / %2$@ للشارة التالية", zh: "距下一枚徽章 %1$@ / %2$@")
        put("math.badgeName",
            en: "%1$@ Star %2$@", es: "%1$@ Estrella %2$@", de: "%1$@ Stern %2$@", pt: "%1$@ Estrela %2$@",
            pl: "%1$@ Gwiazda %2$@", fi: "%1$@ Tähti %2$@", cs: "%1$@ Hvězda %2$@", ar: "%1$@ نجمة %2$@", zh: "%1$@之星 %2$@")
        put("tab.rewards",
            en: "Rewards", es: "Premios", de: "Belohnungen", pt: "Prémios",
            pl: "Nagrody", fi: "Palkinnot", cs: "Odměny", ar: "مكافآت", zh: "奖励")
        put("tab.leaderboard",
            en: "Leaderboard", es: "Clasificación", de: "Rangliste", pt: "Ranking",
            pl: "Ranking", fi: "Tulostaulukko", cs: "Žebříček", ar: "المتصدرون", zh: "排行榜")

        // Home
        put("app.title",
            en: "Baby Alphabet", es: "Baby Alphabet", de: "Baby Alphabet", pt: "Baby Alphabet",
            pl: "Baby Alphabet", fi: "Baby Alphabet", cs: "Baby Alphabet", ar: "Baby Alphabet", zh: "Baby Alphabet")
        put("home.hi",
            en: "Hi, %1$@! 👋", es: "¡Hola, %1$@! 👋", de: "Hallo, %1$@! 👋", pt: "Olá, %1$@! 👋",
            pl: "Cześć, %1$@! 👋", fi: "Hei, %1$@! 👋", cs: "Ahoj, %1$@! 👋", ar: "مرحبًا، %1$@! 👋", zh: "你好，%1$@！👋")
        put("home.change",
            en: "Change", es: "Cambiar", de: "Ändern", pt: "Mudar",
            pl: "Zmień", fi: "Vaihda", cs: "Změnit", ar: "تغيير", zh: "更改")
        put("home.alphabets",
            en: "Alphabets", es: "Alfabeto", de: "Alphabet", pt: "Alfabeto",
            pl: "Alfabet", fi: "Aakkoset", cs: "Abeceda", ar: "الأبجدية", zh: "字母")
        put("home.counting",
            en: "Counting", es: "Contar", de: "Zählen", pt: "Contar",
            pl: "Liczenie", fi: "Laskeminen", cs: "Počítání", ar: "العد", zh: "数数")
        put("home.earned",
            en: "Earned", es: "Ganado", de: "Erhalten", pt: "Conquistado",
            pl: "Zdobyte", fi: "Saatu", cs: "Získáno", ar: "مكتسب", zh: "已获得")

        // Onboarding
        put("onboard.welcome",
            en: "Welcome! 👋", es: "¡Bienvenido! 👋", de: "Willkommen! 👋", pt: "Bem-vindo! 👋",
            pl: "Witaj! 👋", fi: "Tervetuloa! 👋", cs: "Vítej! 👋", ar: "مرحبًا! 👋", zh: "欢迎！👋")
        put("onboard.welcomeBody",
            en: "Pick the language your child will learn. You only need to do this once.",
            es: "Elige el idioma que aprenderá tu hijo. Solo hace falta una vez.",
            de: "Wähle die Sprache, die dein Kind lernen soll. Das brauchst du nur einmal.",
            pt: "Escolhe a língua que a criança vai aprender. Só precisas de fazer isto uma vez.",
            pl: "Wybierz język, którego będzie się uczyć dziecko. Wystarczy zrobić to raz.",
            fi: "Valitse kieli, jota lapsi oppii. Tämä tehdään vain kerran.",
            cs: "Vyber jazyk, který se dítě bude učit. Stačí to udělat jednou.",
            ar: "اختر اللغة التي سيتعلمها طفلك. تحتاج إلى ذلك مرة واحدة فقط.",
            zh: "选择孩子要学习的语言。只需设置一次。")
        put("onboard.changeLanguage",
            en: "Change language", es: "Cambiar idioma", de: "Sprache ändern", pt: "Mudar idioma",
            pl: "Zmień język", fi: "Vaihda kieli", cs: "Změnit jazyk", ar: "تغيير اللغة", zh: "更改语言")
        put("onboard.changeLanguageBody",
            en: "Pick a new language for alphabets and counting.",
            es: "Elige un nuevo idioma para el alfabeto y contar.",
            de: "Wähle eine neue Sprache für Alphabet und Zählen.",
            pt: "Escolhe um novo idioma para o alfabeto e a contagem.",
            pl: "Wybierz nowy język dla alfabetu i liczenia.",
            fi: "Valitse uusi kieli aakkosille ja laskemiselle.",
            cs: "Vyber nový jazyk pro abecedu a počítání.",
            ar: "اختر لغة جديدة للأبجدية والعد.",
            zh: "为字母和数数选择新语言。")
        put("onboard.chooseLanguage",
            en: "Choose Language", es: "Elegir idioma", de: "Sprache wählen", pt: "Escolher idioma",
            pl: "Wybierz język", fi: "Valitse kieli", cs: "Vyber jazyk", ar: "اختر اللغة", zh: "选择语言")
        put("onboard.lettersCount",
            en: "%1$@ letters · 1–100", es: "%1$@ letras · 1–100", de: "%1$@ Buchstaben · 1–100", pt: "%1$@ letras · 1–100",
            pl: "%1$@ liter · 1–100", fi: "%1$@ kirjainta · 1–100", cs: "%1$@ písmen · 1–100", ar: "%1$@ حروف · 1–100", zh: "%1$@ 个字母 · 1–100")

        // Stages
        put("stage.beAHero",
            en: "Stage 1 · Be a Hero!", es: "Nivel 1 · ¡Sé un héroe!", de: "Stufe 1 · Sei ein Held!", pt: "Fase 1 · Sê um herói!",
            pl: "Etap 1 · Bądź bohaterem!", fi: "Taso 1 · Ole sankari!", cs: "Úroveň 1 · Buď hrdina!", ar: "المرحلة 1 · كن بطلًا!", zh: "第 1 关 · 做英雄！")
        put("stage.letters",
            en: "Stage %1$@ · Letters %2$@–%3$@", es: "Nivel %1$@ · Letras %2$@–%3$@", de: "Stufe %1$@ · Buchstaben %2$@–%3$@", pt: "Fase %1$@ · Letras %2$@–%3$@",
            pl: "Etap %1$@ · Litery %2$@–%3$@", fi: "Taso %1$@ · Kirjaimet %2$@–%3$@", cs: "Úroveň %1$@ · Písmena %2$@–%3$@", ar: "المرحلة %1$@ · الحروف %2$@–%3$@", zh: "第 %1$@ 关 · 字母 %2$@–%3$@")
        put("stage.countTo10",
            en: "Stage 1 · Count to 10", es: "Nivel 1 · Contar hasta 10", de: "Stufe 1 · Bis 10 zählen", pt: "Fase 1 · Contar até 10",
            pl: "Etap 1 · Licz do 10", fi: "Taso 1 · Laske kymmeneen", cs: "Úroveň 1 · Počítej do 10", ar: "المرحلة 1 · عدّ إلى 10", zh: "第 1 关 · 数到 10")
        put("stage.numbers",
            en: "Stage %1$@ · %2$@–%3$@", es: "Nivel %1$@ · %2$@–%3$@", de: "Stufe %1$@ · %2$@–%3$@", pt: "Fase %1$@ · %2$@–%3$@",
            pl: "Etap %1$@ · %2$@–%3$@", fi: "Taso %1$@ · %2$@–%3$@", cs: "Úroveň %1$@ · %2$@–%3$@", ar: "المرحلة %1$@ · %2$@–%3$@", zh: "第 %1$@ 关 · %2$@–%3$@")
        put("stage.letterOf",
            en: "Letter %1$@ of %2$@", es: "Letra %1$@ de %2$@", de: "Buchstabe %1$@ von %2$@", pt: "Letra %1$@ de %2$@",
            pl: "Litera %1$@ z %2$@", fi: "Kirjain %1$@ / %2$@", cs: "Písmeno %1$@ z %2$@", ar: "الحرف %1$@ من %2$@", zh: "字母 %1$@ / %2$@")
        put("stage.numberOf",
            en: "Number %1$@ of %2$@", es: "Número %1$@ de %2$@", de: "Zahl %1$@ von %2$@", pt: "Número %1$@ de %2$@",
            pl: "Liczba %1$@ z %2$@", fi: "Numero %1$@ / %2$@", cs: "Číslo %1$@ z %2$@", ar: "الرقم %1$@ من %2$@", zh: "数字 %1$@ / %2$@")
        put("stage.complete",
            en: "Stage complete!", es: "¡Nivel completado!", de: "Stufe geschafft!", pt: "Fase concluída!",
            pl: "Etap ukończony!", fi: "Taso valmis!", cs: "Úroveň hotová!", ar: "اكتملت المرحلة!", zh: "关卡完成！")
        put("stage.coinsBadge",
            en: "+%1$@ coins · %2$@ %3$@", es: "+%1$@ monedas · %2$@ %3$@", de: "+%1$@ Münzen · %2$@ %3$@", pt: "+%1$@ moedas · %2$@ %3$@",
            pl: "+%1$@ monety · %2$@ %3$@", fi: "+%1$@ kolikkoa · %2$@ %3$@", cs: "+%1$@ mincí · %2$@ %3$@", ar: "+%1$@ عملات · %2$@ %3$@", zh: "+%1$@ 金币 · %2$@ %3$@")
        put("common.close",
            en: "Close", es: "Cerrar", de: "Schließen", pt: "Fechar",
            pl: "Zamknij", fi: "Sulje", cs: "Zavřít", ar: "إغلاق", zh: "关闭")
        put("common.done",
            en: "Done", es: "Listo", de: "Fertig", pt: "Concluído",
            pl: "Gotowe", fi: "Valmis", cs: "Hotovo", ar: "تم", zh: "完成")

        // Drawing
        put("draw.clear",
            en: "Clear", es: "Borrar", de: "Löschen", pt: "Limpar",
            pl: "Wyczyść", fi: "Tyhjennä", cs: "Smazat", ar: "مسح", zh: "清除")
        put("draw.hearIt",
            en: "Hear it", es: "Escuchar", de: "Anhören", pt: "Ouvir",
            pl: "Posłuchaj", fi: "Kuuntele", cs: "Poslechnout", ar: "استمع", zh: "听听")
        put("draw.showMe",
            en: "Show me", es: "Muéstrame", de: "Zeig mir", pt: "Mostra-me",
            pl: "Pokaż", fi: "Näytä", cs: "Ukaž", ar: "أرني", zh: "演示")
        put("pace.normal",
            en: "Normal", es: "Normal", de: "Normal", pt: "Normal",
            pl: "Normalne", fi: "Normaali", cs: "Normální", ar: "عادي", zh: "正常")
        put("pace.slow",
            en: "Slow", es: "Lento", de: "Langsam", pt: "Lento",
            pl: "Wolno", fi: "Hidas", cs: "Pomalu", ar: "بطيء", zh: "慢")
        put("pace.slower",
            en: "Slower", es: "Más lento", de: "Langsamer", pt: "Mais lento",
            pl: "Wolniej", fi: "Hitaampi", cs: "Pomaleji", ar: "أبطأ", zh: "更慢")
        put("draw.traced",
            en: "Traced! ✨", es: "¡Trazado! ✨", de: "Nachgezogen! ✨", pt: "Traçado! ✨",
            pl: "Obrysowane! ✨", fi: "Jäljitetty! ✨", cs: "Obkresleno! ✨", ar: "تم التتبع! ✨", zh: "描好了！✨")
        put("draw.watchCarefully",
            en: "Watch carefully…", es: "Mira con atención…", de: "Schau genau hin…", pt: "Olha com atenção…",
            pl: "Patrz uważnie…", fi: "Katso tarkasti…", cs: "Dívej se pozorně…", ar: "شاهد بانتباه…", zh: "仔细看…")
        put("draw.nowYouTry",
            en: "Now you try!", es: "¡Ahora tú!", de: "Jetzt du!", pt: "Agora tu!",
            pl: "Teraz ty!", fi: "Nyt sinä!", cs: "Teď ty!", ar: "الآن دورك!", zh: "轮到你了！")
        put("draw.followGlow",
            en: "Follow the glowing line", es: "Sigue la línea brillante", de: "Folge der leuchtenden Linie", pt: "Segue a linha brilhante",
            pl: "Podążaj za świecącą linią", fi: "Seuraa hehkuvaa viivaa", cs: "Sleduj zářící čáru", ar: "اتبع الخط المتوهج", zh: "跟着发光的线画")
        put("draw.letter",
            en: "letter", es: "letra", de: "Buchstaben", pt: "letra",
            pl: "litery", fi: "kirjaimen", cs: "písmeno", ar: "الحرف", zh: "字母")
        put("draw.number",
            en: "number", es: "número", de: "Zahl", pt: "número",
            pl: "liczby", fi: "numeron", cs: "číslo", ar: "الرقم", zh: "数字")
        put("draw.stayOutline",
            en: "Stay on the purple %1$@ outline", es: "Quédate en el contorno morado de la %1$@", de: "Bleib auf dem lila %1$@-Umriss", pt: "Fica no contorno roxo da %1$@",
            pl: "Trzymaj się fioletowego konturu %1$@", fi: "Pysy violetilla %1$@ ääriviivalla", cs: "Zůstaň na fialovém obrysu %1$@", ar: "ابقَ على المخطط البنفسجي لـ %1$@", zh: "沿着紫色%1$@轮廓画")
        put("draw.traceCarefully",
            en: "Trace carefully over the purple %1$@", es: "Traza con cuidado sobre la %1$@ morada", de: "Zeichne vorsichtig den lila %1$@ nach", pt: "Traça com cuidado sobre a %1$@ roxa",
            pl: "Ostrożnie obrysuj fioletową %1$@", fi: "Jäljitä varovasti violetti %1$@", cs: "Opatrně obkresli fialové %1$@", ar: "تتبّع %1$@ البنفسجي بعناية", zh: "仔细描紫色的%1$@")
        put("draw.oops",
            en: "Oops! Draw on the purple %1$@", es: "¡Ups! Dibuja sobre la %1$@ morada", de: "Ups! Zeichne auf dem lila %1$@", pt: "Ups! Desenha na %1$@ roxa",
            pl: "Ups! Rysuj na fioletowej %1$@", fi: "Hups! Piirrä violetille %1$@lle", cs: "Ups! Kresli na fialové %1$@", ar: "أوبس! ارسم على %1$@ البنفسجي", zh: "哎呀！画在紫色%1$@上")
        put("draw.stayTry",
            en: "Stay on the %1$@ — try again", es: "Quédate en la %1$@ — inténtalo otra vez", de: "Bleib auf dem %1$@ — nochmal versuchen", pt: "Fica na %1$@ — tenta outra vez",
            pl: "Trzymaj się %1$@ — spróbuj ponownie", fi: "Pysy %1$@lla — yritä uudelleen", cs: "Zůstaň na %1$@ — zkus znovu", ar: "ابقَ على %1$@ — حاول مرة أخرى", zh: "留在%1$@上 — 再试一次")
        put("draw.keepGoing",
            en: "Keep going — trace more of the %1$@", es: "Sigue — traza más de la %1$@", de: "Weiter — zeichne mehr vom %1$@", pt: "Continua — traça mais da %1$@",
            pl: "Dalej — obrysuj więcej %1$@", fi: "Jatka — jäljitä enemmän %1$@a", cs: "Pokračuj — obkresli víc %1$@", ar: "تابع — تتبّع المزيد من %1$@", zh: "继续 — 多描一些%1$@")
        put("draw.almost",
            en: "Almost! Follow the full outline", es: "¡Casi! Sigue todo el contorno", de: "Fast! Folge dem ganzen Umriss", pt: "Quase! Segue o contorno todo",
            pl: "Prawie! Podążaj za całym konturem", fi: "Melkein! Seuraa koko ääriviivaa", cs: "Skoro! Sleduj celý obrys", ar: "تقريبًا! اتبع المخطط كاملًا", zh: "快了！跟着完整轮廓画")
        put("draw.isFor",
            en: "%1$@ is for %2$@", es: "%1$@ de %2$@", de: "%1$@ wie %2$@", pt: "%1$@ de %2$@",
            pl: "%1$@ jak %2$@", fi: "%1$@ niin kuin %2$@", cs: "%1$@ jako %2$@", ar: "%1$@ مثل %2$@", zh: "%1$@ 是 %2$@")
        put("draw.numberLabel",
            en: "Number %1$@ · %2$@", es: "Número %1$@ · %2$@", de: "Zahl %1$@ · %2$@", pt: "Número %1$@ · %2$@",
            pl: "Liczba %1$@ · %2$@", fi: "Numero %1$@ · %2$@", cs: "Číslo %1$@ · %2$@", ar: "الرقم %1$@ · %2$@", zh: "数字 %1$@ · %2$@")
        put("speech.letterPhrase",
            en: "%1$@. %1$@ is for %2$@.", es: "%1$@. %1$@ de %2$@.", de: "%1$@. %1$@ wie %2$@.", pt: "%1$@. %1$@ de %2$@.",
            pl: "%1$@. %1$@ jak %2$@.", fi: "%1$@. %1$@ niin kuin %2$@.", cs: "%1$@. %1$@ jako %2$@.", ar: "%1$@. %1$@ مثل %2$@.", zh: "%1$@。%1$@ 是 %2$@。")
        put("speech.numberPhrase",
            en: "%1$@. %2$@.", es: "%1$@. %2$@.", de: "%1$@. %2$@.", pt: "%1$@. %2$@.",
            pl: "%1$@. %2$@.", fi: "%1$@. %2$@.", cs: "%1$@. %2$@.", ar: "%1$@. %2$@.", zh: "%1$@。%2$@。")
        put("speech.letterSound",
            en: "%1$@. %1$@", es: "%1$@. %1$@", de: "%1$@. %1$@", pt: "%1$@. %1$@",
            pl: "%1$@. %1$@", fi: "%1$@. %1$@", cs: "%1$@. %1$@", ar: "%1$@. %1$@", zh: "%1$@。%1$@")
        put("speech.numberSound",
            en: "%1$@. %1$@", es: "%1$@. %1$@", de: "%1$@. %1$@", pt: "%1$@. %1$@",
            pl: "%1$@. %1$@", fi: "%1$@. %1$@", cs: "%1$@. %1$@", ar: "%1$@. %1$@", zh: "%1$@。%1$@")

        // Celebration
        put("celeb.greatJob",
            en: "Great Job!", es: "¡Bien hecho!", de: "Super!", pt: "Muito bem!",
            pl: "Świetna robota!", fi: "Hienoa!", cs: "Skvělá práce!", ar: "أحسنت!", zh: "太棒了！")
        put("celeb.earnedBadge",
            en: "You earned the %1$@ badge!", es: "¡Ganaste la insignia %1$@!", de: "Du hast das Abzeichen %1$@ verdient!", pt: "Ganhaste o distintivo %1$@!",
            pl: "Zdobyłeś odznakę %1$@!", fi: "Sait merkin %1$@!", cs: "Získal jsi odznak %1$@!", ar: "لقد حصلت على شارة %1$@!", zh: "你获得了%1$@徽章！")
        put("celeb.plusCoins",
            en: "+%1$@ coins", es: "+%1$@ monedas", de: "+%1$@ Münzen", pt: "+%1$@ moedas",
            pl: "+%1$@ monety", fi: "+%1$@ kolikkoa", cs: "+%1$@ mincí", ar: "+%1$@ عملات", zh: "+%1$@ 金币")
        put("celeb.keepGoing",
            en: "Yay! Keep Going", es: "¡Yay! Sigue", de: "Juhu! Weiter so", pt: "Yay! Continua",
            pl: "Juhu! Dalej", fi: "Jee! Jatka", cs: "Jupí! Pokračuj", ar: "ياي! تابع", zh: "耶！继续")
        put("celeb.youFoundIt",
            en: "You found it! ✨", es: "¡Lo encontraste! ✨", de: "Du hast es gefunden! ✨", pt: "Encontraste! ✨",
            pl: "Znalazłeś! ✨", fi: "Löysit sen! ✨", cs: "Našel jsi to! ✨", ar: "وجدتها! ✨", zh: "找到了！✨")

        // Rhymes
        put("rhyme.title",
            en: "Rhyme Time 🎵", es: "Hora de rimas 🎵", de: "Reime-Zeit 🎵", pt: "Hora das rimas 🎵",
            pl: "Czas na rymowanki 🎵", fi: "Loruaika 🎵", cs: "Čas říkanek 🎵", ar: "وقت الأناشيد 🎵", zh: "儿歌时间 🎵")
        put("rhyme.soon",
            en: "More rhymes coming soon for %1$@! 🎵", es: "¡Más rimas pronto para %1$@! 🎵", de: "Bald mehr Reime für %1$@! 🎵", pt: "Mais rimas em breve para %1$@! 🎵",
            pl: "Więcej rymowanek wkrótce dla %1$@! 🎵", fi: "Lisää loruja pian kielelle %1$@! 🎵", cs: "Brzy více říkanek pro %1$@! 🎵", ar: "المزيد من الأناشيد قريبًا لـ %1$@! 🎵", zh: "%1$@ 的更多儿歌即将推出！🎵")
        put("rhyme.count",
            en: "%1$@ educational songs", es: "%1$@ canciones educativas", de: "%1$@ Lernlieder", pt: "%1$@ canções educativas",
            pl: "%1$@ piosenek edukacyjnych", fi: "%1$@ opetuslaulua", cs: "%1$@ vzdělávacích písní", ar: "%1$@ أغنية تعليمية", zh: "%1$@ 首教育歌曲")
        put("rhyme.topics",
            en: "ABC · Counting · Animals", es: "ABC · Contar · Animales", de: "ABC · Zählen · Tiere", pt: "ABC · Contar · Animais",
            pl: "ABC · Liczenie · Zwierzęta", fi: "ABC · Lasku · Eläimet", cs: "ABC · Počítání · Zvířata", ar: "أبجد · العد · حيوانات", zh: "字母 · 数数 · 动物")
        put("rhyme.teaches",
            en: "Teaches %1$@", es: "Enseña %1$@", de: "Lehrt %1$@", pt: "Ensina %1$@",
            pl: "Uczy: %1$@", fi: "Opettaa: %1$@", cs: "Učí: %1$@", ar: "يعلّم %1$@", zh: "学习%1$@")
        put("rhyme.audioOnlyMode",
            en: "Audio-only mode", es: "Solo audio", de: "Nur Audio", pt: "Só áudio",
            pl: "Tylko dźwięk", fi: "Vain ääni", cs: "Jen zvuk", ar: "صوت فقط", zh: "仅音频")
        put("rhyme.audioOnly",
            en: "Audio Only", es: "Solo audio", de: "Nur Audio", pt: "Só áudio",
            pl: "Tylko dźwięk", fi: "Vain ääni", cs: "Jen zvuk", ar: "صوت فقط", zh: "仅音频")
        put("rhyme.songOf",
            en: "Song %1$@ of %2$@", es: "Canción %1$@ de %2$@", de: "Lied %1$@ von %2$@", pt: "Canção %1$@ de %2$@",
            pl: "Piosenka %1$@ z %2$@", fi: "Laulu %1$@ / %2$@", cs: "Píseň %1$@ z %2$@", ar: "الأغنية %1$@ من %2$@", zh: "歌曲 %1$@ / %2$@")
        put("rhyme.autoPlay",
            en: "Auto-play next rhyme", es: "Reproducir siguiente automáticamente", de: "Nächsten Reim automatisch abspielen", pt: "Reproduzir próxima automaticamente",
            pl: "Odtwórz następną automatycznie", fi: "Toista seuraava automaattisesti", cs: "Přehrát další automaticky", ar: "تشغيل التالي تلقائيًا", zh: "自动播放下一首")
        put("rhyme.nextUp",
            en: "Next up: %1$@", es: "Siguiente: %1$@", de: "Als Nächstes: %1$@", pt: "A seguir: %1$@",
            pl: "Następna: %1$@", fi: "Seuraava: %1$@", cs: "Další: %1$@", ar: "التالي: %1$@", zh: "下一首：%1$@")
        put("rhyme.lastSong",
            en: "Last song in this language list", es: "Última canción de este idioma", de: "Letztes Lied in dieser Sprache", pt: "Última canção desta língua",
            pl: "Ostatnia piosenka na tej liście", fi: "Viimeinen laulu tällä kielellä", cs: "Poslední píseň v tomto jazyce", ar: "آخر أغنية في هذه اللغة", zh: "该语言列表的最后一首")
        put("rhyme.none",
            en: "No rhymes", es: "Sin rimas", de: "Keine Reime", pt: "Sem rimas",
            pl: "Brak rymowanek", fi: "Ei loruja", cs: "Žádné říkanky", ar: "لا أناشيد", zh: "暂无儿歌")

        // Rewards / leaderboard
        put("rewards.title",
            en: "My Rewards", es: "Mis premios", de: "Meine Belohnungen", pt: "Os meus prémios",
            pl: "Moje nagrody", fi: "Palkintoni", cs: "Mé odměny", ar: "مكافآتي", zh: "我的奖励")
        put("rewards.coins",
            en: "%1$@ coins", es: "%1$@ monedas", de: "%1$@ Münzen", pt: "%1$@ moedas",
            pl: "%1$@ monety", fi: "%1$@ kolikkoa", cs: "%1$@ mincí", ar: "%1$@ عملات", zh: "%1$@ 金币")
        put("rewards.hint",
            en: "Earn 5 coins every time you unlock a badge!",
            es: "¡Gana 5 monedas cada vez que desbloquees una insignia!",
            de: "Verdiene 5 Münzen für jedes freigeschaltete Abzeichen!",
            pt: "Ganha 5 moedas cada vez que desbloqueares um distintivo!",
            pl: "Zdobywaj 5 monet za każdą odblokowaną odznakę!",
            fi: "Ansaitse 5 kolikkoa jokaisesta avatusta merkistä!",
            cs: "Získej 5 mincí za každý odemčený odznak!",
            ar: "اكسب 5 عملات في كل مرة تفتح فيها شارة!",
            zh: "每解锁一枚徽章可获得 5 金币！")
        put("rewards.empty",
            en: "No badges yet — start tracing letters to earn your first Unicorn badge!",
            es: "Aún no hay insignias — ¡empieza a trazar letras para ganar tu primer Unicornio!",
            de: "Noch keine Abzeichen — zeichne Buchstaben für dein erstes Einhorn!",
            pt: "Ainda sem distintivos — começa a traçar letras para o teu primeiro Unicórnio!",
            pl: "Brak odznak — zacznij obrysowywać litery, by zdobyć Jednorożca!",
            fi: "Ei vielä merkkejä — jäljitä kirjaimia saadaksesi yksisarvisen!",
            cs: "Zatím žádné odznaky — začni obkreslovat písmena pro jednorožce!",
            ar: "لا شارات بعد — ابدأ بتتبع الحروف لتحصل على شارة الحصان المجنح!",
            zh: "还没有徽章 — 开始描字母，赢取第一枚独角兽徽章！")
        put("lead.title",
            en: "Leaderboard", es: "Clasificación", de: "Rangliste", pt: "Ranking",
            pl: "Ranking", fi: "Tulostaulukko", cs: "Žebříček", ar: "المتصدرون", zh: "排行榜")
        put("lead.share",
            en: "Share", es: "Compartir", de: "Teilen", pt: "Partilhar",
            pl: "Udostępnij", fi: "Jaa", cs: "Sdílet", ar: "مشاركة", zh: "分享")
        put("lead.champions",
            en: "🏆 Alphabet Champions", es: "🏆 Campeones del alfabeto", de: "🏆 Alphabet-Champions", pt: "🏆 Campeões do alfabeto",
            pl: "🏆 Mistrzowie alfabetu", fi: "🏆 Aakkosten mestarit", cs: "🏆 Šampioni abecedy", ar: "🏆 أبطال الأبجدية", zh: "🏆 字母冠军")
        put("lead.stats",
            en: "%1$@ badges · %2$@ letters traced", es: "%1$@ insignias · %2$@ letras trazadas", de: "%1$@ Abzeichen · %2$@ Buchstaben", pt: "%1$@ distintivos · %2$@ letras",
            pl: "%1$@ odznaki · %2$@ litery", fi: "%1$@ merkkiä · %2$@ kirjainta", cs: "%1$@ odznaky · %2$@ písmen", ar: "%1$@ شارات · %2$@ حروف", zh: "%1$@ 徽章 · %2$@ 个字母")

        // Topics
        put("topic.alphabet", en: "ABC", es: "ABC", de: "ABC", pt: "ABC", pl: "ABC", fi: "ABC", cs: "ABC", ar: "أبجد", zh: "字母")
        put("topic.phonics", en: "Phonics", es: "Fonética", de: "Lautlehre", pt: "Fonética", pl: "Fonetyka", fi: "Äänteet", cs: "Fonetika", ar: "صوتيات", zh: "拼音")
        put("topic.counting", en: "Counting", es: "Contar", de: "Zählen", pt: "Contar", pl: "Liczenie", fi: "Laskeminen", cs: "Počítání", ar: "العد", zh: "数数")
        put("topic.colors", en: "Colors", es: "Colores", de: "Farben", pt: "Cores", pl: "Kolory", fi: "Värit", cs: "Barvy", ar: "ألوان", zh: "颜色")
        put("topic.animals", en: "Animals", es: "Animales", de: "Tiere", pt: "Animais", pl: "Zwierzęta", fi: "Eläimet", cs: "Zvířata", ar: "حيوانات", zh: "动物")
        put("topic.body", en: "Body", es: "Cuerpo", de: "Körper", pt: "Corpo", pl: "Ciało", fi: "Keho", cs: "Tělo", ar: "الجسم", zh: "身体")
        put("topic.manners", en: "Manners", es: "Modales", de: "Manieren", pt: "Maneiras", pl: "Manners", fi: "Tavat", cs: "Slušnost", ar: "آداب", zh: "礼貌")
        put("topic.language", en: "Words", es: "Palabras", de: "Wörter", pt: "Palavras", pl: "Słowa", fi: "Sanat", cs: "Slova", ar: "كلمات", zh: "词语")
        put("topic.nature", en: "Nature", es: "Naturaleza", de: "Natur", pt: "Natureza", pl: "Przyroda", fi: "Luonto", cs: "Příroda", ar: "طبيعة", zh: "自然")
        put("topic.shapes", en: "Shapes", es: "Formas", de: "Formen", pt: "Formas", pl: "Kształty", fi: "Muodot", cs: "Tvary", ar: "أشكال", zh: "形状")

        // Badges
        put("badge.unicorn",
            en: "Unicorn Hero", es: "Héroe Unicornio", de: "Einhorn-Held", pt: "Herói Unicórnio",
            pl: "Bohater Jednorożec", fi: "Yksisarvissankari", cs: "Jednorožčí hrdina", ar: "بطل الحصان المجنح", zh: "独角兽英雄")
        put("badge.star",
            en: "Star Learner", es: "Estrella Aprendiz", de: "Sternenlerner", pt: "Estrela Aprendiz",
            pl: "Gwiazda Nauki", fi: "Tähtioppilas", cs: "Hvězdný žák", ar: "متعلم نجمة", zh: "星星学员")
        put("badge.rocket",
            en: "Rocket Reader", es: "Lector Cohete", de: "Raketenleser", pt: "Leitor Foguete",
            pl: "Rakietowy Czytelnik", fi: "Rakettilukija", cs: "Raketový čtenář", ar: "قارئ صاروخ", zh: "火箭小读者")
        put("badge.rainbow",
            en: "Rainbow Writer", es: "Escritor Arcoíris", de: "Regenbogenschreiber", pt: "Escritor Arco-íris",
            pl: "Tęczowy Pisarz", fi: "Sateenkaarikirjoittaja", cs: "Duhový pisatel", ar: "كاتب قوس قزح", zh: "彩虹小作家")
        put("badge.crown",
            en: "Alphabet Crown", es: "Corona del Alfabeto", de: "Alphabet-Krone", pt: "Coroa do Alfabeto",
            pl: "Korona Alfabetu", fi: "Aakkoskruunu", cs: "Koruna abecedy", ar: "تاج الأبجدية", zh: "字母皇冠")
        put("badge.trophy",
            en: "Champion Trophy", es: "Trofeo Campeón", de: "Meisterpokal", pt: "Troféu Campeão",
            pl: "Puchar Mistrza", fi: "Mestaruuspokaali", cs: "Pohár šampiona", ar: "كأس البطل", zh: "冠军奖杯")

        return t
    }
}

extension Stage {
    func localizedTitle(for language: AppLanguage) -> String {
        let s = L10n(language)
        if id == 0 { return s.stageBeAHero }
        let start = letterRange.lowerBound + 1
        let end = letterRange.upperBound
        return s.stageLetters(id + 1, start: start, end: end)
    }
}

extension CountingStage {
    func localizedTitle(for language: AppLanguage) -> String {
        let s = L10n(language)
        if id == 0 { return s.stageCountTo10() }
        return s.stageNumbers(id + 1, start: numberRange.lowerBound, end: numberRange.upperBound)
    }
}
