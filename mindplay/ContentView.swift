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
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
