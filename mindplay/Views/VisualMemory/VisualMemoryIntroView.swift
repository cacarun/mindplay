//
//  VisualMemoryIntroView.swift
//  mindplay
//
//  Created for MindPlay app.
//

import SwiftUI

struct VisualMemoryIntroView: View {
    @EnvironmentObject var gameDataManager: GameDataManager
    @State private var isShowingGame = false
    @State private var selectedGridSize = 3 // 默认网格大小为3x3
    @State private var isAnimating = false
    
    // 可选的网格大小范围
    private let gridOptions = [3, 4, 5]
    
    // 视觉记忆游戏的主题渐变色 - 紫色/靛蓝色
    private let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.4, green: 0.2, blue: 0.8),
            Color(red: 0.2, green: 0.3, blue: 0.7)
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
                ZStack {
                    // 添加一些装饰性方块，代表记忆格子
                    ForEach(0..<8) { i in
                        let positions = [
                            CGPoint(x: geometry.size.width * 0.1, y: geometry.size.height * 0.2),
                            CGPoint(x: geometry.size.width * 0.85, y: geometry.size.height * 0.15),
                            CGPoint(x: geometry.size.width * 0.25, y: geometry.size.height * 0.8),
                            CGPoint(x: geometry.size.width * 0.75, y: geometry.size.height * 0.75),
                            CGPoint(x: geometry.size.width * 0.15, y: geometry.size.height * 0.4),
                            CGPoint(x: geometry.size.width * 0.9, y: geometry.size.height * 0.6),
                            CGPoint(x: geometry.size.width * 0.6, y: geometry.size.height * 0.1),
                            CGPoint(x: geometry.size.width * 0.5, y: geometry.size.height * 0.9)
                        ]
                        
                        let sizes: [CGFloat] = [60, 70, 50, 65, 55, 45, 50, 60]
                        let opacities: [Double] = [0.15, 0.1, 0.12, 0.08, 0.12, 0.1, 0.14, 0.09]
                        
                        // 记忆方块装饰
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(opacities[i]))
                            .frame(width: sizes[i], height: sizes[i])
                            .position(positions[i])
                            .rotationEffect(.degrees(isAnimating ? Double(i * 5) : 0))
                            .opacity(isAnimating ? 1.0 : 0.7)
                            .animation(
                                Animation.easeInOut(duration: Double.random(in: 3...6))
                                    .repeatForever(autoreverses: true)
                                    .delay(Double.random(in: 0...1)),
                                value: isAnimating
                            )
                    }
                    
                    // 记忆图标
                    Image(systemName: "brain")
                        .font(.system(size: 60))
                        .foregroundColor(.white.opacity(0.2))
                        .position(x: geometry.size.width * 0.8, y: geometry.size.height * 0.3)
                        .rotationEffect(.degrees(isAnimating ? 10 : -10))
                        .animation(
                            Animation.easeInOut(duration: 4)
                                .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                }
            }
            
            ScrollView {
                VStack(spacing: 25) {
                    // 顶部标题
                    VStack(spacing: 8) {
                        Text(LocalizedStringKey.visualMemoryTest.localized)
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 1, y: 1)
                        
                        Text(LocalizedStringKey.memorizeSquares.localized)
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                    }
                    .padding(.top, 30)
                    .scaleEffect(isAnimating ? 1.0 : 0.95)
                    .animation(
                        Animation.easeInOut(duration: 2)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                    
                    // 选择网格大小
                    VStack(spacing: 15) {
                        Text(LocalizedStringKey.startingGridSize.localized)
                            .font(.headline)
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                        
                        HStack(spacing: 15) {
                            ForEach(gridOptions, id: \.self) { size in
                                Button(action: {
                                    // 触觉反馈
                                    let impactMed = UIImpactFeedbackGenerator(style: .light)
                                    impactMed.impactOccurred()
                                    selectedGridSize = size
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(selectedGridSize == size ? Color.white : Color.white.opacity(0.3))
                                            .frame(width: 70, height: 70)
                                            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                                        
                                        Text("\(size)×\(size)")
                                            .font(.system(size: 22, weight: .bold))
                                            .foregroundColor(selectedGridSize == size ? Color(red: 0.4, green: 0.2, blue: 0.8) : .white)
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
                        if let bestScore = gameDataManager.getBestScore(for: .visualMemory) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(LocalizedStringKey.bestScore.localized)
                                        .font(.headline)
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    Text("\(LocalizedStringKey.level.localized): \(Int(bestScore))")
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
                        Button(action: {
                            // 触觉反馈
                            let impactMed = UIImpactFeedbackGenerator(style: .medium)
                            impactMed.impactOccurred()
                            isShowingGame = true
                        }) {
                            HStack {
                                Image(systemName: "play.fill")
                                    .font(.headline)
                                
                                Text(LocalizedStringKey.startTest.localized)
                                    .font(.headline)
                            }
                            .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.8))
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 3)
                        }
                        .padding(.horizontal)
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
                                icon: "square.fill",
                                text: LocalizedStringKey.tilesFlashWhite.localized
                            )
                            
                            instructionItem(
                                icon: "brain.head.profile",
                                text: LocalizedStringKey.memorizeAndPick.localized
                            )
                            
                            instructionItem(
                                icon: "arrow.up.forward",
                                text: LocalizedStringKey.levelProgressivelyHarder.localized
                            )
                            
                            instructionItem(
                                icon: "heart",
                                text: LocalizedStringKey.missThreeTilesLoseLife.localized
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
                        Text(LocalizedStringKey.aboutTheTest.localized)
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .padding(.bottom, 5)
                        
                        Text(LocalizedStringKey.visualMemoryExplanation1.localized)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.bottom, 5)
                        
                        Text(LocalizedStringKey.visualMemoryExplanation2.localized)
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
                                    scoreRangeItem(range: "> 12", description: LocalizedStringKey.excellent.localized)
                                    scoreRangeItem(range: "9-12", description: LocalizedStringKey.good.localized)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    scoreRangeItem(range: "6-8", description: LocalizedStringKey.average.localized)
                                    scoreRangeItem(range: "< 6", description: LocalizedStringKey.belowAverage.localized)
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
        .fullScreenCover(isPresented: $isShowingGame) {
            VisualMemoryGameView(gridSize: selectedGridSize)
        }
    }
    
    // 指导项
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
                .frame(width: 45, alignment: .center)
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
        VisualMemoryIntroView()
            .environmentObject(GameDataManager())
    }
} 