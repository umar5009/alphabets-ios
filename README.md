# Baby Alphabet — SwiftUI iOS App

A finger-tracing alphabet app for toddlers, covering English, Spanish, German,
Portuguese, Polish, Finnish, Czech, Arabic and Chinese (Pinyin initials),
with stages, badges, coins, a leaderboard, and a nursery-rhymes video player.

This is a **complete, ready-to-open Xcode project** — `BabyAlphabetApp.xcodeproj`
is included with the target, build settings, asset catalog and all 18 Swift
files already wired into the build. No project setup needed.

## 1. Requirements

- A Mac with Xcode 15 or later
- iOS 17+ target (uses `NavigationStack`, `ScrollView` grids, `ImageRenderer`)
- No third-party dependencies — everything uses first-party Apple frameworks
  (SwiftUI, AVFoundation, WebKit, CoreText)

## 2. Open and run

1. Double-click `BabyAlphabetApp.xcodeproj` — it opens directly in Xcode.
2. In the scheme selector at the top, pick an iPhone simulator (or a
   connected device).
3. Press **⌘R** (Run).
4. First launch shows the Learn tab; tap a language card to open its stage
   map, tap Stage 1 to trace the first letter, and the whole reward loop
   (clap → sound → confetti → badge → coins) fires automatically.

If Xcode asks about code signing for a physical device, go to the project's
**Signing & Capabilities** tab and pick your personal Apple ID team — the
simulator needs no signing at all, so that's the fastest way to try it.

The project file was generated programmatically (this environment doesn't
have Xcode installed to build/run it directly), so give it a first build and
report back if Xcode flags anything — the most likely rough edge is a
build-setting tweak, not a structural problem, since every file reference
was verified to resolve to a real file before packaging.

### Project layout

```
BabyAlphabetApp.xcodeproj/     ← open this
BabyAlphabetApp/
  App/
    BabyAlphabetApp.swift
  Models/
    LanguageModels.swift
    ProgressModels.swift
    RhymeModels.swift
  ViewModels/
    ProgressStore.swift
  Views/
    RootTabView.swift
    LearnHomeView.swift
    StageMapView.swift
    StageLetterFlowView.swift
    DrawingCanvasView.swift
    ConfettiView.swift
    RewardsView.swift
    LeaderboardView.swift
    RhymesView.swift
    YouTubePlayerView.swift
  Utilities/
    SpeechManager.swift
    SoundManager.swift
    TracingGuide.swift
  Assets.xcassets/
  Preview Content/
```

## 3. Info.plist / capabilities

No extra permissions or Info.plist keys are required:

- Letter/alphabet sounds use on-device `AVSpeechSynthesizer` (no mic, no
  network, no permission prompt).
- Rhyme videos load `https://www.youtube-nocookie.com/embed/...` inside a
  `WKWebView`, which is plain HTTPS — no App Transport Security exceptions
  needed.
- Progress/coins/badges are saved locally via `UserDefaults`.

If you later add your own bundled audio files (see below), no extra
permissions are needed for those either.

## 4. Optional: add real clapping/chime sound files

`SoundManager.swift` falls back to built-in iOS system sounds (`clap`, `tock`,
`cha-ching` style tones) so the app works immediately with zero setup. For a
richer feel, add your own licensed audio files, named exactly:

- `clapping.mp3` (or `.caf`/`.wav`)
- `success_chime.mp3`
- `coin_reward.mp3`
- `badge_unlock.mp3`

In Xcode, right-click the `BabyAlphabetApp` group → **Add Files to
"BabyAlphabetApp"...**, select your audio files, and make sure "Copy items
if needed" and the app target's checkbox are both checked. `SoundManager`
will automatically prefer your files over the system-sound fallback.

## 5. Rhyme videos — verify before shipping

`Models/RhymeModels.swift` ships with real, currently-live public YouTube
video IDs (verified via web search) for each language, played through
YouTube's official embeddable iframe player — nothing is downloaded or
rehosted, which keeps this fully within YouTube's terms. YouTube's catalogue
changes over time (creators remove/re-upload videos), so before you release:

1. Open each ID as `https://youtu.be/{id}` and confirm it still plays and
   embedding isn't disabled by the uploader.
2. Swap in your own preferred/rights-cleared channel picks if you want a
   specific creator, or if you'd rather use your studio's own uploaded
   content.
3. For the **audio-only** toggle, the app currently keeps the YouTube
   player running invisibly (so sound continues) rather than switching to a
   separate audio file. If you'd prefer true audio-only playback with no
   video decoding at all, add your own `.mp3` per rhyme and reference it via
   the `audioFileName` field already defined on the `Rhyme` model — swap the
   player to `AVPlayer` when `audioFileName != nil`.

## 6. How the core features map to files

| Feature (from spec) | Implementation |
|---|---|
| Draw alphabets of their language | `Models/LanguageModels.swift` (9 languages), `Views/DrawingCanvasView.swift` |
| Show a letter, trace with finger | `Utilities/TracingGuide.swift` (CoreText glyph outline → sample points), `DrawingCanvasView` `DragGesture` |
| Light-colored guide + bold label | `DrawingCanvasView`: guide stroked at `Color.purple.opacity(0.22)` (light) with a bold outline pass, header letter shown at `.black` weight |
| Confetti + clapping at the end | `Views/ConfettiView.swift`, `Utilities/SoundManager.playClapping` |
| Stage 1 = hero intro, unlock Unicorn badge | `Models/ProgressModels.swift` → `Stage.stages(for:)` builds stage 0 as a single-letter "hero" stage; `Badge.unicorn` |
| Stage 2+ splits into 5-letter groups, more badges | Same `Stage.stages(for:)` function, chunks remaining letters by 5 |
| Alphabet sounds after clapping, per-language/country standard | `Utilities/SpeechManager.swift` — `AVSpeechSynthesizer` locale per language (e.g. `en-GB`, `ar-SA`, `zh-CN`); `DrawingCanvasView.complete()` plays clap → then speaks the sound |
| Leaderboard + shareable screenshot | `Views/LeaderboardView.swift` — `ImageRenderer` renders the board to a `UIImage`, shared via `UIActivityViewController` |
| Rhymes with real embedded video + audio option | `Views/YouTubePlayerView.swift`, `Views/RhymesView.swift` |
| 5 coins per badge reward | `Models/ProgressModels.swift` → every `Badge` has `coinReward = 5`; `RewardsView.swift` shows the wallet |

## 7. Known simplifications (intentional, for a first working build)

- **Chinese** has no alphabet — the app teaches the 23 Pinyin initials
  (b, p, m, f, d, t, n, l...), which is the standard first step in Mandarin
  literacy curricula before full characters.
- **Tracing accuracy** is a coverage heuristic (does the finger path pass
  near enough points along the letter's outline), tuned generously
  (55% coverage, 34pt tolerance) for small thumbs — tune
  `completionThreshold` / `tolerance` in `DrawingCanvasView.swift` to taste.
- **Leaderboard** currently mixes the real child profile with a few
  friendly mock rivals so it never looks empty on a fresh install. Swap
  `ProgressStore.leaderboardEntries()` for a real backend (CloudKit,
  GameKit, or your own API) when you're ready for multi-device/social play.
- **Coins/badges** persist locally per device via `UserDefaults`. For
  family iCloud sync across devices, migrate `ChildProfile` storage to
  `NSUbiquitousKeyValueStore` or CloudKit.
