//
//  RootTabView.swift
//  BabyAlphabetApp
//

import SwiftUI

struct RootTabView: View {
    @StateObject private var store = ProgressStore.shared

    private var s: L10n { L10n(store.selectedLanguage) }

    var body: some View {
        Group {
            if store.hasSelectedLanguage {
                TabView {
                    LearnHomeView()
                        .environmentObject(store)
                        .tabItem { Label(s.tabLearn, systemImage: "pencil.and.outline") }

                    MathHomeView()
                        .environmentObject(store)
                        .tabItem { Label(s.tabMath, systemImage: "plus.forwardslash.minus") }

                    RhymesView()
                        .environmentObject(store)
                        .tabItem { Label(s.tabRhymes, systemImage: "music.note") }

                    RewardsView()
                        .environmentObject(store)
                        .tabItem { Label(s.tabRewards, systemImage: "gift.fill") }

                    LeaderboardView()
                        .environmentObject(store)
                        .tabItem { Label(s.tabLeaderboard, systemImage: "trophy.fill") }
                }
                .tint(.purple)
                .environment(\.layoutDirection, store.selectedLanguage.isRightToLeft ? .rightToLeft : .leftToRight)
            } else {
                LanguageOnboardingView()
                    .environmentObject(store)
            }
        }
        .id(store.selectedLanguage) // refresh tab labels when language changes
    }
}

#Preview {
    RootTabView()
}
