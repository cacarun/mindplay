//
//  GameModel.swift
//  mindplay
//
//  Created for MindPlay app.
//

import Foundation

// Game types available in the app
enum GameType: String, CaseIterable, Identifiable {
    case reactionTime = "Reaction Time"
    case sequenceMemory = "Sequence Memory"
    // Future games will be added here
    
    var id: String { self.rawValue }
    
    // 本地化游戏名称
    var localizedName: String {
        switch self {
        case .reactionTime:
            return LocalizedStringKey.reactionTimeTest.localized
        case .sequenceMemory:
            return LocalizedStringKey.sequenceMemoryTest.localized
        }
    }
    
    var description: String {
        switch self {
        case .reactionTime:
            return "Test your reaction speed by tapping when the screen changes color."
        case .sequenceMemory:
            return "Remember an increasingly long pattern of button presses."
        }
    }
    
    var iconName: String {
        switch self {
        case .reactionTime:
            return "bolt.fill"
        case .sequenceMemory:
            return "brain.head.profile"
        }
    }
}

// Model for storing game results
struct GameResult: Identifiable, Codable {
    let id: UUID
    let gameType: String
    let score: Double
    let date: Date
    
    init(gameType: GameType, score: Double) {
        self.id = UUID()
        self.gameType = gameType.rawValue
        self.score = score
        self.date = Date()
    }
}

// Class to manage game data and user progress
class GameDataManager: ObservableObject {
    @Published var gameResults: [GameResult] = []
    
    private let saveKey = "mindplay_game_results"
    
    init() {
        loadResults()
    }
    
    func saveResult(gameType: GameType, score: Double) {
        let result = GameResult(gameType: gameType, score: score)
        gameResults.append(result)
        saveResults()
    }
    
    func getBestScore(for gameType: GameType) -> Double? {
        let filteredResults = gameResults.filter { $0.gameType == gameType.rawValue }
        
        switch gameType {
        case .reactionTime:
            // For reaction time, lower is better
            return filteredResults.min(by: { $0.score < $1.score })?.score
        case .sequenceMemory:
            // For sequence memory, higher is better
            return filteredResults.max(by: { $0.score < $1.score })?.score
        }
    }
    
    private func saveResults() {
        if let encoded = try? JSONEncoder().encode(gameResults) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadResults() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([GameResult].self, from: data) {
            gameResults = decoded
        }
    }
}
