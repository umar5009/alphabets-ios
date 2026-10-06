//
//  LanguageOnboardingView.swift
//  BabyAlphabetApp
//

import SwiftUI

struct LanguageOnboardingView: View {
    @EnvironmentObject var store: ProgressStore
    @Environment(\.dismiss) private var dismiss

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 16)]

    /// Prefer current selection for chrome; fall back to English on first launch.
    private var s: L10n {
        L10n(store.hasSelectedLanguage ? store.selectedLanguage : .english)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(store.hasSelectedLanguage ? s.changeLanguage : s.welcome)
                            .font(.system(size: 32, weight: .heavy, design: .rounded))
                        Text(store.hasSelectedLanguage ? s.changeLanguageBody : s.welcomeBody)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)

                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(AppLanguage.allCases) { language in
                            Button {
                                store.selectLanguage(language)
                                if store.hasSelectedLanguage {
                                    dismiss()
                                }
                            } label: {
                                VStack(spacing: 8) {
                                    Text(language.flagEmoji).font(.system(size: 40))
                                    Text(language.displayName)
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundStyle(.primary)
                                    Text(L10n(language).lettersAndCounting(language.letters.count))
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundStyle(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, minHeight: 120)
                                .background(.background, in: RoundedRectangle(cornerRadius: 20))
                                .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle(s.chooseLanguage)
            .background(
                LinearGradient(
                    colors: [Color.purple.opacity(0.08), Color.mint.opacity(0.06), Color(.systemBackground)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
        }
    }
}
