//
//  ChimpTestIntroView.swift
//  mindplay
//
//  Created for MindPlay app.
//

import SwiftUI

struct ChimpTestIntroView: View {
    @EnvironmentObject var gameDataManager: GameDataManager
    @State private var isShowingGame = false
    @State private var isAnimating = false
    
    // 猩猩测试的主题色 - 使用蓝绿色和蓝色组合
    private let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.2, green: 0.6, blue: 0.8),
            Color(red: 0.1, green: 0.3, blue: 0.7)
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
                    // 添加一些装饰性圆形
                    ForEach(0..<6) { i in
                        let positions = [
                            CGPoint(x: geometry.size.width * 0.1, y: geometry.size.height * 0.2),
                            CGPoint(x: geometry.size.width * 0.85, y: geometry.size.height * 0.15),
                            CGPoint(x: geometry.size.width * 0.25, y: geometry.size.height * 0.8),
                            CGPoint(x: geometry.size.width * 0.7, y: geometry.size.height * 0.75),
                            CGPoint(x: geometry.size.width * 0.5, y: geometry.size.height * 0.5),
                            CGPoint(x: geometry.size.width * 0.9, y: geometry.size.height * 0.6)
                        ]
                        
                        let sizes: [CGFloat] = [100, 80, 120, 90, 70, 110]
                        let opacities: [Double] = [0.1, 0.08, 0.12, 0.07, 0.1, 0.09]
                        let rotations: [Double] = [0, 45, 90, 135, 180, 225]
                        let rotationValues: [Double] = [15, -10, 12, -8, 10, -12]
                        
                        // 添加数字方块装饰
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(opacities[i]), lineWidth: 2)
                                .frame(width: sizes[i], height: sizes[i])
                            
                            if i < 3 {
                                // 只在部分方块中显示数字
                                Text("\(i + 1)")
                                    .font(.system(size: sizes[i] * 0.4, weight: .bold))
                                    .foregroundColor(.white.opacity(opacities[i] * 1.5))
                            }
                        }
                        .position(positions[i])
                        .rotationEffect(.degrees(rotations[i]))
                        .rotationEffect(.degrees(isAnimating ? rotationValues[i] : 0))
                        .animation(
                            Animation.easeInOut(duration: Double.random(in: 5...8))
                                .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                    }
                    
                    // 悬浮的猩猩图标
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 65))
                        .foregroundColor(.white.opacity(0.2))
                        .position(x: geometry.size.width * 0.8, y: geometry.size.height * 0.3)
                        .rotationEffect(.degrees(isAnimating ? 8 : -8))
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
                        Text(LocalizedStringKey.chimpTest.localized)
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 1, y: 1)
                        
                        Text(LocalizedStringKey.smarterThanChimp.localized)
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
                    
                    // 最佳成绩和开始按钮卡片
                    VStack(spacing: 20) {
                        // 最佳成绩
                        if let bestScore = gameDataManager.getBestScore(for: .chimpTest) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(LocalizedStringKey.bestScore.localized)
                                        .font(.headline)
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    Text("\(Int(bestScore))")
                                        .font(.system(size: 32, weight: .bold))
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
                            .foregroundColor(Color(red: 0.1, green: 0.3, blue: 0.7))
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
                                icon: "brain",
                                text: LocalizedStringKey.memorizeNumbers.localized
                            )
                            
                            instructionItem(
                                icon: "eye.slash",
                                text: LocalizedStringKey.numbersDisappear.localized
                            )
                            
                            instructionItem(
                                icon: "hand.tap",
                                text: LocalizedStringKey.clickInOrder.localized
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
                        Text(LocalizedStringKey.aboutChimpTest.localized)
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .padding(.bottom, 5)
                        
                        Text(LocalizedStringKey.chimpTestDescription.localized)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.bottom, 5)
                        
                        Text(LocalizedStringKey.chimpOutperformHumans.localized)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.bottom, 5)
                        
                        Text(LocalizedStringKey.chimpTestRules.localized)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.bottom, 10)
                        
                        // 评级标准
                        VStack(alignment: .leading, spacing: 10) {
                            Text("评级标准")
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
            ChimpTestGameView()
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
        ChimpTestIntroView()
            .environmentObject(GameDataManager())
    }
} 