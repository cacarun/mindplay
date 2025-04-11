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
    
    // 计时器
    @State private var timer: Publishers.Autoconnect<Timer.TimerPublisher>?
    @State private var timerCancellable: Cancellable?
    
    init(startLength: Int = 7) {
        self.startLength = startLength
        // 使用_digitLength来初始化状态变量
        _digitLength = State(initialValue: startLength)
    }
    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // 顶部状态区域
                VStack(spacing: 10) {
                    if gameState != .ready && gameState != .finished {
                        Text("Level \(currentLevel)")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("\(digitLength) Digits")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    if gameState == .showing || gameState == .answering {
                        Text(LocalizedStringKey.timeRemaining.localized(with: timeRemaining))
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
                .padding()
                
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
        }
        .onAppear {
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
    
    // 背景颜色
    private var backgroundColor: Color {
        switch gameState {
        case .ready:
            return Color(.systemBackground)
        case .showing:
            return Color.blue
        case .answering:
            return Color.indigo
        case .correct:
            return Color.green
        case .incorrect:
            return Color.red
        case .finished:
            return Color(.systemBackground)
        }
    }
    
    // 开始视图
    private var startView: some View {
        VStack(spacing: 20) {
            Text(LocalizedStringKey.numberMemoryTest.localized)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(LocalizedStringKey.rememberLongestNumber.localized)
                .font(.title3)
                .multilineTextAlignment(.center)
            
            Button(action: {
                startGame()
            }) {
                Text(LocalizedStringKey.startNumberTest.localized)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.top, 20)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 5)
        .padding()
    }
    
    // 数字显示视图
    private var numberDisplayView: some View {
        VStack(spacing: 30) {
            Text(LocalizedStringKey.memorizeNumber.localized)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(currentNumber)
                .font(.system(size: 44, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .padding(.horizontal)
                .multilineTextAlignment(.center)
                .lineLimit(10)
        }
    }
    
    // 答案输入视图
    private var answerInputView: some View {
        VStack(spacing: 25) {
            Text(LocalizedStringKey.enterNumber.localized)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            TextField("", text: $userAnswer)
                .font(.system(size: 32, weight: .bold, design: .monospaced))
                .foregroundColor(.black)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
            
            Button(action: {
                checkAnswer()
            }) {
                Text(LocalizedStringKey.submitAnswer.localized)
                    .font(.headline)
                    .foregroundColor(.indigo)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(12)
            }
            .padding(.top, 10)
        }
    }
    
    // 答案正确视图
    private var correctView: some View {
        VStack(spacing: 25) {
            Text(LocalizedStringKey.correct.localized)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.white)
            
            Button(action: {
                nextLevel()
            }) {
                Text(LocalizedStringKey.nextLevel.localized)
                    .font(.headline)
                    .foregroundColor(.green)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(12)
            }
            .padding(.top, 10)
        }
    }
    
    // 答案错误视图
    private var incorrectView: some View {
        VStack(spacing: 20) {
            Text(LocalizedStringKey.wrong.localized)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Text(LocalizedStringKey.correctNumber.localized + ":")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(currentNumber)
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                HStack {
                    Text(LocalizedStringKey.yourNumber.localized + ":")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(userAnswer)
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                HStack {
                    Text(LocalizedStringKey.levelReached.localized + ":")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("\(currentLevel)")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
            
            Button(action: {
                finishGame()
            }) {
                Text(LocalizedStringKey.seeResults.localized)
                    .font(.headline)
                    .foregroundColor(.red)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(12)
            }
            .padding(.top, 10)
        }
    }
    
    // MARK: - 游戏逻辑
    
    // 开始游戏
    private func startGame() {
        currentLevel = 1
        digitLength = startLength
        gameState = .showing
        startShowingNumber()
    }
    
    // 生成随机数字
    private func generateNumber() {
        var newNumber = ""
        for _ in 0..<digitLength {
            // 生成1-9的随机数字，避免以0开头
            if newNumber.isEmpty {
                newNumber += String(Int.random(in: 1...9))
            } else {
                newNumber += String(Int.random(in: 0...9))
            }
        }
        currentNumber = newNumber
    }
    
    // 开始显示数字
    private func startShowingNumber() {
        // 取消可能存在的旧计时器
        timerCancellable?.cancel()
        
        // 计算显示时间：每一位数字1秒，最少5秒
        let displayTime = max(5, digitLength)
        timeRemaining = displayTime
        
        // 创建并启动计时器
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        timerCancellable = timer?.sink { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
                if timeRemaining == 0 {
                    timerCancellable?.cancel()
                    gameState = .answering
                    userAnswer = ""
                    startAnswerTimer()
                }
            }
        }
    }
    
    // 开始答题计时器
    private func startAnswerTimer() {
        // 取消可能存在的旧计时器
        timerCancellable?.cancel()
        
        // 答题时间固定为30秒
        timeRemaining = 30
        
        // 创建并启动计时器
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        timerCancellable = timer?.sink { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
                if timeRemaining == 0 {
                    timerCancellable?.cancel()
                    // 时间到，判断为错误
                    gameState = .incorrect
                }
            }
        }
    }
    
    // 检查答案
    private func checkAnswer() {
        // 取消当前计时器
        timerCancellable?.cancel()
        
        // 检查答案是否正确
        if userAnswer == currentNumber {
            gameState = .correct
        } else {
            gameState = .incorrect
        }
    }
    
    // 进入下一关
    private func nextLevel() {
        currentLevel += 1
        digitLength += 1
        generateNumber()
        gameState = .showing
        startShowingNumber()
    }
    
    // 完成游戏
    private func finishGame() {
        // 保存游戏结果（记忆的最大位数）
        gameDataManager.saveResult(gameType: .numberMemory, score: Double(digitLength - 1))
        
        // 显示结果
        gameState = .finished
    }
}

#Preview {
    NumberMemoryGameView(startLength: 7)
        .environmentObject(GameDataManager())
} 