//
//  ChimpTestGameView.swift
//  mindplay
//
//  Created for MindPlay app.
//

import SwiftUI
import AVFoundation

enum ChimpTestGameState {
    case ready      // 准备开始
    case memorizing // 记忆数字阶段
    case playing    // 点击数字阶段
    case success    // 本轮成功
    case failure    // 本轮失败
    case finished   // 游戏结束
}

struct ChimpTestGameView: View {
    @EnvironmentObject var gameDataManager: GameDataManager
    @Environment(\.dismiss) private var dismiss
    
    // 游戏状态
    @State private var gameState: ChimpTestGameState = .ready
    @State private var currentLevel = 4 // 开始于4个数字
    @State private var strikes = 0 // 失误计数
    @State private var maxLevel = 4 // 记录达到的最高等级
    @State private var isShowingResult = false
    @State private var isAnimating = false // 控制动画状态
    @State private var showSuccessConfetti = false // 成功时显示彩色粒子
    
    // 方块信息
    @State private var squares: [NumberSquare] = []
    @State private var nextNumber = 1 // 下一个应该点击的数字
    
    // 布局信息
    private let gridSize = 5 // 5x5网格
    private let squareSpacing: CGFloat = 10.0
    @State private var boardSize: CGFloat = 300.0
    @State private var memorizingTimeRemaining: Int = 3 // 记忆时间
    
    // 数字显示定时器
    @State private var timer: Timer?
    
    // 音效服务
    private let soundService = SoundService.shared
    
    // 猩猩测试的主题色 - 使用蓝绿色和蓝色组合
    private let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.2, green: 0.6, blue: 0.8),
            Color(red: 0.1, green: 0.3, blue: 0.7)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 渐变背景
                backgroundGradient
                    .ignoresSafeArea()
                
                // 背景装饰元素
                ZStack {
                    // 添加一些装饰性圆形
                    ForEach(0..<5) { i in
                        let positions = [
                            CGPoint(x: geometry.size.width * 0.1, y: geometry.size.height * 0.2),
                            CGPoint(x: geometry.size.width * 0.85, y: geometry.size.height * 0.15),
                            CGPoint(x: geometry.size.width * 0.7, y: geometry.size.height * 0.85),
                            CGPoint(x: geometry.size.width * 0.25, y: geometry.size.height * 0.7),
                            CGPoint(x: geometry.size.width * 0.6, y: geometry.size.height * 0.4)
                        ]
                        
                        let sizes: [CGFloat] = [80, 120, 100, 90, 70]
                        let opacities: [Double] = [0.07, 0.05, 0.08, 0.06, 0.07]
                        
                        Circle()
                            .stroke(Color.white.opacity(opacities[i]), lineWidth: 2)
                            .frame(width: sizes[i], height: sizes[i])
                            .position(positions[i])
                            .rotationEffect(.degrees(isAnimating ? Double(i * 10) : 0))
                            .animation(
                                Animation.easeInOut(duration: Double(i) + 5)
                                    .repeatForever(autoreverses: true),
                                value: isAnimating
                            )
                    }
                    
                    // 成功时的彩色粒子
                    if showSuccessConfetti {
                        ForEach(0..<20) { i in
                            Circle()
                                .fill(confettiColor(for: i))
                                .frame(width: CGFloat.random(in: 5...15), height: CGFloat.random(in: 5...15))
                                .position(
                                    x: geometry.size.width * 0.5 + CGFloat.random(in: -100...100),
                                    y: geometry.size.height * 0.5 + CGFloat.random(in: -100...100)
                                )
                                .opacity(isAnimating ? 0 : 1)
                                .animation(
                                    Animation.easeOut(duration: Double.random(in: 0.5...1.2))
                                        .delay(Double.random(in: 0...0.3)),
                                    value: isAnimating
                                )
                        }
                    }
                }
                
                VStack(spacing: 20) {
                    // 顶部状态区域
                    HStack(spacing: 40) {
                        // 等级卡片
                        VStack {
                            Text(LocalizedStringKey.level.localized)
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.9))
                            
                            Text("\(currentLevel)")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                        
                        // 失误/生命卡片
                        VStack {
                            Text(LocalizedStringKey.strikesRemaining.localized)
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.9))
                            
                            HStack(spacing: 8) {
                                ForEach(0..<3) { index in
                                    Image(systemName: index < (3 - strikes) ? "heart.fill" : "heart")
                                        .foregroundColor(.red)
                                        .font(.title2)
                                        .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
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
                    
                    // 倒计时显示
                    if gameState == .memorizing {
                        Text("\(memorizingTimeRemaining)")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 80, height: 80)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                            )
                            .transition(.scale)
                            .scaleEffect(isAnimating ? 1.0 : 1.2)
                            .animation(
                                Animation.easeInOut(duration: 1.0)
                                    .repeatForever(autoreverses: true),
                                value: isAnimating
                            )
                    } else {
                        // 状态提示文本
                        if gameState == .playing {
                            Text(LocalizedStringKey.clickInOrder.localized)
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(10)
                        } else if gameState == .success {
                            Text(LocalizedStringKey.correct.localized)
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color.green.opacity(0.6))
                                .cornerRadius(10)
                                .scaleEffect(isAnimating ? 1.05 : 1.0)
                                .animation(
                                    Animation.easeInOut(duration: 0.5)
                                        .repeatForever(autoreverses: true),
                                    value: isAnimating
                                )
                        } else if gameState == .failure {
                            Text(LocalizedStringKey.wrong.localized)
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color.red.opacity(0.6))
                                .cornerRadius(10)
                        } else {
                            // 占位视图保持高度一致
                            Color.clear
                                .frame(height: 36)
                        }
                    }
                    
                    // 游戏区域
                    ZStack {
                        if gameState == .ready {
                            readyView
                        } else if gameState != .finished {
                            gameBoard
                        } else {
                            // 占位视图保持大小一致
                            Color.clear
                                .frame(width: boardSize, height: boardSize)
                        }
                    }
                    .frame(width: boardSize, height: boardSize)
                    
                    Spacer()
                    
                    // 控制按钮区域
                    VStack {
                        if gameState == .ready {
                            Button(action: {
                                // 触觉反馈
                                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                impactMed.impactOccurred()
                                startGame()
                            }) {
                                HStack {
                                    Image(systemName: "play.fill")
                                        .font(.headline)
                                    
                                    Text(LocalizedStringKey.startTest.localized)
                                        .font(.headline)
                                }
                                .foregroundColor(Color(red: 0.1, green: 0.3, blue: 0.7))
                                .padding(.vertical, 16)
                                .frame(width: 220)
                                .background(Color.white)
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 3)
                            }
                            .scaleEffect(isAnimating ? 1.05 : 1.0)
                            .animation(
                                Animation.easeInOut(duration: 1.8)
                                    .repeatForever(autoreverses: true),
                                value: isAnimating
                            )
                        } else if gameState == .success {
                            Button(action: {
                                // 触觉反馈
                                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                impactMed.impactOccurred()
                                startNextLevel()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.right.circle.fill")
                                        .font(.headline)
                                    
                                    Text(LocalizedStringKey.nextLevel.localized)
                                        .font(.headline)
                                }
                                .foregroundColor(Color(red: 0.1, green: 0.3, blue: 0.7))
                                .padding(.vertical, 16)
                                .frame(width: 220)
                                .background(Color.white)
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 3)
                            }
                        } else if gameState == .failure {
                            Button(action: {
                                // 触觉反馈
                                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                impactMed.impactOccurred()
                                resetLevel()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.counterclockwise.circle.fill")
                                        .font(.headline)
                                    
                                    Text(LocalizedStringKey.tryAgain.localized)
                                        .font(.headline)
                                }
                                .foregroundColor(Color(red: 0.1, green: 0.3, blue: 0.7))
                                .padding(.vertical, 16)
                                .frame(width: 220)
                                .background(Color.white)
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 3)
                            }
                        } else {
                            // 占位视图保持高度一致
                            Color.clear
                                .frame(height: 50)
                        }
                    }
                    .padding(.bottom, 30)
                }
                .padding(.horizontal)
            }
            .onAppear {
                boardSize = min(geometry.size.width, geometry.size.height) - 120
                isAnimating = true
            }
            .onDisappear {
                timer?.invalidate()
            }
            .fullScreenCover(isPresented: $isShowingResult) {
                ChimpTestResultView(
                    maxLevel: maxLevel,
                    onDismiss: { dismiss() },
                    onRestart: {
                        resetGame()
                        gameState = .ready
                    }
                )
            }
        }
    }
    
    // 游戏准备视图
    private var readyView: some View {
        VStack(spacing: 25) {
            // 猩猩图标
            Image(systemName: "brain.head.profile")
                .font(.system(size: 70))
                .foregroundColor(.white)
                .padding(25)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
                .scaleEffect(isAnimating ? 1.1 : 0.9)
                .animation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )
            
            Text(LocalizedStringKey.chimpTest.localized)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.2), radius: 2, x: 1, y: 1)
                .multilineTextAlignment(.center)
            
            Text(LocalizedStringKey.clickSquaresInOrder.localized)
                .font(.headline)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(width: boardSize, height: boardSize)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.15))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    // 游戏面板
    private var gameBoard: some View {
        ZStack {
            // 方块背景
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.15))
                .frame(width: boardSize, height: boardSize)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            
            // 网格布局
            VStack(spacing: squareSpacing) {
                ForEach(Array(0..<gridSize), id: \.self) { row in
                    HStack(spacing: squareSpacing) {
                        ForEach(Array(0..<gridSize), id: \.self) { column in
                            let index = row * gridSize + column
                            
                            // 查找position对应这个位置的方块
                            if let square = squares.first(where: { $0.position == index }) {
                                numberSquareView(square: square)
                            } else {
                                // 空白占位符
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(width: squareSize, height: squareSize)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // 单个数字方块视图
    private func numberSquareView(square: NumberSquare) -> some View {
        Button(action: {
            if gameState == .playing {
                handleSquareTap(square)
            }
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(squareColor(for: square))
                    .frame(width: squareSize, height: squareSize)
                    .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: 2)
                
                if gameState == .memorizing || (gameState == .playing && square.isRevealed) || gameState == .success || gameState == .failure {
                    Text("\(square.number)")
                        .font(.system(size: squareSize / 2, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
                }
            }
        }
        .disabled(gameState != .playing || square.isRevealed)
        .scaleEffect(square.isRevealed && gameState == .playing ? 0.9 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: square.isRevealed)
    }
    
    // 方块颜色
    private func squareColor(for square: NumberSquare) -> Color {
        if square.isRevealed {
            return Color.green.opacity(0.8) // 已点击正确的方块显示绿色
        } else if gameState == .memorizing {
            return Color(red: 0.3, green: 0.5, blue: 0.9) // 记忆阶段使用蓝色
        } else {
            // 游戏阶段使用浅色，增加对比度
            return Color.white.opacity(0.7)
        }
    }
    
    // 彩色粒子颜色
    private func confettiColor(for index: Int) -> Color {
        let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]
        return colors[index % colors.count]
    }
    
    // 计算方块大小
    private var squareSize: CGFloat {
        let availableSpace = boardSize - (squareSpacing * CGFloat(gridSize - 1))
        return availableSpace / CGFloat(gridSize)
    }
    
    // MARK: - 游戏逻辑
    
    // 开始游戏
    private func startGame() {
        resetGame()
        setupLevel()
    }
    
    // 重置游戏
    private func resetGame() {
        currentLevel = 4
        strikes = 0
        maxLevel = 4
        gameState = .ready
        showSuccessConfetti = false
    }
    
    // 设置当前等级
    private func setupLevel() {
        // 重置方块数据
        squares = []
        showSuccessConfetti = false
        
        // 创建随机位置的数字方块
        var positions = generateRandomPositions(count: currentLevel)
        
        // 创建方块
        for i in 1...currentLevel {
            let position = positions.removeFirst()
            squares.append(NumberSquare(id: i, number: i, position: position))
        }
        
        nextNumber = 1
        
        // 开始记忆阶段
        gameState = .memorizing
        startMemorizingTimer()
    }
    
    // 生成随机位置
    private func generateRandomPositions(count: Int) -> [Int] {
        // 创建可能的所有位置
        var positions = Array(0..<(gridSize * gridSize))
        
        // 随机打乱
        positions.shuffle()
        
        // 返回需要的数量
        return Array(positions.prefix(count))
    }
    
    // 开始记忆计时器
    private func startMemorizingTimer() {
        memorizingTimeRemaining = 3
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if memorizingTimeRemaining > 0 {
                memorizingTimeRemaining -= 1
            } else {
                timer?.invalidate()
                // 记忆时间结束，开始游戏
                withAnimation {
                    gameState = .playing
                    
                    // 隐藏所有数字
                    for i in 0..<squares.count {
                        squares[i].isRevealed = false
                    }
                }
            }
        }
    }
    
    // 处理方块点击
    private func handleSquareTap(_ square: NumberSquare) {
        if square.number == nextNumber {
            // 正确点击
            squares[squares.firstIndex(where: { $0.id == square.id })!].isRevealed = true
            nextNumber += 1
            
            // 播放正确点击音效
            soundService.playSound(named: "boop")
            
            // 检查是否完成本轮
            if nextNumber > currentLevel {
                // 本轮完成
                withAnimation {
                    gameState = .success
                    
                    // 显示成功粒子效果
                    showSuccessConfetti = true
                    // 重新触发动画
                    isAnimating.toggle()
                    
                    // 成功振动反馈
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                }
                
                // 更新最高等级
                maxLevel = max(maxLevel, currentLevel)
            }
        } else {
            // 错误点击
            withAnimation {
                gameState = .failure
                strikes += 1
                
                // 显示所有数字
                for i in 0..<squares.count {
                    squares[i].isRevealed = true
                }
                
                // 错误振动反馈
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
            }
            
            // 检查游戏是否结束
            if strikes >= 3 {
                // 游戏结束
                endGame()
            }
        }
    }
    
    // 进入下一级
    private func startNextLevel() {
        currentLevel += 1
        setupLevel()
    }
    
    // 重置当前等级
    private func resetLevel() {
        setupLevel()
    }
    
    // 结束游戏
    private func endGame() {
        gameState = .finished
        
        // 保存最高成绩
        gameDataManager.saveResult(gameType: .chimpTest, score: Double(maxLevel))
        
        // 显示结果页面
        isShowingResult = true
    }
}

// 数字方块模型
struct NumberSquare: Identifiable {
    let id: Int
    let number: Int
    let position: Int
    var isRevealed = true
}

#Preview {
    ChimpTestGameView()
        .environmentObject(GameDataManager())
} 