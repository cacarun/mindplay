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
    @State private var showInstructions = false
    @State private var showAbout = false
    
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
        NavigationStack {
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
                
                // 主内容
                ScrollView {
                    VStack(spacing: 25) {
                        // 标题区域
                        VStack(spacing: 10) {
                            Text(LocalizedStringKey.lastCircleTest.localized)
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.2), radius: 2, x: 1, y: 1)
                                .multilineTextAlignment(.center)
                                .padding(.top, 20)
                            
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
                        VStack(spacing: 20) {
                            Text(LocalizedStringKey.circlesCount.localized)
                                .font(.headline)
                                .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.8))
                            
                            // 圆圈数量选择
                            HStack(spacing: 15) {
                                ForEach(circleCounts, id: \.self) { count in
                                    CircleCountButton(
                                        count: count,
                                        isSelected: selectedCircleCount == count,
                                        action: {
                                            selectedCircleCount = count
                                            let generator = UIImpactFeedbackGenerator(style: .medium)
                                            generator.impactOccurred()
                                        }
                                    )
                                }
                            }
                            
                            // 最佳分数显示
                            HStack {
                                Image(systemName: "trophy.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.yellow)
                                    .opacity(isAnimating ? 1.0 : 0.7)
                                    .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                                
                                Text(LocalizedStringKey.bestScore.localized)
                                    .font(.headline)
                                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.8))
                                
                                Spacer()
                                
                                Text(getBestScoreText())
                                    .font(.headline)
                                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.8))
                            }
                            .padding(.top, 10)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white.opacity(0.9))
                                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        )
                        .padding(.horizontal)
                        
                        // 开始按钮
                        NavigationLink(destination: LastCircleGameView(circleCount: selectedCircleCount)) {
                            Text(LocalizedStringKey.startRound.localized)
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color(red: 0.3, green: 0.5, blue: 0.9), Color(red: 0.5, green: 0.3, blue: 0.9)]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
                                )
                                .scaleEffect(isAnimating ? 1.03 : 1.0)
                                .animation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: isAnimating)
                        }
                        .padding(.horizontal)
                        .buttonStyle(PlainButtonStyle())
                        
                        // 游戏说明卡片
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Text(LocalizedStringKey.howToPlay.localized)
                                    .font(.headline)
                                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.8))
                                
                                Spacer()
                                
                                Button {
                                    withAnimation {
                                        showInstructions.toggle()
                                    }
                                } label: {
                                    Image(systemName: showInstructions ? "chevron.up" : "chevron.down")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.8))
                                }
                            }
                            
                            if showInstructions {
                                VStack(alignment: .leading, spacing: 8) {
                                    InstructionRow(number: 1, text: LocalizedStringKey.lastCircleRule1.localized)
                                    InstructionRow(number: 2, text: LocalizedStringKey.lastCircleRule2.localized)
                                    InstructionRow(number: 3, text: LocalizedStringKey.lastCircleRule3.localized)
                                    InstructionRow(number: 4, text: LocalizedStringKey.lastCircleRule4.localized)
                                }
                                .padding(.top, 5)
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white.opacity(0.9))
                                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        )
                        .padding(.horizontal)
                        
                        // 关于测试卡片
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Text(LocalizedStringKey.aboutLastCircleTest.localized)
                                    .font(.headline)
                                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.8))
                                
                                Spacer()
                                
                                Button {
                                    withAnimation {
                                        showAbout.toggle()
                                    }
                                } label: {
                                    Image(systemName: showAbout ? "chevron.up" : "chevron.down")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.8))
                                }
                            }
                            
                            if showAbout {
                                Text(LocalizedStringKey.lastCircleDescription.localized)
                                    .font(.subheadline)
                                    .foregroundColor(.black.opacity(0.7))
                                    .padding(.top, 5)
                                
                                Text(LocalizedStringKey.scoreExplanation.localized)
                                    .font(.subheadline)
                                    .foregroundColor(.black.opacity(0.7))
                                    .padding(.top, 8)
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white.opacity(0.9))
                                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        )
                        .padding(.horizontal)
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.vertical)
                }
            }
            .onAppear {
                isAnimating = true
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
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
}

// 圆圈数量选择按钮
struct CircleCountButton: View {
    let count: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("\(count)")
                .font(.system(size: 16, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? .white : Color(red: 0.3, green: 0.3, blue: 0.8))
                .frame(width: 52, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? 
                              LinearGradient(gradient: Gradient(colors: [Color(red: 0.3, green: 0.5, blue: 0.9), Color(red: 0.5, green: 0.3, blue: 0.9)]),
                                             startPoint: .leading,
                                             endPoint: .trailing) :
                              LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.5), Color.white.opacity(0.5)]),
                                             startPoint: .leading,
                                             endPoint: .trailing)
                        )
                        .shadow(color: Color.black.opacity(isSelected ? 0.2 : 0.1), radius: isSelected ? 4 : 2, x: 0, y: isSelected ? 2 : 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// 指令行
struct InstructionRow: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color(red: 0.3, green: 0.5, blue: 0.9), Color(red: 0.5, green: 0.3, blue: 0.9)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 26, height: 26)
                
                Text("\(number)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.black.opacity(0.7))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    LastCircleIntroView()
        .environmentObject(GameDataManager())
} 