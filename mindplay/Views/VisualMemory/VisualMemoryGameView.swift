//
//  VisualMemoryGameView.swift
//  mindplay
//
//  Created for MindPlay app.
//

import SwiftUI
import AVFoundation

enum VisualMemoryGameState {
    case ready       // 准备开始
    case memorizing  // 记忆阶段 - 显示方块
    case playing     // 玩家选择阶段
    case levelComplete // 完成当前级别
    case gameOver    // 游戏结束
}

struct VisualMemoryGameView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var gameDataManager: GameDataManager
    
    // 游戏参数
    let gridSize: Int
    
    // 游戏状态
    @State private var gameState: VisualMemoryGameState = .ready
    @State private var currentLevel = 1
    @State private var lives = 3
    @State private var mistakes = 0 // 当前级别的错误次数
    @State private var isShowingResult = false
    
    // 方块状态
    @State private var tiles: [MemoryTile] = []
    @State private var targetTiles: [Int] = [] // 需要记忆的方块索引
    @State private var selectedTiles: [Int] = [] // 用户已选择的方块索引
    
    // 布局相关
    @State private var boardSize: CGFloat = 300.0
    private let tileSpacing: CGFloat = 10.0
    
    // 动画与计时器
    @State private var memorizingTimeRemaining: Int = 3
    @State private var timer: Timer?
    
    // 音效服务
    private let soundService = SoundService.shared
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.blue
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // 状态区域
                    VStack {
                        statusView
                            .padding(.top, 10)
                        
                        // 记忆阶段倒计时
                        if gameState == .memorizing {
                            Text("\(memorizingTimeRemaining)")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color.black.opacity(0.4))
                                .cornerRadius(10)
                                .transition(.scale)
                        } else {
                            // 占位视图保持高度一致
                            Color.clear
                                .frame(height: 46)
                        }
                    }
                    
                    // 游戏区域
                    ZStack {
                        if gameState != .ready && gameState != .gameOver {
                            gameBoard
                        } else if gameState == .ready {
                            readyView
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
                            Button(action: startGame) {
                                Text(LocalizedStringKey.startTest.localized)
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                    .padding()
                                    .frame(width: 200)
                                    .background(Color.white)
                                    .cornerRadius(12)
                            }
                        } else if gameState == .levelComplete {
                            Button(action: nextLevel) {
                                Text(LocalizedStringKey.nextLevel.localized)
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                    .padding()
                                    .frame(width: 200)
                                    .background(Color.white)
                                    .cornerRadius(12)
                            }
                        } else {
                            // 占位视图保持高度一致
                            Color.clear
                                .frame(height: 44)
                        }
                    }
                    .frame(height: 60)
                    .padding(.bottom, 20)
                }
                .padding()
                .onAppear {
                    boardSize = min(geometry.size.width, geometry.size.height) - 100
                }
            }
            .onDisappear {
                timer?.invalidate()
            }
            .fullScreenCover(isPresented: $isShowingResult) {
                VisualMemoryResultView(
                    level: currentLevel,
                    onDismiss: { dismiss() },
                    onRestart: { size in
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
        .padding(.bottom)
    }
    
    // 游戏准备视图
    private var readyView: some View {
        VStack(spacing: 20) {
            Text(LocalizedStringKey.visualMemoryTest.localized)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(LocalizedStringKey.memorizeSquares.localized)
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            
            Text(LocalizedStringKey.tilesFlashWhite.localized)
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
    }
    
    // 游戏板视图
    private var gameBoard: some View {
        ZStack {
            // 板背景
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(width: boardSize, height: boardSize)
                .cornerRadius(12)
            
            // 网格布局
            VStack(spacing: tileSpacing) {
                ForEach(0..<gridSize, id: \.self) { row in
                    HStack(spacing: tileSpacing) {
                        ForEach(0..<gridSize, id: \.self) { column in
                            let index = row * gridSize + column
                            
                            if index < tiles.count {
                                memoryTileView(tile: tiles[index], index: index)
                            } else {
                                // 占位符
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(width: tileSize, height: tileSize)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // 方块视图
    private func memoryTileView(tile: MemoryTile, index: Int) -> some View {
        Button(action: {
            if gameState == .playing {
                handleTileTap(index: index)
            }
        }) {
            ZStack {
                Rectangle()
                    .fill(tileColor(for: tile))
                    .frame(width: tileSize, height: tileSize)
                    .cornerRadius(8)
            }
            .rotation3DEffect(
                .degrees(tiles[index].isFlipped ? 180 : 0),
                axis: (x: 1.0, y: 0.0, z: 0.0),
                anchor: .center,
                perspective: 0.3
            )
        }
        .disabled(gameState != .playing || tile.isSelected)
    }
    
    // 方块颜色
    private func tileColor(for tile: MemoryTile) -> Color {
        if gameState == .memorizing && tile.isTarget {
            return .white // 记忆阶段，目标方块显示为白色
        } else if tile.isSelected {
            return tile.isTarget ? .green : .red // 已选择正确为绿色，错误为红色
        } else {
            return Color.gray.opacity(0.8) // 默认颜色
        }
    }
    
    // 计算方块大小
    private var tileSize: CGFloat {
        let availableSpace = boardSize - (tileSpacing * CGFloat(gridSize - 1))
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
        currentLevel = 1
        lives = 3
        gameState = .ready
    }
    
    // 设置当前级别
    private func setupLevel() {
        // 重置错误计数和已选择的方块
        mistakes = 0
        selectedTiles = []
        
        // 创建网格
        setupGrid()
        
        // 开始记忆阶段
        gameState = .memorizing
        
        // 播放翻转显示音效
        soundService.playSound(named: "reveal")
        
        // 翻转目标方块以显示
        withAnimation(.easeInOut(duration: 0.5)) {
            for index in targetTiles {
                tiles[index].isFlipped = true
            }
        }
        
        startMemorizingTimer()
    }
    
    // 设置网格和目标方块
    private func setupGrid() {
        // 清空现有方块
        tiles = []
        targetTiles = []
        
        // 创建所有方块
        for i in 0..<(gridSize * gridSize) {
            tiles.append(MemoryTile(id: i))
        }
        
        // 确定当前级别的目标方块数量
        let targetCount = min(currentLevel + 2, gridSize * gridSize - 1)
        
        // 随机选择目标方块
        targetTiles = generateRandomTargets(count: targetCount)
        
        // 标记目标方块
        for index in targetTiles {
            tiles[index].isTarget = true
        }
    }
    
    // 生成随机目标方块索引
    private func generateRandomTargets(count: Int) -> [Int] {
        var positions = Array(0..<(gridSize * gridSize))
        positions.shuffle()
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
                
                // 播放翻转回原始状态音效
                soundService.playSound(named: "go")
                
                // 翻转回所有方块，隐藏目标
                withAnimation(.easeInOut(duration: 0.5)) {
                    for index in 0..<tiles.count {
                        tiles[index].isFlipped = false
                    }
                }
                
                // 短暂延迟后开始游戏，让动画完成
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    // 记忆时间结束，开始游戏
                    gameState = .playing
                }
            }
        }
    }
    
    // 处理方块点击
    private func handleTileTap(index: Int) {
        let tile = tiles[index]
        
        // 标记为已选择
        tiles[index].isSelected = true
        selectedTiles.append(index)
        
        // 播放翻转显示音效
        soundService.playSound(named: "reveal")
        
        // 翻转方块以显示状态
        withAnimation(.easeInOut(duration: 0.3)) {
            tiles[index].isFlipped = true
        }
        
        // 检查是否正确
        if tile.isTarget {
            // 正确点击目标方块
        } else {
            // 错误点击非目标方块
            mistakes += 1
            
            // 如果在一个级别中错误达到3次，失去一条命
            if mistakes >= 3 {
                lives -= 1
                mistakes = 0
                
                // 检查游戏是否结束
                if lives <= 0 {
                    endGame()
                    return
                }
            }
        }
        
        // 检查是否完成当前级别
        checkLevelCompletion()
    }
    
    // 检查是否完成当前级别
    private func checkLevelCompletion() {
        // 计算还有多少目标方块未被选择
        let remainingTargets = targetTiles.filter { !selectedTiles.contains($0) }.count
        
        // 计算非目标方块中还有多少未被选择
        let availableNonTargets = tiles.indices.filter { !targetTiles.contains($0) && !selectedTiles.contains($0) }.count
        
        // 如果没有目标方块未被选择，或者剩余的错误机会不足以继续游戏
        if remainingTargets == 0 || (availableNonTargets < 3 - mistakes && remainingTargets > 0) {
            // 完成当前级别
            gameState = .levelComplete
        }
    }
    
    // 进入下一级
    private func nextLevel() {
        currentLevel += 1
        setupLevel()
    }
    
    // 结束游戏
    private func endGame() {
        gameState = .gameOver
        
        // 保存最高成绩
        gameDataManager.saveResult(gameType: .visualMemory, score: Double(currentLevel))
        
        // 显示结果页面
        isShowingResult = true
    }
}

// 内存方块模型
struct MemoryTile: Identifiable {
    let id: Int
    var isTarget = false
    var isSelected = false
    var isFlipped = false // 添加翻转状态
}

#Preview {
    VisualMemoryGameView(gridSize: 3)
        .environmentObject(GameDataManager())
} 