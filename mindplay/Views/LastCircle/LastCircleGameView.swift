//
//  LastCircleGameView.swift
//  mindplay
//
//  Created for MindPlay app.
//

import SwiftUI

// 游戏状态
enum LastCircleGameState {
    case ready
    case playing
    case correct
    case incorrect
    case finished
}

// 圆圈模型
struct GameCircle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var color: Color
    var opacity: Double
    var isNewest: Bool
    var size: CGFloat
}

struct LastCircleGameView: View {
    @EnvironmentObject var gameDataManager: GameDataManager
    @Environment(\.dismiss) private var dismiss
    @State private var gameState: LastCircleGameState = .ready
    @State private var circles: [GameCircle] = []
    @State private var score: Int = 0
    @State private var round: Int = 0
    @State private var timeRemaining: Double = 3.0
    @State private var timer: Timer?
    @State private var startTime: Date?
    @State private var reactionTimes: [Double] = []
    @State private var isAnimating = false
    @State private var showParticles = false
    @State private var particlePosition: CGPoint = .zero
    @State private var showResult = false
    
    // 游戏配置
    let circleCount: Int // 最大圆圈数量
    let baseTimeLimit: Double = 3.0 // 基础时间限制(秒)
    let colors: [Color] = [.red, .blue, .green, .orange, .purple, .pink, .yellow, .teal]
    let newestCircleSize: CGFloat = 60
    let normalCircleSize: CGFloat = 50
    
    // 背景渐变
    private var backgroundGradient: LinearGradient {
        switch gameState {
        case .ready:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.3, green: 0.6, blue: 0.9),
                    Color(red: 0.5, green: 0.2, blue: 0.8)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .playing:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.3, green: 0.6, blue: 0.9),
                    Color(red: 0.5, green: 0.2, blue: 0.8)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .correct:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.2, green: 0.7, blue: 0.3),
                    Color(red: 0.3, green: 0.6, blue: 0.9)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .incorrect:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.8, green: 0.2, blue: 0.2),
                    Color(red: 0.6, green: 0.1, blue: 0.3)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .finished:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.3, green: 0.5, blue: 0.9),
                    Color(red: 0.6, green: 0.3, blue: 0.8)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    init(circleCount: Int) {
        self.circleCount = circleCount
    }
    
    var body: some View {
        ZStack {
            // 渐变背景
            backgroundGradient
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.5), value: gameState)
            
            // 背景装饰元素
            GeometryReader { geometry in
                ForEach(0..<5) { index in
                    Circle()
                        .fill(Color.white.opacity(0.05 + Double(index) * 0.01))
                        .frame(width: CGFloat(100 + index * 10), height: CGFloat(100 + index * 10))
                        .position(
                            x: geometry.size.width * getRandomPosition(seed: index + 20),
                            y: geometry.size.height * getRandomPosition(seed: index + 30)
                        )
                        .opacity(isAnimating ? 0.8 : 0.4)
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
                        Text(LocalizedStringKey.roundTime.localized)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text(String(format: "%.1f", timeRemaining) + " " + LocalizedStringKey.seconds.localized)
                            .font(.title3.bold())
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text(LocalizedStringKey.currentScore.localized)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text("\(score)")
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
                    ZStack {
                        // 游戏圆圈
                        ForEach(circles) { circle in
                            Circle()
                                .fill(circle.color)
                                .frame(width: circle.size, height: circle.size)
                                .position(circle.position)
                                .opacity(circle.opacity)
                                .scaleEffect(circle.isNewest && isAnimating ? 1.1 : 1.0)
                                .animation(circle.isNewest ? Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true) : .default, value: isAnimating)
                                .onTapGesture {
                                    handleCircleTap(circle)
                                }
                        }
                        
                        // 粒子效果
                        if showParticles {
                            ParticleEffectView(position: particlePosition)
                                .opacity(showParticles ? 1 : 0)
                        }
                        
                        // 游戏状态信息
                        if gameState == .ready {
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
            }
            
            // 结果导航
            if gameState == .finished {
                NavigationLink(value: "showResult") {
                    EmptyView()
                }
                .opacity(0)
            }
        }
        .fullScreenCover(isPresented: $showResult) {
            LastCircleResultView(
                score: score,
                rounds: round,
                circleCount: circleCount,
                reactionTimes: reactionTimes,
                onDismiss: {
                    // 完全返回到首页
                    dismiss()
                }
            )
            .environmentObject(gameDataManager)
        }
        .onAppear {
            isAnimating = true
        }
        .onDisappear {
            stopTimer()
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            if gameState != .finished {
                dismiss()
            }
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.white)
                .padding(8)
                .background(Circle().fill(Color.white.opacity(0.15)))
        })
    }
    
    // 开始游戏
    private func startGame() {
        gameState = .playing
        round = 0
        score = 0
        circles = []
        reactionTimes = []
        addNewCircle()
    }
    
    // 添加新圆圈
    private func addNewCircle() {
        withAnimation {
            // 重置当前圆圈的 "newest" 标志
            for i in 0..<circles.count {
                circles[i].isNewest = false
                circles[i].size = normalCircleSize
                
                // 随机改变一些现有圆圈的颜色和透明度
                if Double.random(in: 0...1) < 0.3 { // 30% 的概率改变颜色
                    circles[i].color = colors.randomElement() ?? .blue
                }
                
                if Double.random(in: 0...1) < 0.4 { // 40% 的概率降低透明度
                    circles[i].opacity = max(0.3, circles[i].opacity - Double.random(in: 0.1...0.3))
                }
            }
            
            // 限制圆圈数量
            if circles.count >= circleCount {
                circles.removeFirst()
            }
            
            // 生成新圆圈
            let screenWidth = UIScreen.main.bounds.width - 100
            let screenHeight = UIScreen.main.bounds.height - 200
            
            let newPosition = CGPoint(
                x: CGFloat.random(in: 50...screenWidth),
                y: CGFloat.random(in: 100...screenHeight)
            )
            
            let newCircle = GameCircle(
                position: newPosition,
                color: colors.randomElement() ?? .blue,
                opacity: 1.0,
                isNewest: true,
                size: newestCircleSize
            )
            
            circles.append(newCircle)
            round += 1
            
            // 调整时间限制 (随着回合增加而增加)
            let roundFactor = min(2.0, 1.0 + Double(round) / 20.0) // 最多增加到原来的2倍
            timeRemaining = baseTimeLimit * roundFactor
            startTimer()
            startTime = Date()
        }
    }
    
    // 处理圆圈点击
    private func handleCircleTap(_ circle: GameCircle) {
        guard gameState == .playing else { return }
        
        if circle.isNewest {
            // 正确点击
            gameState = .correct
            
            // 计算反应时间
            if let start = startTime {
                let reactionTime = Date().timeIntervalSince(start)
                reactionTimes.append(reactionTime)
                
                // 根据反应速度计算得分
                let basePoints = 100
                let timeBonus = Int(max(0, timeRemaining * 20))
                let roundPoints = basePoints + timeBonus
                score += roundPoints
            }
            
            // 触觉反馈
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            // 显示粒子效果
            particlePosition = circle.position
            showParticles = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showParticles = false
            }
            
            stopTimer()
            
            // 延迟添加下一个圆圈
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                if round < circleCount * 2 { // 最多玩 circleCount * 2 轮
                    gameState = .playing
                    addNewCircle()
                } else {
                    gameOver()
                }
            }
        } else {
            // 错误点击
            gameState = .incorrect
            
            // 触觉反馈 (错误)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            
            stopTimer()
            
            // 延迟后结束游戏
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                gameOver()
            }
        }
    }
    
    // 游戏结束
    private func gameOver() {
        stopTimer()
        gameState = .finished
        
        // 保存分数
        gameDataManager.saveResult(gameType: .lastCircle, score: Double(score), extraData: String(circleCount))
        
        // 显示结果页面
        showResult = true
    }
    
    // 开始计时器
    private func startTimer() {
        stopTimer()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 0.1
            } else {
                // 时间到，游戏结束
                timeRemaining = 0
                gameState = .incorrect
                
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    gameOver()
                }
            }
        }
    }
    
    // 停止计时器
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // 根据种子生成随机位置 (0.1-0.9范围内)
    private func getRandomPosition(seed: Int) -> Double {
        let random = Double(((seed * 1234321) % 80) + 10) / 100.0
        return random
    }
}

// 粒子效果视图
struct ParticleEffectView: View {
    let position: CGPoint
    @State private var particles: [Particle] = []
    
    struct Particle: Identifiable {
        let id = UUID()
        var position: CGPoint
        var color: Color
        var scale: CGFloat
        var speed: CGVector
    }
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: 10, height: 10)
                    .scaleEffect(particle.scale)
                    .position(particle.position)
            }
        }
        .onAppear {
            createParticles()
        }
    }
    
    private func createParticles() {
        for _ in 0..<20 {
            let direction = CGFloat.random(in: 0...2 * .pi)
            let speed = CGFloat.random(in: 1...5)
            let dx = cos(direction) * speed
            let dy = sin(direction) * speed
            
            let particle = Particle(
                position: position,
                color: [.blue, .purple, .cyan, .pink].randomElement() ?? .blue,
                scale: CGFloat.random(in: 0.2...0.7),
                speed: CGVector(dx: dx, dy: dy)
            )
            
            particles.append(particle)
        }
        
        // 粒子动画
        withAnimation(.easeOut(duration: 0.5)) {
            for i in 0..<particles.count {
                let dx = particles[i].speed.dx * 10
                let dy = particles[i].speed.dy * 10
                particles[i].position = CGPoint(
                    x: particles[i].position.x + dx,
                    y: particles[i].position.y + dy
                )
                particles[i].scale = 0
            }
        }
    }
}

#Preview {
    LastCircleGameView(circleCount: 10)
        .environmentObject(GameDataManager())
} 