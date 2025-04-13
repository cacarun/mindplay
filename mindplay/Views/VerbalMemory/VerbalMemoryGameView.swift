//
//  VerbalMemoryGameView.swift
//  mindplay
//
//  Created for MindPlay app.
//

import SwiftUI

enum VerbalMemoryGameState {
    case ready     // 准备开始
    case playing   // 游戏进行中
    case finished  // 游戏结束
}

struct VerbalMemoryGameView: View {
    @EnvironmentObject var gameDataManager: GameDataManager
    @Environment(\.dismiss) private var dismiss
    
    // 游戏状态
    @State private var gameState: VerbalMemoryGameState = .ready
    @State private var currentWord = "" // 当前显示的单词
    @State private var seenWords: Set<String> = [] // 已经看过的单词集合
    @State private var allWords: [String] = [] // 所有可用的单词
    @State private var score = 0 // 得分
    @State private var lives = 3 // 剩余生命
    @State private var isShowingResult = false // 是否显示结果
    
    // 用于加载单词列表的常量
    private let wordCount = 500 // 预加载的单词数量
    
    var body: some View {
        ZStack {
            // 背景颜色
            Color.indigo
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // 状态区域
                HStack(spacing: 40) {
                    // 分数
                    VStack {
                        Text(LocalizedStringKey.currentScore.localized)
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("\(score)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    // 生命值
                    VStack {
                        Text(LocalizedStringKey.remainingLives.localized)
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                        
                        HStack(spacing: 5) {
                            ForEach(0..<3) { index in
                                Image(systemName: index < lives ? "heart.fill" : "heart")
                                    .foregroundColor(.red)
                                    .font(.title2)
                            }
                        }
                    }
                }
                .padding(.bottom, 40)
                
                // 显示单词
                if gameState == .playing {
                    Text(currentWord)
                        .font(.system(size: 44, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 300, height: 150)
                        )
                        .padding(.bottom, 50)
                } else if gameState == .ready {
                    // 准备开始
                    VStack(spacing: 20) {
                        Text(LocalizedStringKey.verbalMemoryTest.localized)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(LocalizedStringKey.keepWordsInMemory.localized)
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.bottom, 50)
                }
                
                // 控制按钮
                if gameState == .ready {
                    Button(action: {
                        startGame()
                    }) {
                        Text(LocalizedStringKey.startTest.localized)
                            .font(.headline)
                            .foregroundColor(.indigo)
                            .padding()
                            .frame(width: 200)
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                } else if gameState == .playing {
                    // SEEN/NEW 按钮
                    HStack(spacing: 20) {
                        Button(action: {
                            handleSeen()
                        }) {
                            Text(LocalizedStringKey.wordSeen.localized)
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 120)
                                .background(Color.green.opacity(0.8))
                                .cornerRadius(12)
                        }
                        
                        Button(action: {
                            handleNew()
                        }) {
                            Text(LocalizedStringKey.wordNew.localized)
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 120)
                                .background(Color.orange.opacity(0.8))
                                .cornerRadius(12)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            loadWords()
        }
        .fullScreenCover(isPresented: $isShowingResult) {
            VerbalMemoryResultView(
                score: score,
                onDismiss: { dismiss() },
                onRestart: {
                    resetGame()
                    gameState = .ready
                }
            )
        }
    }
    
    // 加载单词列表
    private func loadWords() {
        // 这里加载一些常用英文单词，实际应用中可以从外部资源文件加载
        let wordList = [
            "apple", "banana", "cherry", "date", "elderberry", "fig", "grape", "honeydew",
            "kiwi", "lemon", "mango", "nectarine", "orange", "papaya", "quince", "raspberry",
            "strawberry", "tangerine", "watermelon", "apricot", "blackberry", "coconut", "dragonfruit",
            "avocado", "blueberry", "cranberry", "durian", "guava", "lime", "peach", "pear",
            "plum", "pineapple", "pomegranate", "raisin", "tomato", "melon", "grapefruit", "mandarin",
            
            "computer", "keyboard", "mouse", "monitor", "laptop", "desktop", "tablet", "smartphone",
            "printer", "scanner", "speaker", "microphone", "camera", "router", "modem", "server",
            "network", "internet", "software", "hardware", "program", "application", "system", "database",
            "file", "folder", "document", "browser", "website", "email", "password", "username",
            "login", "logout", "download", "upload", "backup", "restore", "update", "upgrade",
            
            "house", "apartment", "building", "room", "kitchen", "bathroom", "bedroom", "living",
            "dining", "garden", "yard", "garage", "basement", "attic", "ceiling", "floor",
            "wall", "window", "door", "roof", "stair", "elevator", "balcony", "terrace",
            
            "chair", "table", "desk", "sofa", "couch", "bed", "cabinet", "drawer",
            "shelf", "bookcase", "lamp", "light", "mirror", "picture", "painting", "clock",
            "carpet", "curtain", "pillow", "blanket", "sheet", "towel", "shower", "bath",
            
            "car", "truck", "bus", "train", "airplane", "bicycle", "motorcycle", "boat",
            "ship", "helicopter", "subway", "taxi", "driver", "passenger", "ticket", "station",
            "airport", "highway", "road", "street", "avenue", "bridge", "tunnel", "traffic",
            
            "school", "college", "university", "student", "teacher", "professor", "class", "course",
            "lesson", "lecture", "homework", "exam", "test", "quiz", "grade", "degree",
            "education", "knowledge", "study", "learn", "teach", "instruction", "subject", "topic",
            
            "book", "magazine", "newspaper", "article", "story", "novel", "poem", "author",
            "writer", "reader", "library", "bookstore", "publisher", "edition", "chapter", "page",
            "paragraph", "sentence", "word", "letter", "character", "vocabulary", "grammar", "language",
            
            "music", "song", "melody", "rhythm", "harmony", "note", "instrument", "piano",
            "guitar", "drum", "violin", "flute", "trumpet", "saxophone", "orchestra", "band",
            "concert", "album", "record", "disc", "play", "listen", "sing", "dance"
        ]
        
        // 将单词列表打乱，并取前wordCount个
        allWords = Array(Set(wordList)).shuffled()
        
        // 如果实际单词数量不足，则进行复制扩充
        while allWords.count < wordCount {
            allWords += Array(Set(wordList)).shuffled()
        }
        
        // 截取需要的数量
        allWords = Array(allWords.prefix(wordCount))
    }
    
    // 开始游戏
    private func startGame() {
        resetGame()
        gameState = .playing
        showNextWord()
    }
    
    // 重置游戏状态
    private func resetGame() {
        score = 0
        lives = 3
        seenWords.removeAll()
        allWords.shuffle()
    }
    
    // 显示下一个单词
    private func showNextWord() {
        // 随机决定是显示已见过的还是新单词
        let showSeen = !seenWords.isEmpty && Int.random(in: 0..<3) > 0
        
        if showSeen {
            // 从已见过的单词中随机选择一个
            currentWord = seenWords.randomElement() ?? allWords.removeFirst()
        } else {
            // 如果还有新单词，则显示新单词
            if !allWords.isEmpty {
                currentWord = allWords.removeFirst()
            } else {
                // 如果没有新单词了，就从已见过的单词中选择一个
                currentWord = seenWords.randomElement() ?? ""
            }
        }
    }
    
    // 处理用户点击"见过"按钮
    private func handleSeen() {
        if seenWords.contains(currentWord) {
            // 正确：玩家确实见过这个单词
            score += 1
        } else {
            // 错误：玩家没见过这个单词
            lives -= 1
            // 现在这个单词也变成见过的了
            seenWords.insert(currentWord)
        }
        
        checkGameStatus()
    }
    
    // 处理用户点击"新词"按钮
    private func handleNew() {
        if seenWords.contains(currentWord) {
            // 错误：玩家实际上见过这个单词
            lives -= 1
        } else {
            // 正确：这是一个新单词
            score += 1
            // 将这个单词加入到已见过的集合中
            seenWords.insert(currentWord)
        }
        
        checkGameStatus()
    }
    
    // 检查游戏状态
    private func checkGameStatus() {
        if lives <= 0 {
            // 游戏结束
            endGame()
        } else {
            // 继续游戏
            showNextWord()
        }
    }
    
    // 结束游戏
    private func endGame() {
        gameState = .finished
        
        // 保存最高分
        gameDataManager.saveResult(gameType: .verbalMemory, score: Double(score))
        
        // 显示结果页面
        isShowingResult = true
    }
}

#Preview {
    VerbalMemoryGameView()
        .environmentObject(GameDataManager())
} 