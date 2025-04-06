//
//  HomeView.swift
//  mindplay
//
//  Created for MindPlay app.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var gameDataManager: GameDataManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("MindPlay")
                        .font(.system(size: 36, weight: .bold))
                        .padding(.top, 20)
                    
                    Text("Train your brain with cognitive games")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 20)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 300, maximum: 400), spacing: 16)], spacing: 16) {
                        ForEach(GameType.allCases) { gameType in
                            GameCardView(gameType: gameType)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarTitle("", displayMode: .inline)
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
        }
    }
}

struct GameCardView: View {
    let gameType: GameType
    @EnvironmentObject var gameDataManager: GameDataManager
    
    var body: some View {
        NavigationLink(destination: destinationView) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: gameType.iconName)
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    VStack(alignment: .leading) {
                        Text(gameType.rawValue)
                            .font(.headline)
                        
                        if let bestScore = gameDataManager.getBestScore(for: gameType) {
                            Text("Best: \(formatScore(bestScore))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                
                Text(gameType.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var destinationView: some View {
        switch gameType {
        case .reactionTime:
            return AnyView(ReactionTimeIntroView())
        }
    }
    
    private func formatScore(_ score: Double) -> String {
        switch gameType {
        case .reactionTime:
            return String(format: "%.0f ms", score)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(GameDataManager())
}
