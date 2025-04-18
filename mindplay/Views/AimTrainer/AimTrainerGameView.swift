//
//  AimTrainerGameView.swift
//  mindplay
//
//  Created for MindPlay app.
//

import SwiftUI

struct AimTrainerGameView: View {
    @EnvironmentObject var gameDataManager: GameDataManager
    @Environment(\.displayScale) private var displayScale
    @Environment(\.dismiss) private var dismiss
    
    // 添加参数以接收自定义目标数量
    let totalTargets: Int
    
    // 游戏状态
    @State private var isGameStarted = false
    @State private var isGameFinished = false
    @State private var targetPosition = CGPoint(x: 0.5, y: 0.5)
    @State private var targetSize: CGFloat = 60
    @State private var targetsRemaining: Int = 0
    @State private var targetsHit = 0
    @State private var navigateToResults = false
    @State private var isAnimating = false
    @State private var showHitEffect = false
    @State private var hitEffectPosition: CGPoint = .zero
    
    // 计时器
    @State private var startTime: Date? = nil
    @State private var totalTimeElapsed: TimeInterval = 0
    @State private var hitTimes: [TimeInterval] = []
    
    // 游戏区域
    @State private var gameAreaSize: CGSize = .zero
    
    // 目标可用区域的边缘填充
    private let edgePadding: CGFloat = 40
    
    // 动画持续时间
    private let targetAppearDuration: Double = 0.2
    
    // 背景渐变色 - 使用绿色和蓝色渐变表示瞄准和准确性
    private let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.2, green: 0.7, blue: 0.4),
            Color(red: 0.1, green: 0.5, blue: 0.9)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // 添加默认构造函数
    init(totalTargets: Int = 30) {
        self.totalTargets = totalTargets
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
                    ForEach(0..<3, id: \.self) { i in
                        let sizes: [CGFloat] = [80, 60, 100]
                        let posX: [CGFloat] = [0.1, 0.9, 0.15]
                        let posY: [CGFloat] = [0.2, 0.25, 0.85]
                        let rotations: [Double] = [10, -8, 15]
                        let durations: [Double] = [6, 5, 7]
                        
                        Circle()
                            .stroke(Color.white.opacity(0.08), lineWidth: 2)
                            .frame(width: sizes[i], height: sizes[i])
                            .position(
                                x: geometry.size.width * posX[i],
                                y: geometry.size.height * posY[i]
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
            
            VStack(spacing: 0) {
                // 状态区域
                VStack(spacing: 10) {
                    if isGameStarted {
                        // 游戏进度指示
                        HStack {
                            // 剩余目标
                            VStack(alignment: .leading, spacing: 4) {
                                Text(LocalizedStringKey.targetsRemaining.localized)
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.9))
                                
                                Text("\(targetsRemaining)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            // 已击中目标
                            VStack(alignment: .trailing, spacing: 4) {
                                Text(LocalizedStringKey.targetHit.localized)
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.9))
                                
                                Text("\(targetsHit)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        // 进度条
                        ZStack(alignment: .leading) {
                            // 背景条
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 10)
                            
                            // 进度条
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white)
                                .frame(width: progressWidth, height: 10)
                                .animation(.spring(), value: targetsHit)
                        }
                        .padding(.horizontal)
                        .padding(.top, 5)
                    } else if !isGameFinished {
                        Text(LocalizedStringKey.clickToBegin.localized)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top, 30)
                            .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
                    }
                }
                .frame(height: isGameStarted ? 110 : 80)
                
                // 游戏区域
                ZStack {
                    // 游戏区域背景
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.1))
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    if !isGameFinished {
                        // 目标
                        TargetView(size: targetSize)
                            .position(
                                x: targetPosition.x * gameAreaSize.width,
                                y: targetPosition.y * gameAreaSize.height
                            )
                            .opacity(isGameStarted ? 1 : 0.7)
                            .scaleEffect(isGameStarted ? 1.0 : 1.2)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: targetPosition)
                            .onTapGesture {
                                if !isGameStarted {
                                    startGame()
                                } else {
                                    hitEffectPosition = CGPoint(
                                        x: targetPosition.x * gameAreaSize.width,
                                        y: targetPosition.y * gameAreaSize.height
                                    )
                                    withAnimation {
                                        showHitEffect = true
                                    }
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        showHitEffect = false
                                    }
                                    
                                    handleTargetHit()
                                }
                            }
                    }
                    
                    // 点击效果
                    if showHitEffect {
                        ZStack {
                            ForEach(0..<8) { i in
                                Rectangle()
                                    .fill(Color.white)
                                    .frame(width: 3, height: 10)
                                    .offset(y: -15)
                                    .rotationEffect(.degrees(Double(i) * 45))
                            }
                        }
                        .position(hitEffectPosition)
                        .scaleEffect(showHitEffect ? 1.5 : 0.5)
                        .opacity(showHitEffect ? 0 : 1)
                        .animation(.easeOut(duration: 0.3), value: showHitEffect)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal)
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .onAppear {
                                gameAreaSize = geometry.size
                                // 初始化第一个目标位置为中心位置
                                targetPosition = CGPoint(x: 0.5, y: 0.5)
                            }
                            .onChange(of: geometry.size) { newSize in
                                gameAreaSize = newSize
                            }
                    }
                )
                
                // 底部区域 - 只在游戏未开始时显示
                if !isGameStarted && !isGameFinished {
                    Button(action: {
                        startGame()
                        // 添加触觉反馈
                        let impactMed = UIImpactFeedbackGenerator(style: .medium)
                        impactMed.impactOccurred()
                    }) {
                        Text(LocalizedStringKey.tapToStart.localized)
                            .font(.headline)
                            .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.4))
                            .frame(height: 55)
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                } else {
                    Spacer().frame(height: 20)
                }
            }
            .padding(.bottom)
            
            // 游戏结束覆盖
            if isGameFinished {
                gameFinishedOverlay
            }
        }
        .fullScreenCover(isPresented: $navigateToResults) {
            AimTrainerResultView(
                onDismiss: { dismiss() },
                onRestart: {
                    // 重置游戏状态并开始新游戏
                    isGameStarted = false
                    isGameFinished = false
                    targetPosition = CGPoint(x: 0.5, y: 0.5)
                    targetsRemaining = totalTargets
                    targetsHit = 0
                    startTime = nil
                    hitTimes = []
                },
                totalTimeElapsed: totalTimeElapsed,
                hitTimes: hitTimes
            )
        }
        .navigationBarHidden(true)
        .onAppear {
            // 调整目标大小根据屏幕尺寸
            let minDimension = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
            targetSize = minDimension * 0.12
            isAnimating = true
        }
    }
    
    // 游戏结束覆盖层
    private var gameFinishedOverlay: some View {
        ZStack {
            // 半透明背景
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // 完成信息
                Text(LocalizedStringKey.completed.localized)
                    .font(.system(size: 38, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 2)
                
                // 统计信息
                VStack(spacing: 15) {
                    HStack(spacing: 40) {
                        // 总时间
                        VStack {
                            Text(String(format: "%.1f", totalTimeElapsed))
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(LocalizedStringKey.seconds.localized)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        // 平均时间
                        VStack {
                            Text(String(format: "%.0f", totalTimeElapsed / Double(totalTargets) * 1000))
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(LocalizedStringKey.avgTimePerTarget.localized)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
                .padding(.vertical, 20)
                
                Button(action: {
                    navigateToResults = true
                    // 添加触觉反馈
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()
                }) {
                    Text(LocalizedStringKey.seeResults.localized)
                        .font(.headline)
                        .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.4))
                        .padding()
                        .frame(width: 200)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
                }
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 40)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color(red: 0.2, green: 0.5, blue: 0.7).opacity(0.9))
                    .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            )
            .scaleEffect(isGameFinished ? 1.0 : 0.5)
            .opacity(isGameFinished ? 1.0 : 0)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isGameFinished)
            .padding(.horizontal, 30)
        }
    }
    
    // 计算进度条宽度的属性
    private var progressWidth: CGFloat {
        let maxWidth = UIScreen.main.bounds.width - 32 // 减去padding
        let percentage = CGFloat(targetsHit) / CGFloat(totalTargets)
        return maxWidth * percentage
    }
    
    // 开始游戏
    private func startGame() {
        isGameStarted = true
        startTime = Date()
        targetsHit = 0
        targetsRemaining = totalTargets
        hitTimes = []
        
        // 第一个目标位置随机生成
        moveTargetToRandomPosition()
    }
    
    // 处理目标被点击
    private func handleTargetHit() {
        // 计算这次点击的时间
        if let startTime = startTime {
            let hitTime = Date().timeIntervalSince(startTime)
            hitTimes.append(hitTime)
        }
        
        // 更新状态
        targetsHit += 1
        targetsRemaining -= 1
        
        // 播放触觉反馈
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        if targetsRemaining > 0 {
            // 移动目标到新位置
            moveTargetToRandomPosition()
        } else {
            // 游戏结束
            finishGame()
        }
    }
    
    // 将目标移动到随机位置
    private func moveTargetToRandomPosition() {
        // 计算可用区域
        let paddingX = edgePadding + targetSize / 2
        let paddingY = edgePadding + targetSize / 2
        
        let xRange = paddingX/gameAreaSize.width...1 - (paddingX/gameAreaSize.width)
        let yRange = paddingY/gameAreaSize.height...1 - (paddingY/gameAreaSize.height)
        
        // 生成新的随机位置，确保与当前位置不同
        var newX = CGFloat.random(in: xRange)
        var newY = CGFloat.random(in: yRange)
        
        // 确保新位置与当前位置相差足够远
        while sqrt(pow(newX - targetPosition.x, 2) + pow(newY - targetPosition.y, 2)) < 0.2 {
            newX = CGFloat.random(in: xRange)
            newY = CGFloat.random(in: yRange)
        }
        
        targetPosition = CGPoint(x: newX, y: newY)
    }
    
    // 结束游戏
    private func finishGame() {
        isGameFinished = true
        
        // 计算总时间
        if let startTime = startTime {
            totalTimeElapsed = Date().timeIntervalSince(startTime)
        }
        
        // 播放完成触觉反馈
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.success)
        
        // 保存游戏结果 (平均每个目标的时间，毫秒)
        if !hitTimes.isEmpty {
            let avgTime = totalTimeElapsed / Double(hitTimes.count) * 1000
            gameDataManager.saveResult(gameType: .aimTrainer, score: avgTime)
        }
    }
}

// 目标视图
struct TargetView: View {
    var size: CGFloat
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // 外环 - 脉冲动画
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                .frame(width: size * 1.2, height: size * 1.2)
                .scaleEffect(isAnimating ? 1.2 : 1.0)
                .opacity(isAnimating ? 0.0 : 0.3)
                .animation(
                    Animation.easeInOut(duration: 1.2)
                        .repeatForever(autoreverses: false),
                    value: isAnimating
                )
            
            // 外环
            Circle()
                .fill(Color.white.opacity(0.05))
                .frame(width: size, height: size)
            
            // 主环
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(red: 1.0, green: 0.3, blue: 0.3),
                            Color(red: 0.8, green: 0.1, blue: 0.1)
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: size / 2
                    )
                )
                .frame(width: size * 0.85, height: size * 0.85)
                .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 2)
            
            // 中环
            Circle()
                .stroke(Color.white, lineWidth: 2)
                .frame(width: size * 0.6, height: size * 0.6)
            
            // 内环
            Circle()
                .fill(Color.white)
                .frame(width: size * 0.3, height: size * 0.3)
                .shadow(color: Color.white.opacity(0.5), radius: 5, x: 0, y: 0)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    NavigationStack {
        AimTrainerGameView()
            .environmentObject(GameDataManager())
    }
} 