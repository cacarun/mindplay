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
    let initialGridSize: Int // 初始网格大小
    
    // 游戏状态
    @State private var gameState: VisualMemoryGameState = .ready
    @State private var currentLevel = 1
    @State private var lives = 3
    @State private var mistakes = 0 // 当前级别的错误次数
    @State private var isShowingResult = false
    @State private var currentGridSize: Int // 当前网格大小（随等级变化）
    
    // 方块状态
    @State private var tiles: [MemoryTile] = []
    @State private var targetTiles: [Int] = [] // 需要记忆的方块索引
    @State private var selectedTiles: [Int] = [] // 用户已选择的方块索引
    
    // 布局相关
    @State private var boardSize: CGFloat = 300.0
    private let tileSpacing: CGFloat = 10.0
    
    // 动画与计时器
    @State private var timer: Timer?
    
    // 音效服务
    private let soundService = SoundService.shared
    
    // 初始化方法
    init(gridSize: Int) {
        self.initialGridSize = gridSize
        // 使用_currentGridSize初始化状态属性
        _currentGridSize = State(initialValue: gridSize)
    }
    
    // 计算当前等级对应的网格大小
    private func gridSizeForLevel(_ level: Int) -> Int {
        // 按照用户进度动态调整网格大小
        if level <= 2 {
            return 3 // 等级1-2使用3×3
        } else if level <= 5 {
            return 4 // 等级3-5使用4×4
        } else if level <= 9 {
            return 5 // 等级6-9使用5×5
        } else if level <= 14 {
            return 6 // 等级10-14使用6×6
        } else {
            return 7 // 等级15+使用7×7
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(hex: "#2b87d1") // 更新背景色
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // 状态区域 - 在所有状态下都显示
                    VStack {
                        if gameState != .ready {
                            statusView
                                .padding(.top, 10)
                                .transition(.opacity)
                        } else {
                            // 占位视图，保持布局一致性
                            Color.clear
                                .frame(height: 60)
                        }
                    }
                    
                    Spacer(minLength: 20)
                    
                    // 游戏区域 - 中心区域
                    ZStack {
                        if gameState == .ready {
                            readyView
                                .frame(width: boardSize, height: boardSize)
                                .transition(.opacity)
                        } else if gameState != .gameOver {
                            gameBoard
                                .transition(.opacity)
                        } else {
                            // 占位视图保持大小一致
                            Color.clear
                                .frame(width: boardSize, height: boardSize)
                        }
                    }
                    .frame(width: boardSize, height: boardSize)
                    
                    Spacer(minLength: 20)
                    
                    // 控制按钮区域 - 在所有状态下保持相同高度
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
                            .transition(.opacity)
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
                            .transition(.opacity)
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
                    boardSize = min(geometry.size.width, geometry.size.height) - 120
                }
                .animation(.easeInOut(duration: 0.3), value: gameState)
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
                    .foregroundColor(.white)
                
                Text("\(currentLevel)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            // 生命值
            VStack {
                Text(LocalizedStringKey.remainingLives.localized)
                    .font(.headline)
                    .foregroundColor(.white)
                
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
            // 游戏标题和说明
            VStack(spacing: 16) {
                Text(LocalizedStringKey.visualMemoryTest.localized)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(LocalizedStringKey.memorizeSquares.localized)
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(LocalizedStringKey.tilesFlashWhite.localized)
                    .font(.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            
            Spacer(minLength: 20)
            
            // 等级和生命值
            HStack(spacing: 40) {
                // 等级
                VStack {
                    Text(LocalizedStringKey.level.localized)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("\(currentLevel)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                // 生命值
                VStack {
                    Text(LocalizedStringKey.remainingLives.localized)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 5) {
                        ForEach(0..<3) { index in
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                                .font(.title2)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(hex: "#3974bb"))  // 去掉透明度设置
        .cornerRadius(16)
    }
    
    // 游戏板视图
    private var gameBoard: some View {
        ZStack {
            // 板背景
            Rectangle()
                .fill(Color(hex: "#2b87d1"))  // 使用与背景色相同的颜色，不透明
                .frame(width: boardSize, height: boardSize)
                .cornerRadius(12)
            
            // 网格布局
            VStack(spacing: tileSpacing) {
                ForEach(0..<currentGridSize, id: \.self) { row in
                    HStack(spacing: tileSpacing) {
                        ForEach(0..<currentGridSize, id: \.self) { column in
                            let index = row * currentGridSize + column
                            
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
            .modifier(ShakeEffect(animatableData: tiles[index].shakeFactor))
        }
        .disabled(gameState != .playing || tile.isSelected)
    }
    
    // 方块颜色
    private func tileColor(for tile: MemoryTile) -> Color {
        if gameState == .memorizing && tile.isTarget {
            return .white // 记忆阶段，目标方块显示为白色
        } else if tile.isSelected {
            return tile.isTarget ? .white : Color(hex: "#214365") // 修改为白色(点对)和深蓝色(点错)
        } else {
            return Color(hex: "#3974bb") // 默认颜色修改为指定的蓝色
        }
    }
    
    // 计算方块大小
    private var tileSize: CGFloat {
        let availableSpace = boardSize - (tileSpacing * CGFloat(currentGridSize - 1))
        return availableSpace / CGFloat(currentGridSize)
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
        currentGridSize = initialGridSize
        gameState = .ready
    }
    
    // 设置当前级别
    private func setupLevel() {
        // 重置错误计数和已选择的方块
        mistakes = 0
        selectedTiles = []
        
        // 更新当前等级的网格大小
        currentGridSize = gridSizeForLevel(currentLevel)
        
        // 创建网格
        setupGrid()
        
        // 开始记忆阶段
        gameState = .memorizing
        
        // 短暂延迟后再显示方块，让用户做好准备
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // 播放翻转显示音效
            soundService.playSound(named: "reveal")
            
            // 翻转目标方块以显示
            withAnimation(.easeInOut(duration: 0.5)) {
                for index in self.targetTiles {
                    self.tiles[index].isFlipped = true
                }
            }
            
            // 启动计时器，延长显示时间
            self.startMemorizingTimer()
        }
    }
    
    // 设置网格和目标方块
    private func setupGrid() {
        // 清空现有方块
        tiles = []
        targetTiles = []
        
        // 创建所有方块
        for i in 0..<(currentGridSize * currentGridSize) {
            tiles.append(MemoryTile(id: i))
        }
        
        // 确定当前级别的目标方块数量
        let targetCount = min(currentLevel + 2, currentGridSize * currentGridSize - 1)
        
        // 随机选择目标方块
        targetTiles = generateRandomTargets(count: targetCount)
        
        // 标记目标方块
        for index in targetTiles {
            tiles[index].isTarget = true
        }
    }
    
    // 生成随机目标方块索引
    private func generateRandomTargets(count: Int) -> [Int] {
        var positions = Array(0..<(currentGridSize * currentGridSize))
        positions.shuffle()
        return Array(positions.prefix(count))
    }
    
    // 开始记忆计时器 - 不再使用倒计时，改为固定延迟
    private func startMemorizingTimer() {
        // 取消之前的计时器
        timer?.invalidate()
        
        // 延长显示时间到3秒，让用户有足够时间记忆
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [self] _ in
            // 播放翻转回原始状态音效
            soundService.playSound(named: "go")
            
            // 翻转回所有方块，隐藏目标
            withAnimation(.easeInOut(duration: 0.5)) {
                for index in 0..<self.tiles.count {
                    self.tiles[index].isFlipped = false
                }
            }
            
            // 短暂延迟后开始游戏，让动画完成
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                // 记忆时间结束，开始游戏
                self.gameState = .playing
            }
        }
    }
    
    // 处理方块点击
    private func handleTileTap(index: Int) {
        let tile = tiles[index]
        
        // 标记为已选择
        tiles[index].isSelected = true
        selectedTiles.append(index)
        
        // 检查是否正确
        if tile.isTarget {
            // 正确点击目标方块
            // 播放正确音效
            soundService.playSound(named: "boop", volume: 1.0)
            
            // 翻转方块以显示状态
            withAnimation(.easeInOut(duration: 0.3)) {
                tiles[index].isFlipped = true
            }
        } else {
            // 错误点击非目标方块
            // 播放错误音效 - 使用boop但音量降低
            soundService.playSound(named: "boop", volume: 0.3)
            
            // 添加抖动效果而不是翻转
            withAnimation(.easeInOut(duration: 0.3)) {
                tiles[index].shakeFactor += 1
            }
            
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
    var shakeFactor: CGFloat = 0 // 添加抖动因子
}

// 添加Color扩展，支持十六进制颜色值
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// 添加抖动效果修饰符
struct ShakeEffect: GeometryEffect {
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        guard animatableData > 0 else { return ProjectionTransform(.identity) }
        
        let intensity: CGFloat = 6
        let translation = intensity * sin(animatableData * .pi * 8)
        
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}

#Preview {
    VisualMemoryGameView(gridSize: 3)
        .environmentObject(GameDataManager())
} 