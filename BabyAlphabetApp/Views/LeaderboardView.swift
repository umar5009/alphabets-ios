//
//  LeaderboardView.swift
//  BabyAlphabetApp
//

import SwiftUI

struct LeaderboardView: View {
    @EnvironmentObject var store: ProgressStore
    @State private var shareImage: Image?
    @State private var renderedUIImage: UIImage?
    @State private var isSharing = false

    private var s: L10n { L10n(store.selectedLanguage) }

    var body: some View {
        NavigationStack {
            ScrollView {
                LeaderboardCard(
                    entries: store.leaderboardEntries(),
                    profile: store.profile,
                    language: store.selectedLanguage
                )
                .padding()
            }
            .navigationTitle(s.leaderboard)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        renderShareImage()
                    } label: {
                        Label(s.share, systemImage: "square.and.arrow.up")
                    }
                }
            }
            .sheet(isPresented: $isSharing) {
                if let renderedUIImage {
                    ActivityShareSheet(activityItems: [renderedUIImage])
                }
            }
        }
    }

    @MainActor
    private func renderShareImage() {
        let card = LeaderboardCard(
            entries: store.leaderboardEntries(),
            profile: store.profile,
            language: store.selectedLanguage,
            forExport: true
        )
        .frame(width: 420)
        .padding()
        .background(Color.white)

        let renderer = ImageRenderer(content: card)
        renderer.scale = UIScreen.main.scale
        if let uiImage = renderer.uiImage {
            renderedUIImage = uiImage
            isSharing = true
        }
    }
}

private struct LeaderboardCard: View {
    let entries: [LeaderboardEntry]
    let profile: ChildProfile
    let language: AppLanguage
    var forExport: Bool = false

    private var s: L10n { L10n(language) }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(s.alphabetChampions)
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                Spacer()
                if forExport {
                    Text(Date.now.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }

            ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                LeaderboardRow(
                    rank: index + 1,
                    entry: entry,
                    isMe: entry.name == profile.name,
                    language: language
                )
            }
        }
        .padding()
        .background(
            LinearGradient(colors: [.purple.opacity(0.08), .pink.opacity(0.08)], startPoint: .top, endPoint: .bottom),
            in: RoundedRectangle(cornerRadius: 20)
        )
    }
}

private struct LeaderboardRow: View {
    let rank: Int
    let entry: LeaderboardEntry
    let isMe: Bool
    let language: AppLanguage

    private var s: L10n { L10n(language) }

    var body: some View {
        HStack(spacing: 12) {
            Text(rankBadge)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .frame(width: 32)

            Text(entry.avatarEmoji).font(.system(size: 28))

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.name)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                Text(s.badgesAndLetters(entry.totalBadges, letters: entry.lettersTraced))
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: "circlebadge.fill").foregroundStyle(.yellow).font(.system(size: 12))
                Text("\(entry.totalCoins)")
                    .font(.system(size: 16, weight: .heavy, design: .rounded))
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(isMe ? Color.purple.opacity(0.12) : Color.clear, in: RoundedRectangle(cornerRadius: 14))
    }

    private var rankBadge: String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "#\(rank)"
        }
    }
}

private struct ActivityShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
