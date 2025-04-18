//
//  NumberMemoryGameView.swift
//  mindplay
//
//  Created for MindPlay app.
//

import SwiftUI
import Combine

enum NumberMemoryGameState {
    case ready      // 准备开始游戏
    case showing    // 显示数字给用户记忆
    case answering  // 用户输入答案阶段
    case correct    // 用户答案正确
    case incorrect  // 用户答案错误
    case finished   // 游戏结束
}

struct NumberMemoryGameView: View {
    @EnvironmentObject var gameDataManager: GameDataManager
    @Environment(\.dismiss) private var dismiss
    
    // 游戏配置
    let startLength: Int
    
    // 游戏状态
    @State private var gameState: NumberMemoryGameState = .ready
    @State private var currentLevel = 1
    @State private var currentNumber = ""
    @State private var userAnswer = ""
    @State private var digitLength: Int
    @State private var timeRemaining = 0
    @State private var isAnimating = false
    @State private var showingNumber = false
    @State private var pulseAnimation = false
    
    // 计时器
    @State private var timer: Publishers.Autoconnect<Timer.TimerPublisher>?
    @State private var timerCancellable: Cancellable?
    
    // 背景渐变色 - 对应不同游戏状态
    private var backgroundGradient: LinearGradient {
        switch gameState {
        case .ready:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.6, green: 0.4, blue: 0.8),
                    Color(red: 0.3, green: 0.4, blue: 0.9)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .showing:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.3, green: 0.5, blue: 0.9),
                    Color(red: 0.2, green: 0.3, blue: 0.8)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .answering:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.4, green: 0.3, blue: 0.9),
                    Color(red: 0.3, green: 0.2, blue: 0.7)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .correct:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.2, green: 0.7, blue: 0.3),
                    Color(red: 0.1, green: 0.5, blue: 0.4)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .incorrect:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.8, green: 0.2, blue: 0.2),
                    Color(red: 0.6, green: 0.1, blue: 0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .finished:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.6, green: 0.4, blue: 0.8),
                    Color(red: 0.3, green: 0.4, blue: 0.9)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    init(startLength: Int = 7) {
        self.startLength = startLength
        // 使用_digitLength来初始化状态变量
        _digitLength = State(initialValue: startLength)
    }
    
    var body: some View {
        ZStack {
            // 渐变背景
            backgroundGradient
                .ignoresSafeArea()
            
            // 背景装饰元素
            GeometryReader { geometry in
                ZStack {
                    // 添加装饰性元素
                    decorativeElements(in: geometry)
                }
            }
            
            VStack {
                // 顶部状态区域
                VStack(spacing: 8) {
                    if gameState == .showing || gameState == .answering {
                        Text(LocalizedStringKey.timeRemaining.localized(with: timeRemaining))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 20)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(30)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    
                    if gameState == .showing || gameState == .answering || gameState == .correct || gameState == .incorrect {
                        Text(LocalizedStringKey.level.localized + " \(currentLevel)")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.top, 8)
                    }
                }
                .padding(.top, 30)
                .padding(.bottom, 10)
                
                Spacer()
                
                // 游戏主要区域
                switch gameState {
                case .ready:
                    startView
                case .showing:
                    numberDisplayView
                case .answering:
                    answerInputView
                case .correct:
                    correctView
                case .incorrect:
                    incorrectView
                case .finished:
                    EmptyView() // 结果通过fullScreenCover显示
                }
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            isAnimating = true
            generateNumber()
        }
        .fullScreenCover(isPresented: Binding<Bool>(
            get: { gameState == .finished },
            set: { if !$0 { gameState = .ready } }
        )) {
            NumberMemoryResultView(
                level: currentLevel,
                digitsRemembered: digitLength - 1, // 上一轮成功记忆的位数
                onDismiss: { dismiss() },
                onRestart: {
                    // 重置游戏状态
                    gameState = .ready
                    currentLevel = 1
                    digitLength = startLength
                    currentNumber = ""
                    userAnswer = ""
                    generateNumber()
                }
            )
        }
    }
    
    // 装饰性元素
    private func decorativeElements(in geometry: GeometryProxy) -> some View {
        ZStack {
            // 确保视图尺寸有效
            let safeWidth = max(100, geometry.size.width)
            let safeHeight = max(100, geometry.size.height)
            
            // 添加一些圆形和数字作为装饰
            ForEach(0..<5) { i in
                let sizes: [CGFloat] = [100, 80, 120, 90, 110]
                let posX: [CGFloat] = [0.1, 0.85, 0.25, 0.75, 0.5]
                let posY: [CGFloat] = [0.2, 0.15, 0.85, 0.7, 0.3]
                let rotations: [Double] = [10, -8, 15, -12, 5]
                let durations: [Double] = [7, 8, 6, 9, 7.5]
                
                Circle()
                    .stroke(Color.white.opacity(0.08), lineWidth: 2)
                    .frame(width: sizes[i], height: sizes[i])
                    .position(
                        x: safeWidth * posX[i],
                        y: safeHeight * posY[i]
                    )
                    .rotationEffect(.degrees(isAnimating ? rotations[i] : 0))
                    .animation(
                        Animation.easeInOut(duration: durations[i])
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
            }
            
            if gameState == .showing && showingNumber {
                // 显示数字时的动态特效
                ForEach(0..<3) { i in
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 3)
                        .frame(width: 250 + CGFloat(i * 50))
                        .scaleEffect(pulseAnimation ? 1.2 : 0.8)
                        .opacity(pulseAnimation ? 0.1 : 0.3)
                        .animation(
                            Animation.easeInOut(duration: 2)
                                .repeatForever(autoreverses: true)
                                .delay(Double(i) * 0.3),
                            value: pulseAnimation
                        )
                        .position(x: safeWidth/2, y: safeHeight/2)
                }
            }
        }
    }
    
    // 开始视图
    private var startView: some View {
        VStack(spacing: 25) {
            // 动画图标
            Image(systemName: "brain")
                .font(.system(size: 80))
                .foregroundColor(.white)
                .padding()
                .background(Circle().fill(Color.white.opacity(0.2)))
                .scaleEffect(isAnimating ? 1.1 : 0.9)
                .animation(
                    Animation.easeInOut(duration: 2)
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )
            
            Text(LocalizedStringKey.numberMemoryTest.localized)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .shadow(color: Color.black.opacity(0.2), radius: 2, x: 1, y: 1)
            
            Text(LocalizedStringKey.rememberLongestNumber.localized)
                .font(.title3)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                startGame()
                // 触觉反馈
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
            }) {
                Text(LocalizedStringKey.startNumberTest.localized)
                    .font(.headline)
                    .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.8))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
        }
        .padding(30)
        .background(Color.white.opacity(0.15))
        .cornerRadius(30)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        .padding()
    }
    
    // 数字显示视图
    private var numberDisplayView: some View {
        ZStack {
            // 背景卡片
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.15))
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                .padding(.horizontal)
                
            VStack(spacing: 30) {
                Text(LocalizedStringKey.memorizeNumber.localized)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
                
                // 数字显示
                Text(currentNumber)
                    .font(.system(size: min(600 / CGFloat(digitLength), 44), weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
                    .lineLimit(10)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    .scaleEffect(showingNumber ? 1.0 : 0.8)
                    .opacity(showingNumber ? 1 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: showingNumber)
            }
            .padding(30)
        }
        .onAppear {
            pulseAnimation = true
            // 数字稍微延迟显示，增加动画效果
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showingNumber = true
            }
        }
    }
    
    // 答案输入视图
    private var answerInputView: some View {
        VStack(spacing: 30) {
            Text(LocalizedStringKey.enterNumber.localized)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
            
            // 输入框
            VStack(spacing: 16) {
                TextField("", text: $userAnswer)
                    .font(.system(size: 30, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.8))
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // 提交按钮
                Button(action: {
                    checkAnswer()
                    // 触觉反馈
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()
                }) {
                    Text(LocalizedStringKey.submitAnswer.localized)
                        .font(.headline)
                        .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.8))
                        .padding()
                        .frame(width: 180)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
                }
            }
            .padding(.horizontal, 40)
        }
        .padding(30)
        .background(Color.white.opacity(0.15))
        .cornerRadius(30)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        .padding()
    }
    
    // 答案正确视图
    private var correctView: some View {
        VStack(spacing: 25) {
            // 成功动画
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .scaleEffect(isAnimating ? 1.1 : 0.9)
                .animation(
                    Animation.easeInOut(duration: 0.8)
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )
            
            Text(LocalizedStringKey.correct.localized)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.2), radius: 2, x: 1, y: 1)
            
            Button(action: {
                nextLevel()
                // 触觉反馈
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
            }) {
                Text(LocalizedStringKey.nextLevel.localized)
                    .font(.headline)
                    .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.3))
                    .padding()
                    .frame(width: 200)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
            }
            .padding(.top, 20)
        }
        .padding(30)
        .background(Color.white.opacity(0.15))
        .cornerRadius(30)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        .padding()
    }
    
    // 答案错误视图
    private var incorrectView: some View {
        VStack(spacing: 20) {
            // 错误动画
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 70))
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .scaleEffect(isAnimating ? 1.1 : 0.9)
                .animation(
                    Animation.easeInOut(duration: 0.8)
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )
            
            Text(LocalizedStringKey.wrong.localized)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.2), radius: 2, x: 1, y: 1)
            
            // 正确答案和用户答案对比
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Text(LocalizedStringKey.correctNumber.localized + ":")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                    
                    Spacer()
                    
                    Text(currentNumber)
                        .font(.system(.headline, design: .monospaced))
                        .foregroundColor(.white)
                }
                .padding(.vertical, 6)
                
                HStack {
                    Text(LocalizedStringKey.yourNumber.localized + ":")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                    
                    Spacer()
                    
                    Text(userAnswer)
                        .font(.system(.headline, design: .monospaced))
                        .foregroundColor(.white)
                }
                .padding(.vertical, 6)
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(16)
            .padding(.vertical, 10)
            
            // 查看结果按钮
            Button(action: {
                // 保存游戏结果
                gameDataManager.saveResult(gameType: .numberMemory, score: Double(digitLength - 1))
                gameState = .finished
                // 触觉反馈
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
            }) {
                Text(LocalizedStringKey.seeResults.localized)
                    .font(.headline)
                    .foregroundColor(Color(red: 0.7, green: 0.2, blue: 0.2))
                    .padding()
                    .frame(width: 200)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
            }
            .padding(.top, 10)
        }
        .padding(30)
        .background(Color.white.opacity(0.15))
        .cornerRadius(30)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        .padding()
    }
    
    // 生成随机数字
    private func generateNumber() {
        currentNumber = (0..<digitLength).map { _ in String(Int.random(in: 0...9)) }.joined()
    }
    
    // 开始游戏
    private func startGame() {
        // 重置状态
        userAnswer = ""
        showingNumber = false
        pulseAnimation = false
        generateNumber()
        
        // 显示数字阶段
        gameState = .showing
        
        // 计算显示时间（最少5秒）
        let showTime = max(5, digitLength)
        timeRemaining = showTime
        
        // 设置计时器
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        timerCancellable = timer?.sink { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                // 时间到，进入回答阶段
                switchToAnsweringState()
            }
        }
    }
    
    // 切换到回答阶段
    private func switchToAnsweringState() {
        // 取消原计时器
        timerCancellable?.cancel()
        
        // 设置回答阶段
        gameState = .answering
        timeRemaining = 30 // 30秒时间回答
        
        // 新计时器
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        timerCancellable = timer?.sink { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                // 时间到，自动判定为答错
                checkAnswer()
            }
        }
    }
    
    // 检查答案
    private func checkAnswer() {
        // 取消计时器
        timerCancellable?.cancel()
        
        if userAnswer == currentNumber {
            // 答案正确
            gameState = .correct
            // 触觉反馈 - 成功
            let notification = UINotificationFeedbackGenerator()
            notification.notificationOccurred(.success)
        } else {
            // 答案错误
            gameState = .incorrect
            // 触觉反馈 - 错误
            let notification = UINotificationFeedbackGenerator()
            notification.notificationOccurred(.error)
        }
    }
    
    // 进入下一关
    private func nextLevel() {
        currentLevel += 1
        digitLength += 1
        userAnswer = ""
        showingNumber = false
        pulseAnimation = false
        generateNumber()
        
        // 显示数字阶段
        gameState = .showing
        
        // 计算显示时间
        let showTime = max(5, digitLength)
        timeRemaining = showTime
        
        // 设置计时器
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        timerCancellable = timer?.sink { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                // 时间到，进入回答阶段
                switchToAnsweringState()
            }
        }
    }
}

#Preview {
    NavigationStack {
        NumberMemoryGameView()
            .environmentObject(GameDataManager())
    }
} 