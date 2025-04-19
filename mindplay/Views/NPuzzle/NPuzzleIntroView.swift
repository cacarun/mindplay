//
//  NPuzzleIntroView.swift
//  mindplay
//
//  Created for MindPlay app.
//

import SwiftUI

struct NPuzzleIntroView: View {
    @EnvironmentObject var gameDataManager: GameDataManager
    @State private var selectedGridSize: Int = 3
    @State private var isAnimating = false
    @State private var isShowingGame = false
    
    // 可选的网格大小
    private let gridSizes = [3, 4, 5]
    
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
                ForEach(0..<8) { index in
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.1 + Double(index) * 0.01))
                        .frame(width: CGFloat(50 + index * 5), height: CGFloat(50 + index * 5))
                        .position(
                            x: geometry.size.width * getRandomPosition(seed: index),
                            y: geometry.size.height * getRandomPosition(seed: index + 10)
                        )
                        .rotationEffect(.degrees(isAnimating ? Double(index * 10) : 0))
                        .animation(
                            Animation.easeInOut(duration: Double(3 + index)).repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                }
            }
            
            // 主内容
            ScrollView {
                VStack(spacing: 25) {
                    // 标题区域
                    VStack(spacing: 8) {
                        Text(LocalizedStringKey.nPuzzleTest.localized)
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.2), radius: 2, x: 1, y: 1)
                            .multilineTextAlignment(.center)
                            .padding(.top, 30)
                        
                        Text(LocalizedStringKey.moveTiles.localized)
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                    }
                    .padding(.bottom, 10)
                    .scaleEffect(isAnimating ? 1.0 : 0.95)
                    .animation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
                    
                    // 游戏设置卡片
                    VStack(spacing: 15) {
                        Text(LocalizedStringKey.gridSize.localized)
                            .font(.headline)
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                        
                        // 网格大小选择
                        HStack(spacing: 20) {
                            ForEach(gridSizes, id: \.self) { size in
                                Button(action: {
                                    selectedGridSize = size
                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                    generator.impactOccurred()
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(selectedGridSize == size ? Color.white : Color.white.opacity(0.3))
                                            .frame(width: 70, height: 70)
                                            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                                        
                                        Text("\(size)×\(size)")
                                            .font(.system(size: 24, weight: .bold))
                                            .foregroundColor(selectedGridSize == size ? 
                                                           Color(red: 0.1, green: 0.6, blue: 0.7) : .white)
                                    }
                                }
                                .scaleEffect(selectedGridSize == size ? 1.1 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedGridSize)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                    .padding(.horizontal)
                    
                    // 最佳成绩和开始按钮卡片
                    VStack(spacing: 20) {
                        // 最佳成绩
                        if let bestScore = gameDataManager.getBestScore(for: .nPuzzle, with: String(selectedGridSize)) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(LocalizedStringKey.bestScore.localized)
                                        .font(.headline)
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    Text(formatTime(seconds: Int(bestScore)))
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.white)
                                        .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
                                }
                                
                                Spacer()
                                
                                // 奖杯图标
                                Image(systemName: "trophy.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.yellow)
                                    .shadow(color: Color.black.opacity(0.2), radius: 2, x: 1, y: 1)
                                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                                    .animation(
                                        Animation.easeInOut(duration: 1.5)
                                            .repeatForever(autoreverses: true),
                                        value: isAnimating
                                    )
                            }
                            .padding()
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                            .padding(.horizontal)
                        }
                        
                        // 开始测试按钮
                        NavigationLink(destination: NPuzzleGameView(gridSize: selectedGridSize)) {
                            HStack {
                                Image(systemName: "play.fill")
                                    .font(.headline)
                                
                                Text(LocalizedStringKey.startPuzzle.localized)
                                    .font(.headline)
                            }
                            .foregroundColor(Color(red: 0.1, green: 0.6, blue: 0.7))
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 3)
                        }
                        .padding(.horizontal)
                        .buttonStyle(PlainButtonStyle())
                        .scaleEffect(isAnimating ? 1.05 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 1.8)
                                .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                    }
                    
                    // 游戏说明卡片
                    VStack(alignment: .leading, spacing: 20) {
                        Text(LocalizedStringKey.howToPlay.localized)
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .padding(.bottom, 5)
                        
                        // 游戏说明步骤
                        VStack(spacing: 15) {
                            instructionItem(
                                icon: "square.and.arrow.up.on.square",
                                text: LocalizedStringKey.nPuzzleRule1.localized
                            )
                            
                            instructionItem(
                                icon: "arrow.up.and.down.and.arrow.left.and.right",
                                text: LocalizedStringKey.nPuzzleRule2.localized
                            )
                            
                            instructionItem(
                                icon: "rectangle.grid.1x2",
                                text: LocalizedStringKey.nPuzzleRule3.localized
                            )
                            
                            instructionItem(
                                icon: "stopwatch",
                                text: LocalizedStringKey.nPuzzleRule4.localized
                            )
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                    .padding(.horizontal)
                    
                    // 关于测试卡片
                    VStack(alignment: .leading, spacing: 15) {
                        Text(LocalizedStringKey.aboutNPuzzleTest.localized)
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .padding(.bottom, 5)
                        
                        Text(LocalizedStringKey.nPuzzleDescription.localized)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.bottom, 5)
                        
                        Text(LocalizedStringKey.nPuzzleExplanation.localized)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.bottom, 10)
                        
                        // 评级标准
                        VStack(alignment: .leading, spacing: 10) {
                            Text(LocalizedStringKey.performanceLevel.localized)
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.bottom, 5)
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    scoreRangeItem(range: "< 30s", description: LocalizedStringKey.excellent.localized)
                                    scoreRangeItem(range: "30-60s", description: LocalizedStringKey.good.localized)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    scoreRangeItem(range: "60-120s", description: LocalizedStringKey.average.localized)
                                    scoreRangeItem(range: "> 120s", description: LocalizedStringKey.belowAverage.localized)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(15)
                    }
                    .padding()
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                    .padding(.horizontal)
                    
                    Spacer(minLength: 30)
                }
                .padding(.bottom, 30)
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .onAppear {
            isAnimating = true
        }
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
    
    // 游戏说明项
    private func instructionItem(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(Color.white.opacity(0.2))
                .clipShape(Circle())
            
            Text(text)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
    
    // 评级项目
    private func scoreRangeItem(range: String, description: String) -> some View {
        HStack(spacing: 10) {
            Text(range)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .frame(width: 60, alignment: .center)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.2))
                .cornerRadius(8)
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
        }
    }
}

#Preview {
    NavigationStack {
        NPuzzleIntroView()
            .environmentObject(GameDataManager())
    }
} 