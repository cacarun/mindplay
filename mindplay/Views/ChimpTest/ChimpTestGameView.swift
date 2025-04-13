//
//  ChimpTestGameView.swift
//  mindplay
//
//  Created for MindPlay app.
//

import SwiftUI

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
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.purple
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    // 状态区域
                    statusView
                    
                    // 游戏面板
                    if gameState != .ready && gameState != .finished {
                        VStack(spacing: 20) {
                            // 记忆阶段倒计时 - 移到外部
                            if gameState == .memorizing {
                                Text("\(memorizingTimeRemaining)")
                                    .font(.system(size: 60, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(20)
                                    .background(Color.black.opacity(0.6))
                                    .cornerRadius(12)
                                    .padding(.bottom, 10)
                            }
                            
                            gameBoard
                                .padding()
                        }
                    } else if gameState == .ready {
                        readyView
                    }
                    
                    // 控制按钮
                    if gameState == .success {
                        Button(action: startNextLevel) {
                            Text(LocalizedStringKey.nextLevel.localized)
                                .font(.headline)
                                .foregroundColor(.purple)
                                .padding()
                                .frame(width: 200)
                                .background(Color.white)
                                .cornerRadius(12)
                        }
                        .padding(.top, 30)
                    } else if gameState == .failure {
                        Button(action: resetLevel) {
                            Text(LocalizedStringKey.tryAgain.localized)
                                .font(.headline)
                                .foregroundColor(.purple)
                                .padding()
                                .frame(width: 200)
                                .background(Color.white)
                                .cornerRadius(12)
                        }
                        .padding(.top, 30)
                    } else if gameState == .ready {
                        Button(action: startGame) {
                            Text(LocalizedStringKey.startTest.localized)
                                .font(.headline)
                                .foregroundColor(.purple)
                                .padding()
                                .frame(width: 200)
                                .background(Color.white)
                                .cornerRadius(12)
                        }
                        .padding(.top, 30)
                    }
                    
                    Spacer()
                }
                .padding()
                .onAppear {
                    boardSize = min(geometry.size.width, geometry.size.height) - 60
                }
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
    
    // 状态视图
    private var statusView: some View {
        HStack(spacing: 40) {
            // 等级
            VStack {
                Text(LocalizedStringKey.level.localized)
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                
                Text("\(currentLevel)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            // 失误
            VStack {
                Text(LocalizedStringKey.strikesRemaining.localized)
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                
                HStack(spacing: 5) {
                    ForEach(0..<3) { index in
                        Image(systemName: index < (3 - strikes) ? "heart.fill" : "heart")
                            .foregroundColor(.red)
                            .font(.title2)
                    }
                }
            }
        }
        .padding(.bottom)
    }
    
    // 游戏准备视图
    private var readyView: some View {
        VStack(spacing: 20) {
            Text(LocalizedStringKey.chimpTest.localized)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(LocalizedStringKey.smarterThanChimp.localized)
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            
            Text(LocalizedStringKey.clickSquaresInOrder.localized)
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
    }
    
    // 游戏面板
    private var gameBoard: some View {
        ZStack {
            // 方块背景
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(width: boardSize, height: boardSize)
                .cornerRadius(12)
            
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
                Rectangle()
                    .fill(squareColor(for: square))
                    .frame(width: squareSize, height: squareSize)
                    .cornerRadius(8)
                
                if gameState == .memorizing || (gameState == .playing && square.isRevealed) || gameState == .success || gameState == .failure {
                    Text("\(square.number)")
                        .font(.system(size: squareSize / 2, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
        .disabled(gameState != .playing || square.isRevealed)
    }
    
    // 方块颜色
    private func squareColor(for square: NumberSquare) -> Color {
        if square.isRevealed {
            return Color.green // 已点击正确的方块显示绿色
        } else if gameState == .memorizing {
            return Color.blue.opacity(0.9) // 记忆阶段使用深蓝色
        } else {
            // 游戏阶段使用灰白色，增加对比度
            return Color(white: 0.9)
        }
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
    }
    
    // 设置当前等级
    private func setupLevel() {
        // 重置方块数据
        squares = []
        
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
                gameState = .playing
                
                // 隐藏所有数字
                for i in 0..<squares.count {
                    squares[i].isRevealed = false
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
            
            // 检查是否完成本轮
            if nextNumber > currentLevel {
                // 本轮完成
                gameState = .success
                
                // 更新最高等级
                maxLevel = max(maxLevel, currentLevel)
            }
        } else {
            // 错误点击
            gameState = .failure
            strikes += 1
            
            // 显示所有数字
            for i in 0..<squares.count {
                squares[i].isRevealed = true
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