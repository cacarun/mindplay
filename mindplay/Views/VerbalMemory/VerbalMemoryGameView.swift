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
    @State private var isAnimating = false // 用于动画控制
    @State private var wordAppear = false // 单词出现动画
    @State private var showPulse = false // 脉冲动画效果
    
    // 词汇记忆的主题色 - 使用黄色和橙色
    private let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.95, green: 0.6, blue: 0.2),
            Color(red: 0.85, green: 0.4, blue: 0.3)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // 用于加载单词列表的常量
    private let wordCount = 500 // 预加载的单词数量
    
    var body: some View {
        ZStack {
            // 渐变背景
            backgroundGradient
                .ignoresSafeArea()
            
            // 背景装饰元素
            GeometryReader { geometry in
                ZStack {
                    // 添加一些装饰性圆形
                    ForEach(0..<5) { i in
                        let sizes: [CGFloat] = [100, 80, 120, 90, 110]
                        let posX: [CGFloat] = [0.1, 0.85, 0.25, 0.75, 0.5]
                        let posY: [CGFloat] = [0.2, 0.15, 0.85, 0.7, 0.3]
                        let rotations: [Double] = [10, -8, 15, -12, 5]
                        let durations: [Double] = [7, 8, 6, 9, 7.5]
                        
                        Circle()
                            .stroke(Color.white.opacity(0.08), lineWidth: 2)
                            .frame(width: sizes[i], height: sizes[i])
                            .position(
                                x: max(100, geometry.size.width) * posX[i],
                                y: max(100, geometry.size.height) * posY[i]
                            )
                            .rotationEffect(.degrees(isAnimating ? rotations[i] : 0))
                            .animation(
                                Animation.easeInOut(duration: durations[i])
                                    .repeatForever(autoreverses: true),
                                value: isAnimating
                            )
                    }
                    
                    // 单词出现时的脉冲效果 (仅在游戏中显示)
                    if gameState == .playing && showPulse {
                        ForEach(0..<3) { i in
                            Circle()
                                .stroke(Color.white.opacity(0.15), lineWidth: 2)
                                .frame(width: 220 + CGFloat(i * 40))
                                .scaleEffect(isAnimating ? 1.1 : 0.9)
                                .opacity(isAnimating ? 0.3 : 0.1)
                                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                                .animation(
                                    Animation.easeInOut(duration: 1.5 + Double(i) * 0.2)
                                        .repeatForever(autoreverses: true),
                                    value: isAnimating
                                )
                        }
                    }
                }
            }
            
            VStack {
                // 顶部状态栏
                HStack(spacing: 40) {
                    // 分数卡片
                    VStack {
                        Text(LocalizedStringKey.currentScore.localized)
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text("\(score)")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                    
                    // 生命值卡片
                    VStack {
                        Text(LocalizedStringKey.remainingLives.localized)
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.9))
                        
                        HStack(spacing: 8) {
                            ForEach(0..<3) { index in
                                Image(systemName: index < lives ? "heart.fill" : "heart")
                                    .foregroundColor(index < lives ? .red : .white.opacity(0.4))
                                    .font(.title2)
                                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                            }
                        }
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                }
                .padding(.top, 30)
                .padding(.bottom, 20)
                
                Spacer()
                
                // 游戏内容区域
                if gameState == .playing {
                    // 显示单词
                    ZStack {
                        // 单词背景卡片
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 300, height: 150)
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                        
                        // 单词
                        Text(currentWord)
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 1, y: 1)
                            .scaleEffect(wordAppear ? 1.0 : 0.7)
                            .opacity(wordAppear ? 1 : 0)
                            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: wordAppear)
                    }
                    .padding(.bottom, 40)
                } else if gameState == .ready {
                    // 开始页面
                    VStack(spacing: 25) {
                        // 动画图标
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 70))
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(Color.white.opacity(0.2)))
                            .scaleEffect(isAnimating ? 1.1 : 0.9)
                            .animation(
                                Animation.easeInOut(duration: 2)
                                    .repeatForever(autoreverses: true),
                                value: isAnimating
                            )
                        
                        Text(LocalizedStringKey.verbalMemoryTest.localized)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 1, y: 1)
                        
                        Text(LocalizedStringKey.keepWordsInMemory.localized)
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }
                    .padding(.bottom, 40)
                }
                
                // 控制按钮
                if gameState == .ready {
                    Button(action: {
                        startGame()
                        // 触觉反馈
                        let impactMed = UIImpactFeedbackGenerator(style: .medium)
                        impactMed.impactOccurred()
                    }) {
                        Text(LocalizedStringKey.startTest.localized)
                            .font(.headline)
                            .foregroundColor(Color(red: 0.95, green: 0.6, blue: 0.2))
                            .padding()
                            .frame(width: 200)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
                    }
                    .scaleEffect(isAnimating ? 1.05 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                } else if gameState == .playing {
                    // SEEN/NEW 按钮
                    HStack(spacing: 20) {
                        // 见过按钮
                        Button(action: {
                            handleSeen()
                            // 触觉反馈
                            let impactMed = UIImpactFeedbackGenerator(style: .medium)
                            impactMed.impactOccurred()
                        }) {
                            Text(LocalizedStringKey.wordSeen.localized)
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.vertical, 16)
                                .padding(.horizontal, 24)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.green.opacity(0.8))
                                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                                )
                        }
                        
                        // 新词按钮
                        Button(action: {
                            handleNew()
                            // 触觉反馈
                            let impactMed = UIImpactFeedbackGenerator(style: .medium)
                            impactMed.impactOccurred()
                        }) {
                            Text(LocalizedStringKey.wordNew.localized)
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.vertical, 16)
                                .padding(.horizontal, 24)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.orange.opacity(0.8))
                                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                                )
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            isAnimating = true
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
        // 先将单词隐藏，以便制作动画效果
        wordAppear = false
        
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
        
        // 延迟一小段时间后显示单词，制造动画效果
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            showPulse = true
            wordAppear = true
        }
    }
    
    // 处理用户点击"见过"按钮
    private func handleSeen() {
        if seenWords.contains(currentWord) {
            // 答对了
            score += 1
            
            // 成功反馈
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        } else {
            // 答错了
            lives -= 1
            
            // 错误反馈
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            
            // 将这个词加入到已见过的集合中
            seenWords.insert(currentWord)
        }
        
        // 检查游戏是否结束
        if lives <= 0 {
            // 保存游戏结果
            gameDataManager.saveResult(gameType: .verbalMemory, score: Double(score))
            
            // 延迟一小段时间后显示结果，让用户看清当前单词
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                isShowingResult = true
            }
            return
        }
        
        // 显示下一个单词
        showNextWord()
    }
    
    // 处理用户点击"新词"按钮
    private func handleNew() {
        if !seenWords.contains(currentWord) {
            // 答对了
            score += 1
            
            // 将这个词加入到已见过的集合中
            seenWords.insert(currentWord)
            
            // 成功反馈
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        } else {
            // 答错了
            lives -= 1
            
            // 错误反馈
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
        
        // 检查游戏是否结束
        if lives <= 0 {
            // 保存游戏结果
            gameDataManager.saveResult(gameType: .verbalMemory, score: Double(score))
            
            // 延迟一小段时间后显示结果，让用户看清当前单词
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                isShowingResult = true
            }
            return
        }
        
        // 显示下一个单词
        showNextWord()
    }
}

#Preview {
    VerbalMemoryGameView()
        .environmentObject(GameDataManager())
} 