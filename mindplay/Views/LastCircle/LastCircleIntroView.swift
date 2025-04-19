//
//  LastCircleIntroView.swift
//  mindplay
//
//  Created for MindPlay app.
//

import SwiftUI

struct LastCircleIntroView: View {
    @EnvironmentObject var gameDataManager: GameDataManager
    @State private var selectedCircleCount: Int = 10
    @State private var isAnimating = false
    @State private var isShowingGame = false
    @Environment(\.presentationMode) var presentationMode
    
    // 可选择的圆圈数量
    private let circleCounts = [8, 10, 12, 15, 20]
    
    // 背景渐变
    private let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.3, green: 0.6, blue: 0.9),
            Color(red: 0.5, green: 0.2, blue: 0.8)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        ZStack {
            // 渐变背景
            backgroundGradient
                .ignoresSafeArea()
            
            // 背景装饰元素 - 动画圆圈
            GeometryReader { geometry in
                ForEach(0..<8) { index in
                    Circle()
                        .fill(Color.white.opacity(0.1 + Double(index) * 0.01))
                        .frame(width: CGFloat(40 + index * 5), height: CGFloat(40 + index * 5))
                        .position(
                            x: geometry.size.width * getRandomPosition(seed: index),
                            y: geometry.size.height * getRandomPosition(seed: index + 10)
                        )
                        .offset(y: isAnimating ? CGFloat(10 + index * 2) : CGFloat(-10 - index * 2))
                        .animation(
                            Animation.easeInOut(duration: Double(3 + index)).repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                }
            }
            
            // 返回按钮
            VStack {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                    .padding(.leading, 16)
                    .padding(.top, 16)
                    
                    Spacer()
                }
                
                Spacer()
            }
            .zIndex(1)
            
            // 主内容
            ScrollView {
                VStack(spacing: 25) {
                    // 标题区域
                    VStack(spacing: 8) {
                        Text(LocalizedStringKey.lastCircleTest.localized)
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.2), radius: 2, x: 1, y: 1)
                            .multilineTextAlignment(.center)
                            .padding(.top, 30)
                        
                        Text(LocalizedStringKey.tapNewestCircle.localized)
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
                        Text(LocalizedStringKey.circlesCount.localized)
                            .font(.headline)
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                        
                        // 圆圈数量选择
                        HStack(spacing: 15) {
                            ForEach(circleCounts, id: \.self) { count in
                                Button(action: {
                                    selectedCircleCount = count
                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                    generator.impactOccurred()
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(selectedCircleCount == count ? Color.white : Color.white.opacity(0.3))
                                            .frame(width: 52, height: 52)
                                            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                                        
                                        Text("\(count)")
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(selectedCircleCount == count ? 
                                                            Color(red: 0.3, green: 0.6, blue: 0.9) : .white)
                                    }
                                }
                                .scaleEffect(selectedCircleCount == count ? 1.1 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedCircleCount)
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
                        if let bestScore = gameDataManager.getBestScore(for: .lastCircle, with: String(selectedCircleCount)) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(LocalizedStringKey.bestScore.localized)
                                        .font(.headline)
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    Text("\(Int(bestScore))")
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
                        NavigationLink(destination: LastCircleGameView(circleCount: selectedCircleCount)) {
                            HStack {
                                Image(systemName: "play.fill")
                                    .font(.headline)
                                
                                Text(LocalizedStringKey.startRound.localized)
                                    .font(.headline)
                            }
                            .foregroundColor(Color(red: 0.3, green: 0.6, blue: 0.9))
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
                                icon: "circle",
                                text: LocalizedStringKey.lastCircleRule1.localized
                            )
                            
                            instructionItem(
                                icon: "hand.tap",
                                text: LocalizedStringKey.lastCircleRule2.localized
                            )
                            
                            instructionItem(
                                icon: "clock",
                                text: LocalizedStringKey.lastCircleRule3.localized
                            )
                            
                            instructionItem(
                                icon: "brain",
                                text: LocalizedStringKey.lastCircleRule4.localized
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
                        Text(LocalizedStringKey.aboutLastCircleTest.localized)
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .padding(.bottom, 5)
                        
                        Text(LocalizedStringKey.lastCircleDescription.localized)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.bottom, 5)
                        
                        Text(LocalizedStringKey.scoreExplanation.localized)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.bottom, 10)
                        
                        // 评级标准
                        VStack(alignment: .leading, spacing:
                            10) {
                            Text(LocalizedStringKey.performanceLevel.localized)
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.bottom, 5)
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    scoreRangeItem(range: "> 20", description: LocalizedStringKey.excellent.localized)
                                    scoreRangeItem(range: "15-20", description: LocalizedStringKey.good.localized)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    scoreRangeItem(range: "10-14", description: LocalizedStringKey.average.localized)
                                    scoreRangeItem(range: "< 10", description: LocalizedStringKey.belowAverage.localized)
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
        .navigationBarHidden(true)
        .onAppear {
            isAnimating = true
        }
    }
    
    // 根据种子生成随机位置 (0.1-0.9范围内)
    private func getRandomPosition(seed: Int) -> Double {
        let random = Double(((seed * 1234321) % 80) + 10) / 100.0
        return random
    }
    
    // 获取最佳分数文本
    private func getBestScoreText() -> String {
        if let bestScore = gameDataManager.getBestScore(for: .lastCircle, with: String(selectedCircleCount)) {
            return String(format: "%.0f", bestScore)
        } else {
            return LocalizedStringKey.noData.localized
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
        LastCircleIntroView()
            .environmentObject(GameDataManager())
    }
} 