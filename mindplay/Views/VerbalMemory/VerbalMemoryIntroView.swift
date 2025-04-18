//
//  VerbalMemoryIntroView.swift
//  mindplay
//
//  Created for MindPlay app.
//

import SwiftUI

struct VerbalMemoryIntroView: View {
    @EnvironmentObject var gameDataManager: GameDataManager
    @State private var isShowingGame = false
    @State private var isAnimating = false
    
    // 背景渐变色 - 使用黄色和橙色渐变表示词汇记忆
    private let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.95, green: 0.6, blue: 0.2),
            Color(red: 0.85, green: 0.4, blue: 0.3)
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
                    // 添加文字气泡装饰元素
                    ForEach(0..<10) { i in
                        let words = ["A", "B", "C", "D", "E", "W", "X", "Y", "Z", "?"]
                        let sizes: [CGFloat] = [30, 38, 26, 34, 42, 28, 32, 36, 30, 40]
                        let positions = generateRandomPositions(count: 10, in: geometry.size)
                        let rotations: [Double] = [-15, 10, -5, 20, -10, 15, -20, 5, -25, 30]
                        let opacities: [Double] = [0.15, 0.1, 0.12, 0.08, 0.14, 0.09, 0.13, 0.11, 0.07, 0.16]
                        let animationDurations: [Double] = [8, 7, 9, 6, 10, 7.5, 8.5, 6.5, 9.5, 7]
                        
                        Text(words[i])
                            .font(.system(size: sizes[i], weight: .bold))
                            .foregroundColor(.white.opacity(opacities[i]))
                            .position(positions[i])
                            .rotationEffect(.degrees(rotations[i]))
                            .offset(y: isAnimating ? 10 : -10)
                            .animation(
                                Animation.easeInOut(duration: animationDurations[i])
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(i) * 0.1),
                                value: isAnimating
                            )
                    }
                    
                    // 添加一些圆形装饰
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
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(LocalizedStringKey.verbalMemoryTest.localized)
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 1, y: 1)
                        
                        Text(LocalizedStringKey.keepWordsInMemory.localized)
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.9))
                            .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // 最佳成绩和开始按钮
                    HStack(spacing: 15) {
                        // 最佳成绩
                        if let bestScore = gameDataManager.getBestScore(for: .verbalMemory) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(LocalizedStringKey.bestScore.localized)
                                    .font(.headline)
                                    .foregroundColor(.white.opacity(0.9))
                                
                                Text("\(Int(bestScore))")
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
                            HStack {
                                Image(systemName: "brain")
                                    .font(.headline)
                                Text(LocalizedStringKey.startTest.localized)
                                    .font(.headline)
                            }
                            .foregroundColor(Color(red: 0.95, green: 0.6, blue: 0.2))
                            .frame(height: 55)
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
                        }
                        .scaleEffect(isAnimating ? 1.02 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
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
                        
                        instructionItem(number: "1", text: LocalizedStringKey.verbalInstruction1.localized)
                        instructionItem(number: "2", text: LocalizedStringKey.verbalInstruction2.localized)
                        instructionItem(number: "3", text: LocalizedStringKey.verbalInstruction3.localized)
                    }
                    .padding()
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                    
                    // About section
                    VStack(alignment: .leading, spacing: 16) {
                        Text(LocalizedStringKey.aboutVerbalTest.localized)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(LocalizedStringKey.verbalTestDescription.localized)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text(LocalizedStringKey.threeStrikes.localized)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.top, 4)
                        
                        // 评级标准
                        VStack(alignment: .leading, spacing: 10) {
                            scoreRangeRow(range: "> 100", description: LocalizedStringKey.excellent.localized)
                            scoreRangeRow(range: "70-100", description: LocalizedStringKey.good.localized)
                            scoreRangeRow(range: "40-70", description: LocalizedStringKey.average.localized)
                            scoreRangeRow(range: "< 40", description: LocalizedStringKey.belowAverage.localized)
                        }
                        .padding(.top, 6)
                    }
                    .padding()
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                    
                    // 底部留空
                    Spacer(minLength: 40)
                }
                .padding(.vertical)
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .fullScreenCover(isPresented: $isShowingGame) {
            VerbalMemoryGameView()
        }
        .onAppear {
            isAnimating = true
        }
    }
    
    // 生成随机位置
    private func generateRandomPositions(count: Int, in size: CGSize) -> [CGPoint] {
        var positions: [CGPoint] = []
        // 确保大小有效，避免范围为负数导致崩溃
        let safeWidth = max(60, size.width)
        let safeHeight = max(60, size.height)
        
        for _ in 0..<count {
            let x = CGFloat.random(in: 30...(safeWidth - 30))
            let y = CGFloat.random(in: 30...(safeHeight - 30))
            positions.append(CGPoint(x: x, y: y))
        }
        return positions
    }
    
    private func instructionItem(number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Text(number)
                .font(.headline)
                .foregroundColor(Color(red: 0.95, green: 0.6, blue: 0.2))
                .frame(width: 36, height: 36)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            
            Text(text)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
    
    private func scoreRangeRow(range: String, description: String) -> some View {
        HStack {
            Text(range)
                .font(.subheadline)
                .foregroundColor(.white)
                .frame(width: 80, alignment: .leading)
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        VerbalMemoryIntroView()
            .environmentObject(GameDataManager())
    }
} 