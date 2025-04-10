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
    
    // 游戏状态
    @State private var isGameStarted = false
    @State private var isGameFinished = false
    @State private var targetPosition = CGPoint(x: 0.5, y: 0.5)
    @State private var targetSize: CGFloat = 60
    @State private var targetsRemaining = 30
    @State private var targetsHit = 0
    @State private var navigateToResults = false
    
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
    
    var body: some View {
        VStack {
            // 状态区域
            VStack(spacing: 5) {
                if isGameStarted {
                    Text(String(format: LocalizedStringKey.targetsRemaining.localized, targetsRemaining))
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.top)
                } else if !isGameFinished {
                    Text(LocalizedStringKey.clickToBegin.localized)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.top)
                }
            }
            .frame(height: 50)
            
            // 游戏区域
            ZStack {
                // 游戏区域背景
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                if !isGameFinished {
                    // 目标
                    TargetView(size: targetSize)
                        .position(
                            x: targetPosition.x * gameAreaSize.width,
                            y: targetPosition.y * gameAreaSize.height
                        )
                        .opacity(isGameStarted ? 1 : 0.7)
                        .animation(.easeOut(duration: targetAppearDuration), value: targetPosition)
                        .onTapGesture {
                            if !isGameStarted {
                                startGame()
                            } else {
                                handleTargetHit()
                            }
                        }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToResults) {
            AimTrainerResultView(
                onDismiss: { dismiss() },
                onRestart: {
                    // 重置游戏状态并开始新游戏
                    isGameStarted = false
                    isGameFinished = false
                    targetPosition = CGPoint(x: 0.5, y: 0.5)
                    targetsRemaining = 30
                    targetsHit = 0
                    startTime = nil
                    hitTimes = []
                },
                totalTimeElapsed: totalTimeElapsed,
                hitTimes: hitTimes
            )
        }
        .onAppear {
            // 调整目标大小根据屏幕尺寸
            let minDimension = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
            targetSize = minDimension * 0.12
        }
    }
    
    // 开始游戏
    private func startGame() {
        isGameStarted = true
        startTime = Date()
        targetsHit = 0
        targetsRemaining = 30
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
        
        // 保存游戏结果 (平均每个目标的时间，毫秒)
        if !hitTimes.isEmpty {
            let avgTime = totalTimeElapsed / Double(hitTimes.count) * 1000
            gameDataManager.saveResult(gameType: .aimTrainer, score: avgTime)
        }
        
        // 导航到结果页面
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            navigateToResults = true
        }
    }
}

// 目标视图
struct TargetView: View {
    var size: CGFloat
    
    var body: some View {
        ZStack {
            // 外环
            Circle()
                .fill(Color.red)
                .frame(width: size, height: size)
            
            // 中环
            Circle()
                .stroke(Color.white, lineWidth: 2)
                .frame(width: size * 0.75, height: size * 0.75)
            
            // 内环
            Circle()
                .stroke(Color.white, lineWidth: 1)
                .frame(width: size * 0.5, height: size * 0.5)
            
            // 中心点
            Circle()
                .fill(Color.white)
                .frame(width: size * 0.15, height: size * 0.15)
        }
    }
}

#Preview {
    NavigationStack {
        AimTrainerGameView()
            .environmentObject(GameDataManager())
    }
} 