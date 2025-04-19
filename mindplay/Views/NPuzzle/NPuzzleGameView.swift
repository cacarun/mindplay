//
//  NPuzzleGameView.swift
//  mindplay
//
//  Created for MindPlay app.
//

import SwiftUI

// 游戏状态
enum NPuzzleGameState {
    case ready
    case playing
    case completed
}

// 拼图方块模型
struct PuzzleTile: Identifiable, Equatable {
    let id: Int // 方块编号，0表示空白方块
    var currentPosition: Int // 当前位置
    
    static func == (lhs: PuzzleTile, rhs: PuzzleTile) -> Bool {
        lhs.id == rhs.id && lhs.currentPosition == rhs.currentPosition
    }
}

struct NPuzzleGameView: View {
    @EnvironmentObject var gameDataManager: GameDataManager
    @Environment(\.dismiss) private var dismiss
    
    // 游戏配置
    let gridSize: Int
    
    // 游戏状态
    @State private var gameState: NPuzzleGameState = .ready
    @State private var tiles: [PuzzleTile] = []
    @State private var emptyTilePosition: Int = 0
    @State private var moveCount: Int = 0
    @State private var elapsedTime: Int = 0 // 秒
    @State private var showHint: Bool = false
    @State private var showResult: Bool = false
    @State private var isAnimating = false
    @State private var timer: Timer?
    
    // 背景渐变
    private let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.1, green: 0.6, blue: 0.7),
            Color(red: 0.2, green: 0.4, blue: 0.6)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        ZStack {
            // 渐变背景
            backgroundGradient
                .ignoresSafeArea()
            
            // 背景装饰元素
            GeometryReader { geometry in
                ForEach(0..<5) { index in
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.05 + Double(index) * 0.01))
                        .frame(width: CGFloat(60 + index * 10), height: CGFloat(60 + index * 10))
                        .position(
                            x: geometry.size.width * getRandomPosition(seed: index + 20),
                            y: geometry.size.height * getRandomPosition(seed: index + 30)
                        )
                        .rotationEffect(.degrees(isAnimating ? Double(index * 8) : 0))
                        .animation(
                            Animation.easeInOut(duration: Double(3 + index)).repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                }
            }
            
            VStack {
                // 状态栏
                HStack {
                    VStack(alignment: .leading) {
                        Text(LocalizedStringKey.timeUsed.localized)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text(formatTime(seconds: elapsedTime))
                            .font(.title3.bold())
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text(LocalizedStringKey.movesMade.localized)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text("\(moveCount)")
                            .font(.title3.bold())
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 10)
                
                Spacer()
                
                // 游戏主区域
                GeometryReader { geometry in
                    let availableWidth = max(10, min(geometry.size.width, geometry.size.height) - 40)
                    let tileSize = max(10, availableWidth / CGFloat(gridSize))
                    let boardSize = tileSize * CGFloat(gridSize)
                    
                    ZStack {
                        // 拼图网格
                        if gameState != .ready {
                            ZStack {
                                // 底板
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.1))
                                    .frame(width: boardSize, height: boardSize)
                                
                                // 方块
                                ForEach(tiles) { tile in
                                    if tile.id != 0 { // 不显示空白方块
                                        let row = tile.currentPosition / gridSize
                                        let col = tile.currentPosition % gridSize
                                        
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color.white.opacity(0.8),
                                                        Color.white.opacity(0.7)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: tileSize - 8, height: tileSize - 8)
                                            .shadow(color: Color.black.opacity(0.2), radius: 3, x: 1, y: 2)
                                            .overlay(
                                                Text("\(tile.id)")
                                                    .font(.system(size: tileSize / 2.5, weight: .bold))
                                                    .foregroundColor(Color(red: 0.1, green: 0.4, blue: 0.6))
                                            )
                                            .position(
                                                x: CGFloat(col) * tileSize + tileSize / 2 + (geometry.size.width - boardSize) / 2,
                                                y: CGFloat(row) * tileSize + tileSize / 2 + (geometry.size.height - boardSize) / 2
                                            )
                                            .onTapGesture {
                                                moveTile(at: tile.currentPosition)
                                            }
                                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: tile.currentPosition)
                                    }
                                }
                                
                                // 提示完成图
                                if showHint {
                                    ForEach(Array(1..<gridSize*gridSize), id: \.self) { id in
                                        let targetPosition = id - 1 // 目标位置
                                        let row = targetPosition / gridSize
                                        let col = targetPosition % gridSize
                                        
                                        Text("\(id)")
                                            .font(.system(size: tileSize / 4, weight: .light))
                                            .foregroundColor(.white.opacity(0.5))
                                            .position(
                                                x: CGFloat(col) * tileSize + tileSize / 2 + (geometry.size.width - boardSize) / 2,
                                                y: CGFloat(row) * tileSize + tileSize / 2 + (geometry.size.height - boardSize) / 2
                                            )
                                    }
                                }
                            }
                        } else {
                            // 开始游戏提示
                            VStack {
                                Text(LocalizedStringKey.tapToStart.localized)
                                    .font(.title.bold())
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.2), radius: 2, x: 1, y: 1)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.white.opacity(0.15))
                                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                                    )
                                    .scaleEffect(isAnimating ? 1.05 : 1.0)
                                    .animation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: isAnimating)
                                    .onTapGesture {
                                        startGame()
                                    }
                            }
                            .frame(width: boardSize, height: boardSize)
                            .position(
                                x: geometry.size.width / 2,
                                y: geometry.size.height / 2
                            )
                        }
                        
                        // 胜利提示
                        if gameState == .completed {
                            VStack {
                                Text(LocalizedStringKey.puzzleCompleted.localized)
                                    .font(.title2.bold())
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.green.opacity(0.3))
                                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                                    )
                                    .padding(.bottom, 20)
                                
                                Button(action: {
                                    showResult = true
                                }) {
                                    Text(LocalizedStringKey.seeResults.localized)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(Color.white.opacity(0.3))
                                                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                                        )
                                }
                            }
                            .transition(.scale.combined(with: .opacity))
                            .frame(width: boardSize, height: boardSize)
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(10)
                            .position(
                                x: geometry.size.width / 2,
                                y: geometry.size.height / 2
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if gameState == .ready {
                            startGame()
                        }
                    }
                }
                
                Spacer()
                
                // 控制按钮
                if gameState == .playing {
                    HStack(spacing: 30) {
                        Button(action: {
                            resetGame(shuffle: true)
                        }) {
                            VStack {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 24))
                                
                                Text(LocalizedStringKey.resetPuzzle.localized)
                                    .font(.caption)
                            }
                            .foregroundColor(.white)
                            .frame(width: 80, height: 60)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(15)
                        }
                        
                        Button(action: {
                            // 显示提示5秒钟
                            showHint = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                showHint = false
                            }
                        }) {
                            VStack {
                                Image(systemName: "lightbulb")
                                    .font(.system(size: 24))
                                
                                Text(LocalizedStringKey.showHint.localized)
                                    .font(.caption)
                            }
                            .foregroundColor(.white)
                            .frame(width: 80, height: 60)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(15)
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarBackButtonHidden(gameState == .completed)
        .onAppear {
            isAnimating = true
            setupTiles()
        }
        .onDisappear {
            stopTimer()
        }
        .fullScreenCover(isPresented: $showResult) {
            NPuzzleResultView(
                timeTaken: elapsedTime,
                moveCount: moveCount,
                gridSize: gridSize,
                onDismiss: {
                    dismiss()
                },
                onRestart: { _ in
                    showResult = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        resetGame(shuffle: true)
                        gameState = .ready
                    }
                }
            )
            .environmentObject(gameDataManager)
        }
    }
    
    // 开始游戏
    private func startGame() {
        gameState = .playing
        resetGame(shuffle: true)
        startTimer()
    }
    
    // 重置游戏
    private func resetGame(shuffle: Bool) {
        setupTiles() // 重置所有方块到初始状态
        
        if shuffle {
            shuffleTiles()
            
            // 额外验证，确保没有方块重叠
            validateAndCorrectTilePositions()
        }
        
        moveCount = 0
        if gameState == .playing {
            elapsedTime = 0
            startTimer()
        }
    }
    
    // 设置拼图方块
    private func setupTiles() {
        let totalTiles = gridSize * gridSize
        tiles = []
        
        // 创建方块
        for id in 0..<totalTiles {
            let tile = PuzzleTile(id: id, currentPosition: id)
            tiles.append(tile)
        }
        
        // 设置空白方块位置
        emptyTilePosition = totalTiles - 1
    }
    
    // 洗牌算法 - 确保拼图有解
    private func shuffleTiles() {
        let totalTiles = gridSize * gridSize
        
        // 首先确保所有方块在初始有序位置
        setupTiles()
        
        // 空白方块初始位置（右下角）
        var currentEmptyPos = totalTiles - 1
        
        // 移动次数应根据网格大小调整，确保充分打乱
        let moves = gridSize * gridSize * 20
        
        for _ in 0..<moves {
            // 获取空白位置的相邻位置
            let adjacentPositions = getAdjacentPositions(for: currentEmptyPos)
            
            if let randomPos = adjacentPositions.randomElement() {
                // 找到在randomPos位置的方块索引
                if let tileToMoveIndex = tiles.firstIndex(where: { $0.currentPosition == randomPos }),
                   let emptyTileIndex = tiles.firstIndex(where: { $0.id == 0 }) {
                    
                    // 直接交换位置
                    tiles[tileToMoveIndex].currentPosition = currentEmptyPos
                    tiles[emptyTileIndex].currentPosition = randomPos
                    currentEmptyPos = randomPos
                }
            }
        }
        
        // 更新空白方块位置
        emptyTilePosition = currentEmptyPos
        
        // 验证棋盘可解性（调试模式下使用）
        #if DEBUG
        if !isPuzzleSolvable() {
            print("警告：生成的拼图不可解，重新洗牌")
            shuffleTiles() // 如果不可解则重新洗牌
        }
        #endif
    }
    
    // 计算当前棋盘的逆序数，验证棋盘可解性
    private func isPuzzleSolvable() -> Bool {
        // 创建一个不包含空白方块的数组，用于计算逆序数
        var numbers: [Int] = []
        var emptyRow = 0
        
        // 首先按当前位置排序所有方块
        let sortedTiles = tiles.sorted { $0.currentPosition < $1.currentPosition }
        
        // 收集非空白方块的ID，并记录空白方块所在行
        for tile in sortedTiles {
            if tile.id != 0 {
                numbers.append(tile.id)
            } else {
                // 计算空白方块所在行（从0开始）
                emptyRow = tile.currentPosition / gridSize
            }
        }
        
        // 计算逆序数
        var inversions = 0
        for i in 0..<numbers.count {
            for j in i+1..<numbers.count {
                if numbers[i] > numbers[j] {
                    inversions += 1
                }
            }
        }
        
        // 根据网格大小和逆序数判断可解性
        if gridSize % 2 == 1 {
            // 奇数阶棋盘（3×3，5×5等）：逆序数必须为偶数
            return inversions % 2 == 0
        } else {
            // 偶数阶棋盘（4×4等）：逆序数加上空白方块所在行（从底部数）必须为偶数
            let emptyRowFromBottom = gridSize - 1 - emptyRow
            return (inversions + emptyRowFromBottom) % 2 == 0
        }
    }
    
    // 验证并修正方块位置
    private func validateAndCorrectTilePositions() {
        let totalTiles = gridSize * gridSize
        var positionSet = Set<Int>()
        var duplicateFound = false
        
        // 检查是否有重复位置
        for tile in tiles {
            if positionSet.contains(tile.currentPosition) {
                duplicateFound = true
                break
            }
            positionSet.insert(tile.currentPosition)
        }
        
        // 如果发现重复或缺失位置，重新分配位置
        if duplicateFound || positionSet.count != totalTiles {
            print("检测到方块位置异常，重新分配位置...")
            
            // 创建可用位置列表
            var availablePositions = Array(0..<totalTiles)
            
            // 先处理空白方块，确保它在最后一个位置
            if let emptyTileIndex = tiles.firstIndex(where: { $0.id == 0 }) {
                tiles[emptyTileIndex].currentPosition = totalTiles - 1
                if let index = availablePositions.firstIndex(of: totalTiles - 1) {
                    availablePositions.remove(at: index)
                }
            }
            
            // 为其他方块分配位置
            for (index, tile) in tiles.enumerated() where tile.id != 0 {
                if !availablePositions.isEmpty {
                    let randomIndex = Int.random(in: 0..<availablePositions.count)
                    tiles[index].currentPosition = availablePositions[randomIndex]
                    availablePositions.remove(at: randomIndex)
                }
            }
            
            // 更新空白方块位置
            emptyTilePosition = totalTiles - 1
        }
    }
    
    // 获取相邻位置
    private func getAdjacentPositions(for position: Int) -> [Int] {
        let row = position / gridSize
        let col = position % gridSize
        var adjacent: [Int] = []
        
        // 上方位置
        if row > 0 {
            adjacent.append(position - gridSize)
        }
        
        // 下方位置
        if row < gridSize - 1 {
            adjacent.append(position + gridSize)
        }
        
        // 左侧位置
        if col > 0 {
            adjacent.append(position - 1)
        }
        
        // 右侧位置
        if col < gridSize - 1 {
            adjacent.append(position + 1)
        }
        
        return adjacent
    }
    
    // 移动方块
    private func moveTile(at position: Int) {
        guard gameState == .playing, isAdjacent(position, to: emptyTilePosition) else { return }
        
        // 找到被点击的方块和空白方块的索引
        if let tileToMoveIndex = tiles.firstIndex(where: { $0.currentPosition == position }),
           let emptyTileIndex = tiles.firstIndex(where: { $0.id == 0 }) {
            
            // 直接交换位置
            tiles[tileToMoveIndex].currentPosition = emptyTilePosition
            tiles[emptyTileIndex].currentPosition = position
            
            // 更新空白方块位置和移动次数
            emptyTilePosition = position
            moveCount += 1
            
            // 触觉反馈
            let feedback = UIImpactFeedbackGenerator(style: .light)
            feedback.impactOccurred()
            
            // 检查是否完成
            checkCompletion()
            
            // 验证方块位置（调试用，可以在发布版本中移除）
            #if DEBUG
            validateAndCorrectTilePositions()
            #endif
        }
    }
    
    // 检查是否相邻
    private func isAdjacent(_ pos1: Int, to pos2: Int) -> Bool {
        let row1 = pos1 / gridSize
        let col1 = pos1 % gridSize
        let row2 = pos2 / gridSize
        let col2 = pos2 % gridSize
        
        // 在同一行且列相差1，或在同一列且行相差1
        return (row1 == row2 && abs(col1 - col2) == 1) || (col1 == col2 && abs(row1 - row2) == 1)
    }
    
    // 检查游戏是否完成
    private func checkCompletion() {
        // 首先验证没有重复位置
        let totalTiles = gridSize * gridSize
        var positionSet = Set<Int>()
        for tile in tiles {
            positionSet.insert(tile.currentPosition)
        }
        
        // 如果有重复位置，无法完成游戏
        if positionSet.count != totalTiles {
            return
        }
        
        // 如果最后一个位置不是空白方块，则未完成
        if tiles.first(where: { $0.id == 0 })?.currentPosition != gridSize * gridSize - 1 {
            return
        }
        
        // 检查所有其他方块是否在正确位置
        for tile in tiles where tile.id != 0 {
            if tile.currentPosition != tile.id - 1 {
                return
            }
        }
        
        // 游戏完成
        gameState = .completed
        stopTimer()
        
        // 触觉反馈
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.success)
        
        // 保存成绩
        gameDataManager.saveResult(gameType: .nPuzzle, score: Double(elapsedTime), extraData: String(gridSize))
    }
    
    // 开始计时器
    private func startTimer() {
        stopTimer()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.elapsedTime += 1
        }
    }
    
    // 停止计时器
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // 格式化时间
    private func formatTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
    // 根据种子生成随机位置 (0.1-0.9范围内)
    private func getRandomPosition(seed: Int) -> Double {
        let random = Double(((seed * 1234321) % 80) + 10) / 100.0
        return random
    }
}

#Preview {
    NavigationStack {
        NPuzzleGameView(gridSize: 3)
            .environmentObject(GameDataManager())
    }
} 