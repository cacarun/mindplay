//
//  SequenceMemoryGameView.swift
//  mindplay
//
//  Created for MindPlay app.
//

import SwiftUI
import AVFoundation

enum SequenceGameState {
    case intro           // 游戏介绍
    case showSequence    // 展示序列
    case userTurn        // 用户回答
    case correct         // 回答正确
    case wrong           // 回答错误
    case gameOver        // 游戏结束
}

struct SequenceMemoryGameView: View {
    @EnvironmentObject var gameDataManager: GameDataManager
    @Environment(\.dismiss) private var dismiss
    
    let gridSize: Int // 传入的宫格大小参数
    
    @State private var gameState: SequenceGameState = .intro
    @State private var sequence: [Int] = []
    @State private var userSequence: [Int] = []
    @State private var level = 1
    @State private var currentIndex = 0
    @State private var isAnimating = false
    @State private var activeCell: Int? = nil
    @State private var showingResult = false
    @State private var animationTriggered = false
    
    private var gridDimension: Int {
        Int(sqrt(Double(gridSize)))
    }
    
    // 背景渐变色 - 蓝紫色渐变
    private let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.3, green: 0.4, blue: 0.9),
            Color(red: 0.6, green: 0.3, blue: 0.9)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // 按钮颜色和状态
    private func cellBackgroundColor(for index: Int) -> Color {
        if gameState == .showSequence || gameState == .correct {
            if activeCell == index {
                // 点亮的单元格
                return Color.white
            }
        }
        // 默认单元格颜色
        return Color.white.opacity(0.2)
    }
    
    private func cellForegroundColor(for index: Int) -> Color {
        if gameState == .showSequence || gameState == .correct {
            if activeCell == index {
                // 点亮的单元格文字颜色
                return Color(red: 0.3, green: 0.3, blue: 0.9)
            }
        }
        // 默认文字颜色
        return Color.white
    }
    
    var body: some View {
        ZStack {
            // 渐变背景
            backgroundGradient
                .ignoresSafeArea()
            
            // 背景装饰元素
            GeometryReader { geometry in
                ZStack {
                    // 添加装饰性小方块
                    decorativeSquares(for: geometry)
                }
            }
            
            VStack {
                // 头部信息
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(LocalizedStringKey.level.localized + ": \(level)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
                    }
                    
                    Spacer()
                    
                    // 关闭按钮
                    Button(action: {
                        let impactMed = UIImpactFeedbackGenerator(style: .medium)
                        impactMed.impactOccurred()
                        self.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding()
                
                Spacer()
                
                // 状态提示
                statusPrompt
                    .padding(.vertical, 20)
                
                // 游戏网格
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: gridDimension), spacing: 8) {
                    ForEach(0..<gridSize, id: \.self) { index in
                        Button(action: {
                            if gameState == .userTurn {
                                cellTapped(index)
                            }
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(cellBackgroundColor(for: index))
                                    .aspectRatio(1, contentMode: .fit)
                                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                                
                                // 只在用户回答模式下显示数字
                                if gameState == .userTurn && userSequence.contains(index) {
                                    let position = userSequence.firstIndex(of: index)! + 1
                                    Text("\(position)")
                                        .font(.title3.bold())
                                        .foregroundColor(cellForegroundColor(for: index))
                                }
                            }
                        }
                        .scaleEffect(activeCell == index ? 1.1 : 1.0)
                        .animation(
                            .spring(response: 0.2, dampingFraction: 0.6),
                            value: activeCell
                        )
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // 开始和继续按钮
                if gameState == .intro {
                    Button(action: {
                        startGame()
                        let impactMed = UIImpactFeedbackGenerator(style: .medium)
                        impactMed.impactOccurred()
                    }) {
                        Text(LocalizedStringKey.startSequence.localized)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.9))
                            .frame(height: 60)
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 40)
                }
            }
            
            // 结果覆盖层
            if gameState == .gameOver {
                gameOverOverlay
            }
        }
        .fullScreenCover(isPresented: $showingResult) {
            SequenceMemoryResultView(level: level - 1, gridSize: gridSize) {
                self.dismiss()
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
    
    // 分解复杂表达式 - 装饰性小方块
    private func decorativeSquares(for geometry: GeometryProxy) -> some View {
        ZStack {
            ForEach(0..<6, id: \.self) { i in
                let sizes: [CGFloat] = [20, 25, 15, 18, 22, 16]
                let widthFactors: [CGFloat] = [0.1, 0.9, 0.2, 0.85, 0.15, 0.8]
                let heightFactors: [CGFloat] = [0.1, 0.2, 0.9, 0.85, 0.7, 0.3]
                let rotations: [Double] = [10, -5, 8, -12, 7, -9]
                let durations: [Double] = [4, 5, 4.5, 5.5, 3.5, 6]
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.1))
                    .frame(width: sizes[i], height: sizes[i])
                    .position(
                        x: geometry.size.width * widthFactors[i],
                        y: geometry.size.height * heightFactors[i]
                    )
                    .rotationEffect(.degrees(isAnimating ? rotations[i] : 0))
                    .animation(
                        Animation.easeInOut(duration: durations[i])
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
            }
        }
    }
    
    // 分解复杂表达式 - 游戏结束覆盖层
    private var gameOverOverlay: some View {
        ZStack {
            // 半透明黑色背景
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        showingResult = true
                    }
                }
            
            // 游戏结束提示
            VStack(spacing: 20) {
                Text(LocalizedStringKey.gameOver.localized)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 2)
                
                Text(String.localizedStringWithFormat(
                    LocalizedStringKey.finalLevel.localized as String,
                    level - 1)
                )
                    .font(.title2)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 20)
                
                Button(action: {
                    showingResult = true
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()
                }) {
                    Text(LocalizedStringKey.seeResults.localized)
                        .font(.headline)
                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.9))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
                        .padding(.horizontal, 40)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 50)
            .padding(.horizontal, 20)
            .background(Color(red: 0.3, green: 0.3, blue: 0.9).opacity(0.7))
            .cornerRadius(20)
            .padding(.horizontal, 20)
            .transition(.scale.combined(with: .opacity))
            .scaleEffect(animationTriggered ? 1.0 : 0.8)
            .opacity(animationTriggered ? 1.0 : 0)
            .animation(
                .spring(response: 0.5, dampingFraction: 0.7),
                value: animationTriggered
            )
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    animationTriggered = true
                }
            }
        }
    }
    
    // 游戏状态提示
    private var statusPrompt: some View {
        VStack(spacing: 10) {
            switch gameState {
            case .intro:
                introStatusText
                
            case .showSequence:
                showSequenceStatusText
                
            case .userTurn:
                userTurnStatusText
                
            case .correct:
                correctStatusText
                
            case .wrong:
                wrongStatusText
                
            case .gameOver:
                EmptyView()
            }
        }
        .frame(height: 60)
    }
    
    // 分解状态文本视图
    private var introStatusText: some View {
        Text(LocalizedStringKey.watchSequence.localized)
            .font(.title3)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
            .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
    }
    
    private var showSequenceStatusText: some View {
        Text(LocalizedStringKey.watchSequence.localized)
            .font(.title3)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
            .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
    }
    
    private var userTurnStatusText: some View {
        VStack {
            Text(LocalizedStringKey.yourTurn.localized)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
            
            Text("(\(userSequence.count)/\(sequence.count))")
                .font(.headline)
                .foregroundColor(.white.opacity(0.9))
        }
    }
    
    private var correctStatusText: some View {
        Text(LocalizedStringKey.correct.localized)
            .font(.title3)
            .fontWeight(.bold)
            .foregroundColor(.green)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
            .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
            .scaleEffect(isAnimating ? 1.1 : 1.0)
            .animation(
                Animation.easeInOut(duration: 0.5)
                    .repeatForever(autoreverses: true),
                value: isAnimating
            )
    }
    
    private var wrongStatusText: some View {
        Text(LocalizedStringKey.wrong.localized)
            .font(.title3)
            .fontWeight(.bold)
            .foregroundColor(.red)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
            .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
            .scaleEffect(isAnimating ? 1.1 : 1.0)
            .animation(
                Animation.easeInOut(duration: 0.5)
                    .repeatForever(autoreverses: true),
                value: isAnimating
            )
    }
    
    // 游戏逻辑
    private func startGame() {
        level = 1
        sequence = []
        userSequence = []
        gameState = .showSequence
        generateSequence()
        showSequence()
    }
    
    private func generateSequence() {
        sequence = []
        for _ in 0..<level {
            sequence.append(Int.random(in: 0..<gridSize))
        }
    }
    
    private func showSequence() {
        currentIndex = 0
        activeCell = nil
        
        let delay = level > 10 ? 0.5 : (level > 5 ? 0.7 : 0.9)
        
        func showNextCell() {
            guard currentIndex < sequence.count else {
                // 序列展示完成
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    activeCell = nil
                    userSequence = []
                    gameState = .userTurn
                }
                return
            }
            
            // 展示当前单元格
            let cell = sequence[currentIndex]
            activeCell = cell
            // 播放单元格声音
            let impactLight = UIImpactFeedbackGenerator(style: .light)
            impactLight.impactOccurred()
            
            // 显示一段时间后隐藏
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                activeCell = nil
                
                // 显示下一个单元格
                currentIndex += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + delay * 0.6) {
                    showNextCell()
                }
            }
        }
        
        // 开始显示序列
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showNextCell()
        }
    }
    
    private func cellTapped(_ index: Int) {
        guard gameState == .userTurn else { return }
        
        // 添加触觉反馈
        let impactMed = UIImpactFeedbackGenerator(style: .medium)
        impactMed.impactOccurred()
        
        // 记录用户点击的单元格
        userSequence.append(index)
        
        // 检查是否正确
        let position = userSequence.count - 1
        if sequence[position] == index {
            // 点击正确
            
            // 检查是否完成当前序列
            if userSequence.count == sequence.count {
                // 完成序列，进入下一关
                gameState = .correct
                activeCell = index // 高亮最后点击的单元格
                
                // 播放成功音效
                let notification = UINotificationFeedbackGenerator()
                notification.notificationOccurred(.success)
                
                // 延迟后进入下一关
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    level += 1
                    gameState = .showSequence
                    generateSequence()
                    showSequence()
                }
            }
        } else {
            // 点击错误
            gameState = .wrong
            
            // 播放失败音效
            let notification = UINotificationFeedbackGenerator()
            notification.notificationOccurred(.error)
            
            // 保存游戏结果
            gameDataManager.saveResult(gameType: .sequenceMemory, score: Double(level - 1))
            
            // 延迟后进入游戏结束状态
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                gameState = .gameOver
                animationTriggered = false
            }
        }
    }
}

#Preview {
    SequenceMemoryGameView(gridSize: 9)
        .environmentObject(GameDataManager())
}
