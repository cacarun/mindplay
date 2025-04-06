//
//  ContentView.swift
//  mindplay
//
//  Created by 蔡佳伟 on 2025/4/6.
//

import SwiftUI

struct ContentView: View {
    // Create a shared instance of GameDataManager
    @StateObject private var gameDataManager = GameDataManager()
    // Add language manager for localization
    @StateObject private var languageManager = LanguageManager()
    
    var body: some View {
        HomeView()
            .environmentObject(gameDataManager)
            .environmentObject(languageManager)
            .environment(\.locale, Locale(identifier: languageManager.currentLanguage.rawValue))
    }
}

#Preview {
    ContentView()
        .environmentObject(GameDataManager())
        .environmentObject(LanguageManager())
}
