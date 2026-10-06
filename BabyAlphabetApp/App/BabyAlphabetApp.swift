//
//  BabyAlphabetApp.swift
//  BabyAlphabetApp
//
//  App entry point. To use this file, create a new Xcode "App" project
//  named BabyAlphabetApp and replace its generated @main file with this
//  one (see README.md for full setup steps).
//

import SwiftUI

@main
struct BabyAlphabetApp: App {
    var body: some Scene {
        WindowGroup {
            RootTabView()
                .preferredColorScheme(.light) // consistent bright/cheerful palette for toddlers
        }
    }
}
