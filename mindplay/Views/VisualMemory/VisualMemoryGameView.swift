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
    @State private var isAnimating = false // 添加动画控制状态
    @State private var showSuccessConfetti = false // 成功时显示彩色粒子
    
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
    
    // 视觉记忆的主题渐变色 - 紫色/靛蓝色
    private let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.4, green: 0.2, blue: 0.8),
            Color(red: 0.2, green: 0.3, blue: 0.7)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // 初始化方法
    init(gridSize: Int) {
        self.initialGridSize = gridSize
        // 使用_currentGridSize初始化状态属性
        _currentGridSize = State(initialValue: gridSize)
    }
    
    // 计算当前等级对应的网格大小
    private func gridSizeForLevel(_ level: Int) -> Int {
        // 第一关始终使用玩家选择的初始网格大小
        if level == 1 {
            return initialGridSize
        }
        
        // 后续关卡按照用户进度动态调整网格大小，但确保不小于初始选择的大小
        let baseSize = max(initialGridSize, 3) // 确保基础大小不小于初始选择
        
        if level <= 2 {
            return baseSize // 等级2使用基础大小
        } else if level <= 5 {
            return max(baseSize, 4) // 等级3-5至少使用4×4
        } else if level <= 9 {
            return max(baseSize, 5) // 等级6-9至少使用5×5
        } else if level <= 14 {
            return max(baseSize, 6) // 等级10-14至少使用6×6
        } else {
            return max(baseSize, 7) // 等级15+至少使用7×7
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 渐变背景
                backgroundGradient
                    .ignoresSafeArea()
                
                // 背景装饰元素
                ZStack {
                    // 添加一些装饰性方块，表示视觉记忆
                    ForEach(0..<6) { i in
                        let positions = [
                            CGPoint(x: geometry.size.width * 0.1, y: geometry.size.height * 0.2),
                            CGPoint(x: geometry.size.width * 0.85, y: geometry.size.height * 0.15),
                            CGPoint(x: geometry.size.width * 0.7, y: geometry.size.height * 0.85),
                            CGPoint(x: geometry.size.width * 0.25, y: geometry.size.height * 0.7),
                            CGPoint(x: geometry.size.width * 0.15, y: geometry.size.height * 0.5),
                            CGPoint(x: geometry.size.width * 0.75, y: geometry.size.height * 0.6)
                        ]
                        
                        let sizes: [CGFloat] = [60, 70, 65, 55, 50, 60]
                        let opacities: [Double] = [0.07, 0.05, 0.08, 0.06, 0.07, 0.05]
                        
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(opacities[i]))
                            .frame(width: sizes[i], height: sizes[i])
                            .position(positions[i])
                            .rotationEffect(.degrees(isAnimating ? Double(i * 8) : 0))
                            .animation(
                                Animation.easeInOut(duration: Double(i) + 4)
                                    .repeatForever(autoreverses: true),
                                value: isAnimating
                            )
                    }
                    
                    // 成功时的彩色粒子
                    if showSuccessConfetti {
                        ForEach(0..<15) { i in
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
                            VStack(spacing: 15) {
                                // 游戏状态提示放在容器上方
                                if gameState == .memorizing {
                                    Text(LocalizedStringKey.tilesFlashWhite.localized)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .fixedSize(horizontal: false, vertical: true) // 允许文本换行
                                        .frame(width: boardSize * 0.9, height: 60, alignment: .center) // 固定高度
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 16)
                                        .background(Color.white.opacity(0.2))
                                        .cornerRadius(10)
                                        .scaleEffect(isAnimating ? 1.05 : 1.0)
                                        .animation(
                                            Animation.easeInOut(duration: 0.5)
                                                .repeatForever(autoreverses: true),
                                            value: isAnimating
                                        )
                                } else if gameState == .playing {
                                    Text(LocalizedStringKey.memorizeAndPick.localized)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .fixedSize(horizontal: false, vertical: true) // 允许文本换行
                                        .frame(width: boardSize * 0.9, height: 60, alignment: .center) // 固定高度
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 16)
                                        .background(Color.white.opacity(0.2))
                                        .cornerRadius(10)
                                } else {
                                    // 占位视图，确保布局一致性
                                    Color.clear
                                        .frame(width: boardSize * 0.9, height: 60)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 16)
                                }
                                
                                // 游戏板
                                gameBoard
                                    .transition(.opacity)
                            }
                        } else {
                            // 占位视图保持大小一致
                            Color.clear
                                .frame(width: boardSize, height: boardSize)
                        }
                    }
                    .frame(width: boardSize, height: boardSize + 50) // 增加高度以容纳提示文本
                    
                    Spacer(minLength: 20)
                    
                    // 控制按钮区域 - 在所有状态下保持相同高度
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
                                .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.8))
                                .padding(.vertical, 16)
                                .frame(width: 200)
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
                            .transition(.opacity)
                        } else if gameState == .levelComplete {
                            Button(action: {
                                // 触觉反馈
                                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                impactMed.impactOccurred()
                                nextLevel()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.right.circle.fill")
                                        .font(.headline)
                                    
                                    Text(LocalizedStringKey.nextLevel.localized)
                                        .font(.headline)
                                }
                                .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.8))
                                .padding(.vertical, 16)
                                .frame(width: 200)
                                .background(Color.white)
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 3)
                            }
                            .transition(.opacity)
                        } else {
                            // 占位视图保持高度一致
                            Color.clear
                                .frame(height: 60)
                        }
                    }
                    .padding(.bottom, 20)
                }
                .padding()
                .onAppear {
                    boardSize = min(geometry.size.width, geometry.size.height) - 80 // 减小边距，使游戏板更大
                    isAnimating = true
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
            
            // 生命值
            VStack {
                Text(LocalizedStringKey.remainingLives.localized)
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
                
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Image(systemName: index < lives ? "heart.fill" : "heart")
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
    }
    
    // 游戏准备视图
    private var readyView: some View {
        VStack(spacing: 25) {
            // 视觉记忆图标
            Image(systemName: "square.on.square.fill")
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
            
            Text(LocalizedStringKey.visualMemoryTest.localized)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.2), radius: 2, x: 1, y: 1)
                .multilineTextAlignment(.center)
            
            Text(LocalizedStringKey.memorizeSquares.localized)
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
    
    // 游戏板
    private var gameBoard: some View {
        ZStack {
            // 方块背景
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.15))
                .frame(width: boardSize, height: boardSize)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            
            // 网格布局
            let tileSize = (boardSize - CGFloat(currentGridSize + 1) * tileSpacing) / CGFloat(currentGridSize)
            
            VStack(spacing: tileSpacing) {
                ForEach(0..<currentGridSize, id: \.self) { row in
                    HStack(spacing: tileSpacing) {
                        ForEach(0..<currentGridSize, id: \.self) { column in
                            let index = row * currentGridSize + column
                            
                            tileView(for: index, size: tileSize)
                                .onTapGesture {
                                    if gameState == .playing {
                                        handleTileTap(index: index)
                                    }
                                }
                        }
                    }
                }
            }
            .padding(tileSpacing)
        }
    }
    
    // 方块视图
    private func tileView(for index: Int, size: CGFloat) -> some View {
        let tile = tiles[index]
        return Button(action: {
            if gameState == .playing {
                handleTileTap(index: index)
            }
        }) {
            ZStack {
                Rectangle()
                    .fill(tileColor(for: tile))
                    .frame(width: size, height: size)
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
        if gameState == .memorizing && tile.isTarget && tile.isFlipped {
            return .white // 记忆阶段，目标方块显示为白色，但仅当它已被翻转
        } else if tile.isSelected {
            return tile.isTarget ? .white : Color(hex: "#214365") // 修改为白色(点对)和深蓝色(点错)
        } else {
            return Color(hex: "#3974bb") // 默认颜色修改为指定的蓝色
        }
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
        
        // 开始记忆阶段，但方块初始不翻转为白色
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
    
    // 生成随机目标方块索引，尽量让方块不相邻
    private func generateRandomTargets(count: Int) -> [Int] {
        let totalTiles = currentGridSize * currentGridSize
        
        // 如果需要的方块数超过可用空间的一半，直接随机
        if count > totalTiles / 2 {
            var positions = Array(0..<totalTiles)
            positions.shuffle()
            return Array(positions.prefix(count))
        }
        
        var availablePositions = Array(0..<totalTiles)
        var selectedPositions: [Int] = []
        
        // 选择第一个位置
        if !availablePositions.isEmpty {
            let randomIndex = Int.random(in: 0..<availablePositions.count)
            let firstPosition = availablePositions[randomIndex]
            selectedPositions.append(firstPosition)
            availablePositions.remove(at: randomIndex)
        }
        
        // 定义获取相邻位置的函数
        func getAdjacentPositions(for position: Int) -> [Int] {
            let row = position / currentGridSize
            let col = position % currentGridSize
            
            var adjacent: [Int] = []
            
            // 上
            if row > 0 {
                adjacent.append(position - currentGridSize)
            }
            // 下
            if row < currentGridSize - 1 {
                adjacent.append(position + currentGridSize)
            }
            // 左
            if col > 0 {
                adjacent.append(position - 1)
            }
            // 右
            if col < currentGridSize - 1 {
                adjacent.append(position + 1)
            }
            // 左上
            if row > 0 && col > 0 {
                adjacent.append(position - currentGridSize - 1)
            }
            // 右上
            if row > 0 && col < currentGridSize - 1 {
                adjacent.append(position - currentGridSize + 1)
            }
            // 左下
            if row < currentGridSize - 1 && col > 0 {
                adjacent.append(position + currentGridSize - 1)
            }
            // 右下
            if row < currentGridSize - 1 && col < currentGridSize - 1 {
                adjacent.append(position + currentGridSize + 1)
            }
            
            return adjacent
        }
        
        // 继续选择其余位置
        while selectedPositions.count < count && !availablePositions.isEmpty {
            // 获取所有已选位置的相邻位置
            var adjacentToSelected: Set<Int> = []
            for position in selectedPositions {
                let adjacent = getAdjacentPositions(for: position)
                adjacentToSelected.formUnion(adjacent)
            }
            
            // 计算非相邻的可用位置
            let nonAdjacentAvailable = availablePositions.filter { !adjacentToSelected.contains($0) }
            
            // 如果有非相邻位置可用，优先选择；否则从所有可用位置中选择
            let candidatePositions = nonAdjacentAvailable.isEmpty ? availablePositions : nonAdjacentAvailable
            let randomIndex = Int.random(in: 0..<candidatePositions.count)
            let nextPosition = candidatePositions[randomIndex]
            
            selectedPositions.append(nextPosition)
            if let indexToRemove = availablePositions.firstIndex(of: nextPosition) {
                availablePositions.remove(at: indexToRemove)
            }
        }
        
        return selectedPositions
    }
    
    // 开始记忆计时器 - 不再使用倒计时，改为固定延迟
    private func startMemorizingTimer() {
        // 取消之前的计时器
        timer?.invalidate()
        
        // 显示时间从3秒减少到2秒，给用户记忆时间
        timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { [self] _ in
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
                } else {
                    // 重新开始当前关卡
                    // 短暂延迟以便玩家看到错误反馈
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        // 重置当前关卡
                        self.setupLevel()
                    }
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
        // 继续游戏
        currentLevel += 1
        mistakes = 0
        setupLevel()
        
        // 显示庆祝粒子效果
        showSuccessConfetti = true
        // 重置动画状态触发粒子动画
        isAnimating.toggle()
        
        // 延迟后隐藏粒子
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showSuccessConfetti = false
        }
    }
    
    // 结束游戏
    private func endGame() {
        gameState = .gameOver
        
        // 保存最高成绩
        gameDataManager.saveResult(gameType: .visualMemory, score: Double(currentLevel))
        
        // 显示结果页面
        isShowingResult = true
    }
    
    // 彩色粒子颜色
    private func confettiColor(for index: Int) -> Color {
        let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]
        return colors[index % colors.count]
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