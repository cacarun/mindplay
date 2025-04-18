//
//  ReactionTimeGameView.swift
//  mindplay
//
//  Created for MindPlay app.
//

import SwiftUI

enum GameState {
    case waiting      // Waiting to start the test
    case ready        // Ready to start, showing red screen
    case go           // Screen has turned green, waiting for tap
    case tooEarly     // User tapped too early
    case finished     // All rounds completed
}

struct ReactionTimeGameView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var gameDataManager: GameDataManager
    
    // 添加参数以接收自定义回合数
    let totalRounds: Int
    
    @State private var gameState: GameState = .waiting
    @State private var startTime: Date? = nil
    @State private var reactionTime: Double? = nil
    @State private var roundTimes: [Double] = []
    @State private var currentRound: Int = 1
    @State private var waitTime: Double = 0
    @State private var isFirstRound: Bool = true // 添加状态变量跟踪是否是第一轮
    @State private var isAnimating = false
    @State private var scaleEffect: CGFloat = 1.0
    
    private let minWaitTime = 1.5  // 最小等待时间（秒）
    private let maxWaitTime = 4.0  // 最大等待时间（秒）
    
    // 添加默认构造函数
    init(totalRounds: Int = 3) {
        self.totalRounds = totalRounds
    }
    
    var body: some View {
        ZStack {
            // Background color based on game state
            backgroundColor
                .ignoresSafeArea()
                .onTapGesture {
                    handleTap()
                }
            
            // 装饰性元素
            if gameState == .waiting || gameState == .tooEarly {
                GeometryReader { geometry in
                    ZStack {
                        // 装饰性圆形 - 仅在等待和错误状态显示
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 100, height: 100)
                            .position(x: geometry.size.width * 0.2, y: geometry.size.height * 0.2)
                            .offset(y: isAnimating ? -10 : 5)
                            .animation(Animation.easeInOut(duration: 3).repeatForever(autoreverses: true), value: isAnimating)
                        
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 70, height: 70)
                            .position(x: geometry.size.width * 0.8, y: geometry.size.height * 0.8)
                            .offset(y: isAnimating ? 10 : -5)
                            .animation(Animation.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: isAnimating)
                    }
                }
            }
            
            VStack {
                // Game content based on state
                switch gameState {
                case .waiting:
                    waitingContent
                case .ready:
                    readyContent
                case .go:
                    goContent
                case .tooEarly:
                    tooEarlyContent
                case .finished:
                    // This is handled by a sheet presentation
                    EmptyView()
                }
            }
            .padding()
        }
        .onAppear {
            startGame()
            isAnimating = true
        }
        .fullScreenCover(isPresented: Binding<Bool>(
            get: { gameState == .finished },
            set: { if !$0 { gameState = .waiting } }
        )) {
            ReactionTimeResultView(
                reactionTimes: roundTimes,
                totalRounds: totalRounds,
                onDismiss: { self.dismiss() },
                onRestart: { rounds in
                    // 关闭结果页面并以指定回合数重新开始游戏
                    gameState = .waiting
                    roundTimes = []
                    currentRound = 1
                    isFirstRound = true
                    // 如果回合数不同，更新totalRounds（虽然这种情况在当前实现中不会发生）
                    // totalRounds = rounds // 由于totalRounds是let常量，我们不能修改它
                }
            )
        }
    }
    
    // Background color based on game state
    private var backgroundColor: some View {
        Group {
            switch gameState {
            case .waiting:
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.3, green: 0.4, blue: 0.9),
                        Color(red: 0.5, green: 0.3, blue: 0.9)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .ready:
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.9, green: 0.2, blue: 0.2),
                        Color(red: 0.8, green: 0.3, blue: 0.3)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .go:
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.2, green: 0.8, blue: 0.3),
                        Color(red: 0.3, green: 0.7, blue: 0.4)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .tooEarly:
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.9, green: 0.5, blue: 0.2),
                        Color(red: 0.95, green: 0.4, blue: 0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .finished:
                Color.gray // This is not actually used as we present a full screen cover
            }
        }
    }
    
    // MARK: - Content Views for Different Game States
    
    private var waitingContent: some View {
        VStack(spacing: 30) {
            Text(LocalizedStringKey.getReady.localized)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.2), radius: 2, x: 1, y: 1)
                .padding(.top, 50)
                .scaleEffect(isAnimating ? 1.05 : 0.95)
                .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
            
            Spacer()
            
            VStack(spacing: 15) {
                Text(LocalizedStringKey.tapWhenGreen.localized)
                    .font(.title2)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Image(systemName: "hand.tap.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
                    .padding(.vertical, 20)
                    .scaleEffect(isAnimating ? 1.1 : 0.9)
                    .animation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
            }
            
            Spacer()
            
            Button(action: {
                startRound()
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
            }) {
                Text(String.localizedStringWithFormat(LocalizedStringKey.tapToStartRound.localized as String, totalRounds))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                    .padding(.horizontal, 20)
            }
            .padding(.bottom, 40)
        }
    }
    
    private var readyContent: some View {
        VStack {
            Text(LocalizedStringKey.wait.localized)
                .font(.system(size: 60, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.3), radius: 2, x: 1, y: 1)
                .scaleEffect(scaleEffect)
                .onAppear {
                    withAnimation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                        scaleEffect = 1.1
                    }
                }
        }
    }
    
    private var goContent: some View {
        VStack {
            Text(LocalizedStringKey.tapNow.localized)
                .font(.system(size: 60, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.3), radius: 2, x: 1, y: 1)
                .scaleEffect(scaleEffect)
                .onAppear {
                    withAnimation(Animation.easeInOut(duration: 0.3).repeatForever(autoreverses: true)) {
                        scaleEffect = 1.2
                    }
                }
        }
    }
    
    private var tooEarlyContent: some View {
        VStack(spacing: 24) {
            Text(LocalizedStringKey.tooEarly.localized)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.2), radius: 2, x: 1, y: 1)
            
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.white)
                .padding(.vertical, 10)
                .scaleEffect(isAnimating ? 1.1 : 0.9)
                .animation(Animation.easeInOut(duration: 0.7).repeatForever(autoreverses: true), value: isAnimating)
            
            Text(LocalizedStringKey.tooEarlyDescription.localized)
                .font(.title3)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                startRound()
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
            }) {
                Text(LocalizedStringKey.tryAgain.localized)
                    .font(.headline)
                    .foregroundColor(Color(red: 0.9, green: 0.5, blue: 0.2))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                    .padding(.horizontal, 20)
            }
            .padding(.top, 20)
        }
        .padding()
        .background(Color.white.opacity(0.15))
        .cornerRadius(25)
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
        .padding()
    }
    
    // MARK: - Game Logic
    
    private func startGame() {
        roundTimes = []
        currentRound = 1
        isFirstRound = true // 重置为第一轮
        gameState = .waiting
    }
    
    private func startRound() {
        gameState = .ready
        
        // Random wait time between min and max
        waitTime = Double.random(in: minWaitTime...maxWaitTime)
        
        // Schedule the screen to turn green after the wait time
        DispatchQueue.main.asyncAfter(deadline: .now() + waitTime) {
            // Only proceed if we're still in the ready state
            if gameState == .ready {
                gameState = .go
                startTime = Date()
                
                // 添加轻微震动反馈
                let impactLight = UIImpactFeedbackGenerator(style: .light)
                impactLight.impactOccurred()
            }
        }
    }
    
    private func handleTap() {
        switch gameState {
        case .waiting:
            // Start the round when tapped in waiting state
            startRound()
            
        case .ready:
            // Tapped too early
            gameState = .tooEarly
            
            // 添加错误震动反馈
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.notificationOccurred(.error)
            
        case .go:
            // Calculate reaction time
            if let startTime = startTime {
                let endTime = Date()
                let timeInterval = endTime.timeIntervalSince(startTime) * 1000 // Convert to milliseconds
                reactionTime = timeInterval
                roundTimes.append(timeInterval)
                
                // 添加成功震动反馈
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
                
                // 检查是否还有剩余回合
                if currentRound < totalRounds {
                    currentRound += 1
                    // 短暂延迟后自动开始下一回合，不显示结果页面
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        startRound()
                    }
                } else {
                    // 所有回合完成，显示最终结果
                    gameState = .finished
                    // Save the average score
                    let averageTime = roundTimes.reduce(0, +) / Double(roundTimes.count)
                    gameDataManager.saveResult(gameType: .reactionTime, score: averageTime)
                    
                    // 添加完成震动反馈
                    let notificationFeedback = UINotificationFeedbackGenerator()
                    notificationFeedback.notificationOccurred(.success)
                }
            }
            
        case .tooEarly:
            // These states have their own buttons for navigation
            break
            
        case .finished:
            // Should be handled by the sheet presentation
            break
        }
    }
}

#Preview {
    ReactionTimeGameView(totalRounds: 3)
        .environmentObject(GameDataManager())
}
