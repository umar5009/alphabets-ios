//
//  RhymesView.swift
//  BabyAlphabetApp
//

import SwiftUI

struct RhymesView: View {
    @EnvironmentObject var store: ProgressStore
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var language: AppLanguage { store.selectedLanguage }
    private var s: L10n { L10n(language) }

    private var gridColumns: [GridItem] {
        let count = horizontalSizeClass == .regular ? 3 : 2
        return Array(
            repeating: GridItem(.flexible(), spacing: 14),
            count: count
        )
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                let rhymes = Rhyme.rhymes(for: language)
                if rhymes.isEmpty {
                    Spacer()
                    Text(s.moreRhymesSoon(language.displayName))
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                    Spacer()
                } else {
                    HStack {
                        Text("\(language.flagEmoji) \(language.displayName)")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                        Text("·")
                            .foregroundStyle(.tertiary)
                        Text(s.educationalSongs(rhymes.count))
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Label(s.rhymeTopics, systemImage: "graduationcap.fill")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)

                    ScrollView {
                        LazyVGrid(columns: gridColumns, spacing: 16) {
                            ForEach(Array(rhymes.enumerated()), id: \.element.id) { index, rhyme in
                                NavigationLink {
                                    RhymePlayerView(playlist: rhymes, startIndex: index)
                                        .environmentObject(store)
                                } label: {
                                    RhymeThumbnailCard(rhyme: rhyme, number: index + 1, language: language)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle(s.rhymeTime)
        }
    }
}

private struct RhymeThumbnailCard: View {
    let rhyme: Rhyme
    let number: Int
    let language: AppLanguage

    private var s: L10n { L10n(language) }

    private var thumbnailURL: URL? {
        URL(string: "https://img.youtube.com/vi/\(rhyme.youtubeVideoID)/hqdefault.jpg")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.purple.opacity(0.12))

                AsyncImage(url: thumbnailURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        thumbnailFallback
                    case .empty:
                        ProgressView()
                            .tint(.purple)
                    @unknown default:
                        thumbnailFallback
                    }
                }
                .frame(maxWidth: .infinity)
                .aspectRatio(16 / 9, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                Circle()
                    .fill(.black.opacity(0.45))
                    .frame(width: 52, height: 52)
                    .overlay(
                        Image(systemName: "play.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                            .offset(x: 2)
                    )

                VStack {
                    HStack {
                        Text("#\(number)")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.black.opacity(0.55), in: Capsule())
                        Spacer()
                        Label(s.topic(rhyme.topic), systemImage: rhyme.topic.systemImage)
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.purple.opacity(0.85), in: Capsule())
                    }
                    .padding(8)
                    Spacer()
                }
            }
            .aspectRatio(16 / 9, contentMode: .fit)
            .shadow(color: .black.opacity(0.08), radius: 6, y: 3)

            Text(rhyme.title)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(minHeight: 36, alignment: .top)

            Label(s.teaches(s.topic(rhyme.topic)), systemImage: "graduationcap.fill")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private var thumbnailFallback: some View {
        Image(systemName: rhyme.thumbnailSystemImage)
            .font(.system(size: 36))
            .foregroundStyle(.purple.opacity(0.7))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
