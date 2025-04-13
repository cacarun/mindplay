//
//  SchulteTableGameView.swift
//  mindplay
//
//  Created for MindPlay app.
//

import SwiftUI

enum SchulteTableGameState {
    case ready       // 准备开始
    case playing     // 游戏进行中
    case finished    // 游戏结束
}

struct SchulteTableGameView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var gameDataManager: GameDataManager
    
    // 游戏参数
    let tableSize: Int
    
    // 游戏状态
    @State private var gameState: SchulteTableGameState = .ready
    @State private var currentNumber = 1
    @State private var totalNumbers: Int = 0
    @State private var isShowingResult = false
    @State private var numbers: [[Int]] = []
    
    // 时间相关
    @State private var startTime: Date? = nil
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer? = nil
    
    // 布局相关
    @State private var boardSize: CGFloat = 300.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.blue
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // 状态区域
                    HStack {
                        Spacer()
                        
                        VStack {
                            Text(LocalizedStringKey.findingNumber.localized(with: currentNumber))
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            if gameState == .playing {
                                Text(String(format: "%.1f s", elapsedTime))
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.top, 20)
                    
                    // 游戏区域
                    ZStack {
                        if gameState == .ready {
                            readyView
                        } else {
                            gameBoard
                        }
                    }
                    .frame(width: boardSize, height: boardSize)
                    
                    Spacer()
                    
                    // 控制按钮区域
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
                        .padding(.bottom, 20)
                    }
                }
                .padding()
                .onAppear {
                    boardSize = min(geometry.size.width, geometry.size.height) - 100
                    totalNumbers = tableSize * tableSize
                    setupGame()
                }
            }
            .onDisappear {
                timer?.invalidate()
            }
            .fullScreenCover(isPresented: $isShowingResult) {
                SchulteTableResultView(
                    completionTime: elapsedTime,
                    tableSize: tableSize,
                    onDismiss: { dismiss() },
                    onRestart: { _ in
                        resetGame()
                        gameState = .ready
                    }
                )
            }
        }
    }
    
    // 游戏准备视图
    private var readyView: some View {
        VStack(spacing: 20) {
            Text(LocalizedStringKey.schulteTableTest.localized)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(LocalizedStringKey.findNumbers.localized)
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            
            Text(LocalizedStringKey.usePeripheralVision.localized)
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
    }
    
    // 游戏板视图
    private var gameBoard: some View {
        VStack(spacing: 0) {
            ForEach(0..<tableSize, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<tableSize, id: \.self) { column in
                        if row < numbers.count && column < numbers[row].count {
                            numberCell(number: numbers[row][column])
                        }
                    }
                }
            }
        }
        .background(Color.white)
        .cornerRadius(12)
    }
    
    // 数字单元格
    private func numberCell(number: Int) -> some View {
        let cellSize = (boardSize / CGFloat(tableSize))
        
        return Button(action: {
            if gameState == .playing && number == currentNumber {
                handleNumberTap(number: number)
            }
        }) {
            Text("\(number)")
                .font(.system(size: cellSize * 0.4))
                .fontWeight(.bold)
                .frame(width: cellSize, height: cellSize)
                .background(Color.white)
                .overlay(
                    Rectangle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
        .disabled(gameState != .playing || number < currentNumber)
    }
    
    // MARK: - 游戏逻辑
    
    // 设置游戏
    private func setupGame() {
        // 创建并打乱数字
        numbers = createShuffledNumbers(size: tableSize)
    }
    
    // 创建打乱的数字数组
    private func createShuffledNumbers(size: Int) -> [[Int]] {
        var allNumbers = Array(1...size*size)
        allNumbers.shuffle()
        
        var result: [[Int]] = []
        for i in 0..<size {
            let startIndex = i * size
            let endIndex = startIndex + size
            result.append(Array(allNumbers[startIndex..<endIndex]))
        }
        
        return result
    }
    
    // 开始游戏
    private func startGame() {
        resetGame()
        gameState = .playing
        startTime = Date()
        
        // 设置定时器更新经过的时间
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if let start = startTime {
                elapsedTime = Date().timeIntervalSince(start)
            }
        }
    }
    
    // 重置游戏
    private func resetGame() {
        currentNumber = 1
        elapsedTime = 0
        timer?.invalidate()
        setupGame()
    }
    
    // 处理数字点击
    private func handleNumberTap(number: Int) {
        if number == currentNumber {
            if currentNumber < totalNumbers {
                currentNumber += 1
            } else {
                // 游戏完成
                finishGame()
            }
        }
    }
    
    // 完成游戏
    private func finishGame() {
        timer?.invalidate()
        gameState = .finished
        
        // 保存成绩
        gameDataManager.saveResult(gameType: .schulteTable, score: elapsedTime)
        
        // 显示结果页面
        isShowingResult = true
    }
}

#Preview {
    SchulteTableGameView(tableSize: 5)
        .environmentObject(GameDataManager())
} 