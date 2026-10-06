//
//  YouTubePlayerView.swift
//  BabyAlphabetApp
//
//  Embedded YouTube player using the official IFrame Player API inside a
//  WKWebView. When a video ends, it notifies Swift so the rhyme queue can
//  auto-advance to the next song.
//

import SwiftUI
@preconcurrency import WebKit

struct YouTubePlayerView: UIViewRepresentable {
    let videoID: String
    var autoplay: Bool = true
    var onEnded: (() -> Void)?

    func makeCoordinator() -> Coordinator {
        Coordinator(videoID: videoID, onEnded: onEnded)
    }

    func makeUIView(context: Context) -> WKWebView {
        let userContent = WKUserContentController()
        userContent.add(context.coordinator, name: "rhymeEnded")

        let config = WKWebViewConfiguration()
        config.userContentController = userContent
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.scrollView.isScrollEnabled = false
        webView.backgroundColor = .black
        webView.isOpaque = false
        context.coordinator.webView = webView
        loadPlayer(in: webView, videoID: videoID, autoplay: autoplay)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        context.coordinator.onEnded = onEnded
        if context.coordinator.loadedVideoID != videoID {
            context.coordinator.loadedVideoID = videoID
            loadPlayer(in: uiView, videoID: videoID, autoplay: autoplay)
        }
    }

    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        uiView.configuration.userContentController.removeScriptMessageHandler(forName: "rhymeEnded")
    }

    final class Coordinator: NSObject, WKScriptMessageHandler {
        var loadedVideoID: String
        var onEnded: (() -> Void)?
        weak var webView: WKWebView?

        init(videoID: String, onEnded: (() -> Void)?) {
            self.loadedVideoID = videoID
            self.onEnded = onEnded
        }

        func userContentController(
            _ userContentController: WKUserContentController,
            didReceive message: WKScriptMessage
        ) {
            guard message.name == "rhymeEnded" else { return }
            DispatchQueue.main.async { [weak self] in
                self?.onEnded?()
            }
        }
    }

    private func loadPlayer(in webView: WKWebView, videoID: String, autoplay: Bool) {
        let autoplayFlag = autoplay ? 1 : 0
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
          <style>
            html, body { margin: 0; padding: 0; background: #000; height: 100%; overflow: hidden; }
            #player { position: absolute; inset: 0; width: 100%; height: 100%; }
          </style>
        </head>
        <body>
          <div id="player"></div>
          <script>
            var tag = document.createElement('script');
            tag.src = "https://www.youtube.com/iframe_api";
            var firstScriptTag = document.getElementsByTagName('script')[0];
            firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

            var player;
            function onYouTubeIframeAPIReady() {
              player = new YT.Player('player', {
                width: '100%',
                height: '100%',
                videoId: '\(videoID)',
                playerVars: {
                  playsinline: 1,
                  rel: 0,
                  modestbranding: 1,
                  autoplay: \(autoplayFlag),
                  fs: 1,
                  enablejsapi: 1
                },
                events: {
                  onStateChange: onPlayerStateChange,
                  onError: function() {
                    // If a video fails, skip ahead so the queue keeps moving.
                    setTimeout(function() {
                      try { window.webkit.messageHandlers.rhymeEnded.postMessage('error'); } catch (e) {}
                    }, 800);
                  }
                }
              });
            }

            function onPlayerStateChange(event) {
              // 0 === YT.PlayerState.ENDED
              if (event.data === 0) {
                try { window.webkit.messageHandlers.rhymeEnded.postMessage('ended'); } catch (e) {}
              }
            }
          </script>
        </body>
        </html>
        """
        webView.loadHTMLString(html, baseURL: URL(string: "https://www.youtube-nocookie.com"))
    }
}

/// Full rhyme player with playlist auto-advance when a video ends.
struct RhymePlayerView: View {
    let playlist: [Rhyme]
    let startIndex: Int

    @State private var currentIndex: Int
    @State private var audioOnly = false
    @State private var autoPlayNext = true
    @State private var playerEpoch = 0

    init(playlist: [Rhyme], startIndex: Int = 0) {
        self.playlist = playlist
        self.startIndex = startIndex
        _currentIndex = State(initialValue: min(max(0, startIndex), max(playlist.count - 1, 0)))
    }

    /// Convenience for single-rhyme navigation destinations.
    init(rhyme: Rhyme) {
        let list = Rhyme.rhymes(for: rhyme.language)
        let idx = list.firstIndex(of: rhyme) ?? 0
        self.init(playlist: list.isEmpty ? [rhyme] : list, startIndex: idx)
    }

    private var current: Rhyme {
        guard !playlist.isEmpty else {
            return Rhyme(
                id: "empty",
                title: L10n(.english).noRhymes,
                language: .english,
                youtubeVideoID: "",
                topic: .language,
                audioFileName: nil,
                thumbnailSystemImage: "music.note"
            )
        }
        return playlist[currentIndex]
    }

    private var s: L10n { L10n(current.language) }

    private var hasPrevious: Bool { currentIndex > 0 }
    private var hasNext: Bool { currentIndex + 1 < playlist.count }

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black)

                if !current.youtubeVideoID.isEmpty {
                    YouTubePlayerView(
                        videoID: current.youtubeVideoID,
                        autoplay: true,
                        onEnded: handleVideoEnded
                    )
                    .id("\(current.id)-\(playerEpoch)")
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .opacity(audioOnly ? 0.0001 : 1)
                }

                if audioOnly {
                    VStack(spacing: 12) {
                        Image(systemName: "waveform")
                            .font(.system(size: 50))
                            .foregroundStyle(.white)
                        Text(current.title)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Text(s.audioOnlyMode)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
            }
            .aspectRatio(16/9, contentMode: .fit)
            .padding(.horizontal)

            Text(current.title)
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Label(s.topic(current.topic), systemImage: current.topic.systemImage)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.purple)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.purple.opacity(0.12), in: Capsule())

            Text(s.songOf(currentIndex + 1, total: max(playlist.count, 1)))
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)

            HStack(spacing: 28) {
                Button(action: playPrevious) {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 22, weight: .bold))
                }
                .disabled(!hasPrevious)
                .opacity(hasPrevious ? 1 : 0.35)

                Button(action: playNext) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 22, weight: .bold))
                }
                .disabled(!hasNext)
                .opacity(hasNext ? 1 : 0.35)
            }
            .buttonStyle(.bordered)
            .padding(.top, 4)

            Toggle(isOn: $autoPlayNext) {
                Label(s.autoPlayNext, systemImage: "arrow.triangle.2.circlepath")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
            }
            .padding(.horizontal, 32)

            Toggle(isOn: $audioOnly) {
                Label(s.audioOnly, systemImage: "speaker.wave.2")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
            }
            .padding(.horizontal, 32)

            if autoPlayNext, hasNext {
                Text(s.nextUp(playlist[currentIndex + 1].title))
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            } else if autoPlayNext, !hasNext {
                Text(s.lastSong)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.top)
        .navigationTitle(s.rhymeTime)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func handleVideoEnded() {
        guard autoPlayNext else { return }
        playNext()
    }

    private func playNext() {
        guard hasNext else { return }
        withAnimation(.easeInOut(duration: 0.25)) {
            currentIndex += 1
            playerEpoch += 1
        }
    }

    private func playPrevious() {
        guard hasPrevious else { return }
        withAnimation(.easeInOut(duration: 0.25)) {
            currentIndex -= 1
            playerEpoch += 1
        }
    }
}
