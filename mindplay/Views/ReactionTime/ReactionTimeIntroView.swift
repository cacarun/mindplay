//
//  ReactionTimeIntroView.swift
//  mindplay
//
//  Created for MindPlay app.
//

import SwiftUI

struct ReactionTimeIntroView: View {
    @EnvironmentObject var gameDataManager: GameDataManager
    @State private var isShowingGame = false
    @State private var roundCount = 3 // 默认回合数为3次
    @State private var isAnimating = false
    
    // 可选的回合次数范围
    private let roundOptions = [1, 3, 5, 10]
    
    // 背景渐变色 - 使用橙色到红色的渐变，呼应反应时间游戏的紧迫感
    private let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 1.0, green: 0.6, blue: 0.3),
            Color(red: 0.95, green: 0.3, blue: 0.2)
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
                    // 装饰性圆形
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 120, height: 120)
                        .position(x: geometry.size.width * 0.85, y: geometry.size.height * 0.15)
                        .offset(y: isAnimating ? -15 : 5)
                        .animation(Animation.easeInOut(duration: 4).repeatForever(autoreverses: true), value: isAnimating)
                    
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 80, height: 80)
                        .position(x: geometry.size.width * 0.2, y: geometry.size.height * 0.85)
                        .offset(y: isAnimating ? 10 : -10)
                        .animation(Animation.easeInOut(duration: 3.5).repeatForever(autoreverses: true), value: isAnimating)
                }
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(LocalizedStringKey.reactionTimeTest.localized)
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 1, y: 1)
                        
                        Text(LocalizedStringKey.testVisualReaction.localized)
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.9))
                            .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .padding(.bottom, 8)
                    
                    // 自定义回合次数
                    VStack(alignment: .leading, spacing: 14) {
                        Text(LocalizedStringKey.roundCount.localized)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        HStack(spacing: 12) {
                            ForEach(roundOptions, id: \.self) { count in
                                Button(action: {
                                    roundCount = count
                                    // 添加轻微的触觉反馈
                                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                    impactMed.impactOccurred()
                                }) {
                                    Text("\(count)")
                                        .font(.headline)
                                        .frame(minWidth: 50, minHeight: 50)
                                        .background(roundCount == count ? 
                                                   Color.white : Color.white.opacity(0.2))
                                        .foregroundColor(roundCount == count ? 
                                                       Color(red: 0.95, green: 0.3, blue: 0.2) : .white)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white.opacity(0.5), lineWidth: roundCount == count ? 2 : 0)
                                        )
                                        .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                                }
                                .scaleEffect(roundCount == count ? 1.1 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: roundCount)
                            }
                            
                            Spacer()
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                    
                    // 最佳成绩和开始按钮
                    HStack(spacing: 15) {
                        // 最佳成绩
                        if let bestScore = gameDataManager.getBestScore(for: .reactionTime) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(LocalizedStringKey.bestScore.localized)
                                    .font(.headline)
                                    .foregroundColor(.white.opacity(0.9))
                                
                                Text(String(format: "%.0f ms", bestScore))
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // 开始测试按钮
                        Button(action: {
                            isShowingGame = true
                            // 添加触觉反馈
                            let impactMed = UIImpactFeedbackGenerator(style: .medium)
                            impactMed.impactOccurred()
                        }) {
                            Text(LocalizedStringKey.startTest.localized)
                                .font(.headline)
                                .foregroundColor(Color(red: 0.95, green: 0.3, blue: 0.2))
                                .frame(height: 55)
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                    
                    // 游戏说明
                    VStack(alignment: .leading, spacing: 18) {
                        Text(LocalizedStringKey.howToPlay.localized)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        instructionItem(number: "1", text: LocalizedStringKey.waitForGreen.localized)
                        instructionItem(number: "2", text: LocalizedStringKey.tapWhenChanges.localized)
                        instructionItem(number: "3", text: LocalizedStringKey.reactionMeasured.localized)
                        instructionItem(number: "4", text: LocalizedStringKey.completeRounds.localized(with: roundCount))
                    }
                    .padding()
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                    
                    // About section
                    VStack(alignment: .leading, spacing: 14) {
                        Text(LocalizedStringKey.aboutTheTest.localized)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(LocalizedStringKey.aboutTestDescription.localized)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                        
                        VStack(alignment: .leading, spacing: 10) {
                            scoreRangeRow(range: "< 200 ms", description: LocalizedStringKey.excellent.localized)
                            scoreRangeRow(range: "200-250 ms", description: LocalizedStringKey.good.localized)
                            scoreRangeRow(range: "250-300 ms", description: LocalizedStringKey.average.localized)
                            scoreRangeRow(range: "> 300 ms", description: LocalizedStringKey.belowAverage.localized)
                        }
                        .padding(.top, 8)
                    }
                    .padding()
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                    
                    Spacer(minLength: 40)
                }
                .padding(.vertical)
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .fullScreenCover(isPresented: $isShowingGame) {
            ReactionTimeGameView(totalRounds: roundCount)
        }
        .onAppear {
            isAnimating = true
        }
    }
    
    private func instructionItem(number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Text(number)
                .font(.headline)
                .foregroundColor(Color(red: 0.95, green: 0.3, blue: 0.2))
                .frame(width: 36, height: 36)
                .background(Color.white)
                .clipShape(Circle())
            
            Text(text)
                .font(.body)
                .foregroundColor(.white)
            
            Spacer()
        }
    }
    
    private func scoreRangeRow(range: String, description: String) -> some View {
        HStack {
            Text(range)
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 100, alignment: .leading)
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        ReactionTimeIntroView()
            .environmentObject(GameDataManager())
    }
}
