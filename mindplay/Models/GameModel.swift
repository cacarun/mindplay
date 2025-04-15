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
    case aimTrainer = "Aim Trainer"
    case numberMemory = "Number Memory"
    case verbalMemory = "Verbal Memory"
    case chimpTest = "Chimp Test"
    case visualMemory = "Visual Memory"
    case schulteTable = "Schulte Table"
    // Future games will be added here
    
    var id: String { self.rawValue }
    
    // 本地化游戏名称
    var localizedName: String {
        switch self {
        case .reactionTime:
            return LocalizedStringKey.reactionTimeTest.localized
        case .sequenceMemory:
            return LocalizedStringKey.sequenceMemoryTest.localized
        case .aimTrainer:
            return LocalizedStringKey.aimTrainerTest.localized
        case .numberMemory:
            return LocalizedStringKey.numberMemoryTest.localized
        case .verbalMemory:
            return LocalizedStringKey.verbalMemoryTest.localized
        case .chimpTest:
            return LocalizedStringKey.chimpTest.localized
        case .visualMemory:
            return LocalizedStringKey.visualMemoryTest.localized
        case .schulteTable:
            return LocalizedStringKey.schulteTableTest.localized
        }
    }
    
    var description: String {
        switch self {
        case .reactionTime:
            return "Test your reaction speed by tapping when the screen changes color."
        case .sequenceMemory:
            return "Remember an increasingly long pattern of button presses."
        case .aimTrainer:
            return "Click the targets as quickly and accurately as you can."
        case .numberMemory:
            return "Remember the longest number you can."
        case .verbalMemory:
            return "Remember and recall words or phrases."
        case .chimpTest:
            return "Test your memory and cognitive abilities."
        case .visualMemory:
            return "Remember an increasingly large board of squares."
        case .schulteTable:
            return "Enhance your attention and peripheral vision."
        }
    }
    
    var iconName: String {
        switch self {
        case .reactionTime:
            return "bolt.fill"
        case .sequenceMemory:
            return "square.grid.3x3.fill"
        case .aimTrainer:
            return "target"
        case .numberMemory:
            return "number.square.fill"
        case .verbalMemory:
            return "text.book.closed.fill"
        case .chimpTest:
            return "brain.head.profile"
        case .visualMemory:
            return "eye.fill"
        case .schulteTable:
            return "grid"
        }
    }
}

// Model for storing game results
struct GameResult: Identifiable, Codable {
    var id = UUID()
    let gameType: String
    let score: Double
    let date: Date
    var extraData: String? // 添加额外数据字段，可选
    
    init(gameType: GameType, score: Double, extraData: String? = nil) {
        self.gameType = gameType.rawValue
        self.score = score
        self.date = Date()
        self.extraData = extraData
    }
}

// Class to manage game data and user progress
class GameDataManager: ObservableObject {
    @Published var gameResults: [GameResult] = []
    
    private let saveKey = "mindplay_game_results"
    
    init() {
        loadResults()
    }
    
    func saveResult(gameType: GameType, score: Double, extraData: String? = nil) {
        let result = GameResult(gameType: gameType, score: score, extraData: extraData)
        gameResults.append(result)
        saveResults()
    }
    
    func getBestScore(for gameType: GameType, with extraData: String? = nil) -> Double? {
        let filteredResults = gameResults.filter { 
            $0.gameType == gameType.rawValue && 
            (extraData == nil || $0.extraData == extraData) 
        }
        
        switch gameType {
        case .reactionTime:
            // For reaction time, lower is better
            return filteredResults.min(by: { $0.score < $1.score })?.score
        case .sequenceMemory, .aimTrainer:
            // For sequence memory and aim trainer, lower is better (faster time)
            return filteredResults.min(by: { $0.score < $1.score })?.score
        case .numberMemory:
            // For number memory, higher is better
            return filteredResults.max(by: { $0.score < $1.score })?.score
        case .verbalMemory:
            // For verbal memory, higher is better
            return filteredResults.max(by: { $0.score < $1.score })?.score
        case .chimpTest:
            // For chimp test, higher is better
            return filteredResults.max(by: { $0.score < $1.score })?.score
        case .visualMemory:
            // For visual memory, higher is better
            return filteredResults.max(by: { $0.score < $1.score })?.score
        case .schulteTable:
            // For schulte table, lower is better (faster time)
            return filteredResults.min(by: { $0.score < $1.score })?.score
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
