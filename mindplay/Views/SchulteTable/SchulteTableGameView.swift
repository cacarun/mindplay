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
    @State private var isAnimating = false // 添加动画控制状态
    @State private var showSuccessAnimation = false // 成功点击的动画状态
    
    // 时间相关
    @State private var startTime: Date? = nil
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer? = nil
    
    // 布局相关
    @State private var boardSize: CGFloat = 300.0
    
    // 舒尔特表格游戏的主题渐变色 - 薄荷绿/青色
    private let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.2, green: 0.7, blue: 0.6),
            Color(red: 0.1, green: 0.5, blue: 0.8)
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
                    // 添加一些装饰性方格，代表舒尔特表格
                    ForEach(0..<6) { i in
                        let positions = [
                            CGPoint(x: geometry.size.width * 0.1, y: geometry.size.height * 0.2),
                            CGPoint(x: geometry.size.width * 0.9, y: geometry.size.height * 0.15),
                            CGPoint(x: geometry.size.width * 0.2, y: geometry.size.height * 0.85),
                            CGPoint(x: geometry.size.width * 0.8, y: geometry.size.height * 0.8),
                            CGPoint(x: geometry.size.width * 0.15, y: geometry.size.height * 0.5),
                            CGPoint(x: geometry.size.width * 0.85, y: geometry.size.height * 0.6)
                        ]
                        
                        let sizes: [CGFloat] = [60, 70, 50, 65, 55, 45]
                        let opacities: [Double] = [0.1, 0.08, 0.12, 0.06, 0.1, 0.07]
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.white.opacity(opacities[i]))
                                .frame(width: sizes[i], height: sizes[i])
                            
                            Text("\(i + 1)")
                                .font(.system(size: sizes[i] * 0.4, weight: .bold))
                                .foregroundColor(.white.opacity(opacities[i] * 2))
                        }
                        .position(positions[i])
                        .rotationEffect(.degrees(isAnimating ? Double(i * 8) : 0))
                        .animation(
                            Animation.easeInOut(duration: Double(i) + 4)
                                .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                    }
                    
                    // 成功点击的动画效果
                    if showSuccessAnimation {
                        ForEach(0..<10) { i in
                            Circle()
                                .fill(successAnimationColor(for: i))
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
                    // 状态区域
                    VStack {
                        if gameState != .ready {
                            statusView
                                .padding(.top, 20)
                                .transition(.opacity)
                        } else {
                            // 占位视图，保持布局一致性
                            Color.clear
                                .frame(height: 60)
                        }
                    }
                    
                    Spacer(minLength: 20)
                    
                    // 游戏区域
                    ZStack {
                        if gameState == .ready {
                            readyView
                                .frame(width: boardSize, height: boardSize)
                                .transition(.opacity)
                        } else if gameState != .finished {
                            gameBoard
                                .transition(.opacity)
                        } else {
                            // 占位视图保持大小一致
                            Color.clear
                                .frame(width: boardSize, height: boardSize)
                        }
                    }
                    .frame(width: boardSize, height: boardSize)
                    
                    Spacer()
                    
                    // 控制按钮区域
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
                            .foregroundColor(Color(red: 0.2, green: 0.7, blue: 0.6))
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
                        .padding(.bottom, 20)
                    }
                }
                .padding()
                .onAppear {
                    boardSize = min(geometry.size.width, geometry.size.height) - 100
                    totalNumbers = tableSize * tableSize
                    setupGame()
                    isAnimating = true
                }
                .animation(.easeInOut(duration: 0.3), value: gameState)
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
    
    // 状态视图
    private var statusView: some View {
        VStack(spacing: 6) {
            if currentNumber <= totalNumbers {
                Text(LocalizedStringKey.findingNumber.localized(with: currentNumber))
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(15)
                    .scaleEffect(isAnimating ? 1.05 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
            } else {
                Text("完成!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
            }
            
            if gameState == .playing {
                Text(String(format: "%.1f s", elapsedTime))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.yellow)
                    .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
                    .padding(.top, 4)
            }
        }
    }
    
    // 游戏准备视图
    private var readyView: some View {
        VStack(spacing: 25) {
            // 视觉注意力图标
            Image(systemName: "eye.circle")
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
            
            Text(LocalizedStringKey.schulteTableTest.localized)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.2), radius: 2, x: 1, y: 1)
                .multilineTextAlignment(.center)
            
            Text(String.localizedStringWithFormat(LocalizedStringKey.findNumbers.localized as String, "1", String(tableSize * tableSize)))
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
        .background(Color.white.opacity(0.9))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
    
    // 数字单元格
    private func numberCell(number: Int) -> some View {
        let cellSize = (boardSize / CGFloat(tableSize))
        
        return Button(action: {
            if gameState == .playing && number == currentNumber {
                handleNumberTap(number: number)
            }
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(cellBackground(for: number))
                    .frame(width: cellSize, height: cellSize)
                
                Text("\(number)")
                    .font(.system(size: cellSize * 0.4, weight: .bold))
                    .foregroundColor(cellTextColor(for: number))
            }
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .disabled(gameState != .playing || number < currentNumber)
    }
    
    // 单元格背景颜色
    private func cellBackground(for number: Int) -> Color {
        if number < currentNumber {
            // 已点击的单元格有轻微的绿色背景
            return Color(red: 0.9, green: 1.0, blue: 0.9)
        } else {
            return .white
        }
    }
    
    // 单元格文本颜色
    private func cellTextColor(for number: Int) -> Color {
        if number < currentNumber {
            // 已点击的单元格文字为绿色
            return Color(red: 0.2, green: 0.7, blue: 0.4)
        } else {
            return .black
        }
    }
    
    // 成功动画颜色
    private func successAnimationColor(for index: Int) -> Color {
        let colors: [Color] = [.green, .cyan, .blue, .mint, .teal, .yellow]
        return colors[index % colors.count]
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
            // 触觉反馈
            let impactLight = UIImpactFeedbackGenerator(style: .light)
            impactLight.impactOccurred()
            
            // 显示成功动画
            if currentNumber % 5 == 0 {
                showSuccessAnimationEffect()
            }
            
            if currentNumber < totalNumbers {
                currentNumber += 1
            } else {
                // 游戏完成
                finishGame()
            }
        }
    }
    
    // 显示成功动画效果
    private func showSuccessAnimationEffect() {
        showSuccessAnimation = true
        // 重置动画状态触发粒子动画
        isAnimating.toggle()
        
        // 延迟后隐藏粒子
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            showSuccessAnimation = false
        }
    }
    
    // 完成游戏
    private func finishGame() {
        timer?.invalidate()
        gameState = .finished
        
        // 成功振动反馈
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // 保存成绩，添加表格大小信息
        gameDataManager.saveResult(gameType: .schulteTable, score: elapsedTime, extraData: "\(tableSize)x\(tableSize)")
        
        // 显示结果页面
        isShowingResult = true
    }
}

#Preview {
    SchulteTableGameView(tableSize: 5)
        .environmentObject(GameDataManager())
} 