//
//  Localizable.swift
//  mindplay
//
//  Created for MindPlay app.
//

import Foundation
import SwiftUI

// 支持的语言
enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case chinese = "zh-Hans"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .chinese: return "中文"
        }
    }
}

// 语言管理器
class LanguageManager: ObservableObject {
    @Published var currentLanguage: AppLanguage
    
    private let languageKey = "app_language"
    
    init() {
        // 尝试从用户默认设置中获取语言设置
        if let savedLanguage = UserDefaults.standard.string(forKey: languageKey),
           let language = AppLanguage(rawValue: savedLanguage) {
            self.currentLanguage = language
        } else {
            // 默认使用系统语言
            let preferredLanguage = Locale.preferredLanguages.first ?? "en"
            if preferredLanguage.starts(with: "zh") {
                self.currentLanguage = .chinese
            } else {
                self.currentLanguage = .english
            }
        }
    }
    
    func setLanguage(_ language: AppLanguage) {
        currentLanguage = language
        UserDefaults.standard.set(language.rawValue, forKey: languageKey)
    }
}

// 本地化字符串扩展
extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
    
    func localized(with arguments: CVarArg...) -> String {
        String(format: self.localized, arguments: arguments)
    }
}

// 本地化字符串键
struct LocalizedStringKey {
    // 通用
    static let appName = "app_name"
    static let settings = "settings"
    static let done = "done"
    static let aboutTheApp = "about_the_app"
    static let version = "version"
    static let developer = "developer"
    static let digits = "digits"
    
    // 首页
    static let trainYourBrain = "train_your_brain"
    
    // 反应时间测试
    static let reactionTimeTest = "reaction_time_test"
    static let testVisualReaction = "test_visual_reaction"
    static let roundCount = "round_count"
    static let bestScore = "best_score"
    static let startTest = "start_test"
    static let howToPlay = "how_to_play"
    static let waitForGreen = "wait_for_green"
    static let tapWhenChanges = "tap_when_changes"
    static let reactionMeasured = "reaction_measured"
    static let completeRounds = "complete_rounds"
    static let aboutTheTest = "about_the_test"
    static let aboutTestDescription = "about_test_description"
    static let excellent = "excellent"
    static let good = "good"
    static let average = "average"
    static let belowAverage = "below_average"
    static let exceptional = "exceptional"
    
    // 序列记忆测试
    static let sequenceMemoryTest = "sequence_memory_test"
    static let rememberPattern = "remember_pattern"
    static let watchSequence = "watch_sequence"
    static let repeatSequence = "repeat_sequence"
    static let sequenceWillGetLonger = "sequence_will_get_longer"
    static let level = "level"
    static let yourTurn = "your_turn"
    static let gridSize = "Grid Size"
    static let correct = "correct"
    static let wrong = "wrong"
    static let gameOver = "game_over"
    static let finalLevel = "final_level"
    static let startSequence = "start_sequence"
    static let aboutSequenceTest = "about_sequence_test"
    static let sequenceTestDescription = "sequence_test_description"
    
    // 数字记忆测试
    static let numberMemoryTest = "number_memory_test"
    static let rememberLongestNumber = "remember_longest_number"
    static let numberLength = "number_length"
    static let startNumberTest = "start_number_test"
    static let memorizeNumber = "memorize_number"
    static let enterNumber = "enter_number"
    static let timeRemaining = "time_remaining"
    static let submitAnswer = "submit_answer"
    static let levelReached = "level_reached"
    static let digitsRemembered = "digits_remembered"
    static let aboutNumberTest = "about_number_test"
    static let numberTestDescription = "number_test_description"
    static let nextLevel = "next_level"
    static let timeUp = "time_up"
    static let correctNumber = "correct_number"
    static let yourNumber = "your_number"
    static let numberExplanation = "number_explanation"
    static let numberGameRule = "number_game_rule"
    
    // 目标训练测试
    static let aimTrainerTest = "aim_trainer_test"
    static let hitTargets = "hit_targets"
    static let clickToBegin = "click_to_begin"
    static let targetsRemaining = "targets_remaining"
    static let targetHit = "target_hit"
    static let totalTime = "total_time"
    static let avgTimePerTarget = "avg_time_per_target"
    static let aboutAimTest = "about_aim_test"
    static let aimTestDescription = "aim_test_description"
    static let tapTarget = "tap_target"
    static let completeTargets = "complete_targets"
    static let fastestClick = "fastest_click"
    static let slowestClick = "slowest_click"
    static let totalTargets = "total_targets"
    static let aimExplanation1 = "aim_explanation1"
    static let aimExplanation2 = "aim_explanation2"
    static let excellentAim = "excellent_aim"
    static let goodAim = "good_aim"
    static let averageAim = "average_aim"
    static let belowAverageAim = "below_average_aim"
    static let exceptionalAim = "exceptional_aim"
    
    // 游戏界面
    static let getReady = "get_ready"
    static let tapWhenGreen = "tap_when_green"
    static let tapToStartRound = "tap_to_start_round"
    static let wait = "wait"
    static let tapNow = "tap_now"
    static let tooEarly = "too_early"
    static let tooEarlyDescription = "too_early_description"
    static let tryAgain = "try_again"
    static let yourReactionTime = "your_reaction_time"
    static let roundOf = "round_of"
    static let nextRound = "next_round"
    static let seeResults = "see_results"
    static let tapToStart = "tap_to_start"
    static let seconds = "seconds"
    
    // 结果页面
    static let yourAverageReactionTime = "your_average_reaction_time"
    static let percentileExcellent = "percentile_excellent"
    static let percentileGood = "percentile_good"
    static let percentileAverage = "percentile_average"
    static let percentileBelowAverage = "percentile_below_average"
    static let statistics = "statistics"
    static let bestTime = "best_time"
    static let attempts = "attempts"
    static let yourAttempts = "your_attempts"
    static let whatThisMeans = "what_this_means"
    static let resultExplanation = "result_explanation"
    static let resultFactors = "result_factors"
    static let backToMenu = "back_to_menu"
    static let playAgain = "play_again"
    static let msPerClick = "ms_per_click"
    static let noData = "no_data"
    static let completed = "completed"
    
    // 序列记忆结果页面
    static let sequenceResults = "sequence_results"
    static let memory = "memory"
    static let cells = "cells"
    static let performance = "performance"
    static let distribution = "distribution"
    static let needsPractice = "needs_practice"
    static let fairMemory = "fair_memory"
    static let goodMemory = "good_memory"
    static let greatMemory = "great_memory"
    static let exceptionalMemory = "exceptional_memory"
    static let needsPracticeDesc = "needs_practice_desc"
    static let fairMemoryDesc = "fair_memory_desc"
    static let goodMemoryDesc = "good_memory_desc"
    static let greatMemoryDesc = "great_memory_desc"
    static let exceptionalMemoryDesc = "exceptional_memory_desc"
    static let rating = "rating"
    static let results = "results"
    static let memoryExplanation = "memory_explanation"
    
    // 数字记忆结果页面
    static let excellentNumberMemory = "excellent_number_memory"
    static let goodNumberMemory = "good_number_memory"
    static let averageNumberMemory = "average_number_memory"
    static let belowAverageNumberMemory = "below_average_number_memory"
    static let yourResult = "your_result"
    
    // 词汇记忆测试
    static let verbalMemoryTest = "verbal_memory_test"
    static let keepWordsInMemory = "keep_words_in_memory"
    static let wordSeen = "word_seen"
    static let wordNew = "word_new"
    static let remainingLives = "remaining_lives"
    static let currentScore = "current_score"
    static let aboutVerbalTest = "about_verbal_test"
    static let verbalTestDescription = "verbal_test_description"
    static let threeStrikes = "three_strikes"
    static let wordExplanation = "word_explanation"
    
    // 词汇记忆指令
    static let verbalInstruction1 = "verbal_instruction_1"
    static let verbalInstruction2 = "verbal_instruction_2"
    static let verbalInstruction3 = "verbal_instruction_3"
    
    // 词汇记忆结果
    static let excellentVerbalMemory = "excellent_verbal_memory"
    static let goodVerbalMemory = "good_verbal_memory"
    static let averageVerbalMemory = "average_verbal_memory"
    static let belowAverageVerbalMemory = "below_average_verbal_memory"
    static let wordsRemembered = "words_remembered"
    static let testComplete = "test_complete"
    static let yourScore = "your_score"
    static let excellentMemory = "excellent_memory"
    static let goodJob = "good_job"
    
    // 猩猩测试
    static let chimpTest = "chimp_test"
    static let smarterThanChimp = "smarter_than_chimp"
    static let clickSquaresInOrder = "click_squares_in_order"
    static let testGetHarder = "test_get_harder"
    static let aboutChimpTest = "about_chimp_test"
    static let chimpTestDescription = "chimp_test_description"
    static let chimpOutperformHumans = "chimp_outperform_humans"
    static let chimpTestRules = "chimp_test_rules"
    static let strikesRemaining = "strikes_remaining"
    static let memorizeNumbers = "memorize_numbers"
    static let numbersDisappear = "numbers_disappear"
    static let clickInOrder = "click_in_order"
    
    // 猩猩测试结果
    static let excellentChimpMemory = "excellent_chimp_memory"
    static let goodChimpMemory = "good_chimp_memory"
    static let averageChimpMemory = "average_chimp_memory"
    static let belowAverageChimpMemory = "below_average_chimp_memory"
    static let maxLevel = "max_level"
    
    // 视觉记忆测试
    static let visualMemoryTest = "visual_memory_test"
    static let memorizeSquares = "memorize_squares"
    static let aboutVisualTest = "about_visual_test"
    static let visualTestDescription = "visual_test_description"
    static let tilesFlashWhite = "tiles_flash_white"
    static let memorizeAndPick = "memorize_and_pick"
    static let levelProgressivelyHarder = "level_progressively_harder"
    static let missThreeTilesLoseLife = "miss_three_tiles_lose_life"
    static let threeLifeRemaining = "three_life_remaining"
    static let makeItFar = "make_it_far"
    static let startingGridSize = "starting_grid_size"
    static let performanceLevel = "performance_level"
    
    // 视觉记忆结果
    static let excellentVisualMemory = "excellent_visual_memory"
    static let goodVisualMemory = "good_visual_memory"
    static let averageVisualMemory = "average_visual_memory"
    static let belowAverageVisualMemory = "below_average_visual_memory"
    static let squaresRemembered = "squares_remembered"
    static let visualMemoryExplanation1 = "visual_memory_explanation1"
    static let visualMemoryExplanation2 = "visual_memory_explanation2"
    
    // 舒尔特表测试
    static let schulteTableTest = "schulte_table_test"
    static let enhanceAttention = "enhance_attention"
    static let findNumbers = "find_numbers"
    static let usePeripheralVision = "use_peripheral_vision"
    static let tableSize = "table_size"
    static let aboutSchulteTest = "about_schulte_test"
    static let schulteTestDescription = "schulte_test_description"
    static let childrenStandards = "children_standards"
    static let adultStandards = "adult_standards"
    static let brilliant = "brilliant"
    static let optimal = "optimal"
    static let mediocre = "mediocre"
    static let beginnerLevel = "beginner_level"
    static let averageProficiency = "average_proficiency"
    static let advancedLevel = "advanced_level"
    static let elitePerformance = "elite_performance"
    static let secondsOrLess = "seconds_or_less"
    static let upToSeconds = "up_to_seconds"
    static let yourTime = "your_time"
    static let secondsShort = "seconds_short"
    static let averageTime = "average_time"
    static let fastestTime = "fastest_time"
    static let findingNumber = "finding_number"
    
    // 舒尔特表结果
    static let excellentSchultePerformance = "excellent_schulte_performance"
    static let goodSchultePerformance = "good_schulte_performance"
    static let averageSchultePerformance = "average_schulte_performance"
    static let belowAverageSchultePerformance = "below_average_schulte_performance"
    
    // 舒尔特表表现描述
    static let excellentPerception = "excellent_perception"
    static let goodPerception = "good_perception"
    static let averagePerception = "average_perception"
    static let practicePerception = "practice_perception"
    
    // 舒尔特表和其他游戏需要的通用键
    static let result = "result"
    static let history = "history"
    static let home = "home"
    static let table = "table"
    
    // Last Circle 游戏
    static let lastCircleTest = "last_circle_test"
    static let tapNewestCircle = "tap_newest_circle"
    static let watchColorsAndOpacity = "watch_colors_and_opacity"
    static let aboutLastCircleTest = "about_last_circle_test"
    static let lastCircleDescription = "last_circle_description"
    static let startRound = "start_round"
    static let circlesCount = "circles_count"
    static let roundTime = "round_time"
    static let pointsScored = "points_scored"
    static let scoreExplanation = "score_explanation"
    
    // Last Circle 游戏规则
    static let lastCircleRule1 = "last_circle_rule1"
    static let lastCircleRule2 = "last_circle_rule2"
    static let lastCircleRule3 = "last_circle_rule3"
    static let lastCircleRule4 = "last_circle_rule4"
    
    // Last Circle 结果
    static let excellentLastCircleMemory = "excellent_last_circle_memory"
    static let goodLastCircleMemory = "good_last_circle_memory"
    static let averageLastCircleMemory = "average_last_circle_memory"
    static let belowAverageLastCircleMemory = "below_average_last_circle_memory"
    static let lastCircleExplanation = "last_circle_explanation"
    
    // NPuzzle游戏
    static let nPuzzleTest = "n_puzzle_test"
    static let slidingPuzzle = "sliding_puzzle"
    static let moveTiles = "move_tiles"
    static let timeUsed = "time_used"
    static let movesMade = "moves_made"
    static let resetPuzzle = "reset_puzzle"
    static let showHint = "show_hint"
    static let puzzleCompleted = "puzzle_completed"
    static let startPuzzle = "start_puzzle"
    static let nPuzzleRule1 = "n_puzzle_rule1"
    static let nPuzzleRule2 = "n_puzzle_rule2"
    static let nPuzzleRule3 = "n_puzzle_rule3"
    static let nPuzzleRule4 = "n_puzzle_rule4"
    static let aboutNPuzzleTest = "about_n_puzzle_test"
    static let nPuzzleDescription = "n_puzzle_description"
    static let nPuzzleExplanation = "n_puzzle_explanation"
    static let excellentNPuzzleSkill = "excellent_n_puzzle_skill"
    static let goodNPuzzleSkill = "good_n_puzzle_skill"
    static let averageNPuzzleSkill = "average_n_puzzle_skill"
    static let belowAverageNPuzzleSkill = "below_average_n_puzzle_skill"
}

extension LocalizedStringKey {
    var localized: String {
        return NSLocalizedString(String(describing: self), comment: "")
    }
}
