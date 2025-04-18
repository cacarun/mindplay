//
//  AimTrainerIntroView.swift
//  mindplay
//
//  Created for MindPlay app.
//

import SwiftUI

struct AimTrainerIntroView: View {
    @EnvironmentObject var gameDataManager: GameDataManager
    @State private var navigateToGame = false
    @State private var targetCount = 30 // 默认目标点击次数为30
    @State private var isAnimating = false
    
    // 可选的目标点击次数范围
    private let targetOptions = [10, 20, 30, 50]
    
    // 背景渐变色 - 使用绿色和蓝色渐变表示瞄准和准确性
    private let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.2, green: 0.7, blue: 0.4),
            Color(red: 0.1, green: 0.5, blue: 0.9)
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
                    // 装饰性图形 - 使用圆形目标作为主题元素
                    Circle()
                        .stroke(Color.white.opacity(0.15), lineWidth: 3)
                        .frame(width: 100, height: 100)
                        .position(x: geometry.size.width * 0.85, y: geometry.size.height * 0.2)
                        .scaleEffect(isAnimating ? 1.1 : 0.9)
                        .animation(
                            Animation.easeInOut(duration: 3)
                                .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                    
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 60, height: 60)
                        .position(x: geometry.size.width * 0.15, y: geometry.size.height * 0.8)
                        .scaleEffect(isAnimating ? 0.9 : 1.1)
                        .animation(
                            Animation.easeInOut(duration: 4)
                                .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                    
                    // 添加一些小目标作为装饰
                    ForEach(0..<3, id: \.self) { i in
                        let sizes: [CGFloat] = [25, 30, 20]
                        let posX: [CGFloat] = [0.7, 0.3, 0.6]
                        let posY: [CGFloat] = [0.3, 0.5, 0.7]
                        let opacities: [Double] = [0.1, 0.08, 0.12]
                        let durations: [Double] = [5, 4, 6]
                        
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(opacities[i]))
                                .frame(width: sizes[i], height: sizes[i])
                            
                            Circle()
                                .stroke(Color.white.opacity(opacities[i]), lineWidth: 1)
                                .frame(width: sizes[i] * 0.7, height: sizes[i] * 0.7)
                            
                            Circle()
                                .fill(Color.white.opacity(opacities[i] * 1.5))
                                .frame(width: sizes[i] * 0.2, height: sizes[i] * 0.2)
                        }
                        .position(
                            x: geometry.size.width * posX[i],
                            y: geometry.size.height * posY[i]
                        )
                        .scaleEffect(isAnimating ? 1.1 : 0.9)
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
                        Text(LocalizedStringKey.aimTrainerTest.localized)
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 1, y: 1)
                        
                        Text(LocalizedStringKey.hitTargets.localized)
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.9))
                            .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // 自定义目标点击次数
                    VStack(alignment: .leading, spacing: 14) {
                        Text(LocalizedStringKey.totalTargets.localized)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        HStack(spacing: 12) {
                            ForEach(targetOptions, id: \.self) { count in
                                Button(action: {
                                    targetCount = count
                                    // 添加触觉反馈
                                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                    impactMed.impactOccurred()
                                }) {
                                    Text("\(count)")
                                        .font(.headline)
                                        .frame(height: 45)
                                        .frame(minWidth: 45)
                                        .background(targetCount == count ? 
                                                  Color.white : Color.white.opacity(0.2))
                                        .foregroundColor(targetCount == count ? 
                                                       Color(red: 0.2, green: 0.5, blue: 0.8) : .white)
                                        .cornerRadius(12)
                                        .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                                }
                                .scaleEffect(targetCount == count ? 1.1 : 1.0)
                                .animation(
                                    .spring(response: 0.3, dampingFraction: 0.6),
                                    value: targetCount
                                )
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
                        if let bestScore = gameDataManager.getBestScore(for: .aimTrainer) {
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
                            navigateToGame = true
                            // 添加触觉反馈
                            let impactMed = UIImpactFeedbackGenerator(style: .medium)
                            impactMed.impactOccurred()
                        }) {
                            Text(LocalizedStringKey.startTest.localized)
                                .font(.headline)
                                .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.4))
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
                        
                        instructionItem(number: "1", text: LocalizedStringKey.clickToBegin.localized)
                        instructionItem(number: "2", text: LocalizedStringKey.tapTarget.localized)
                        instructionItem(number: "3", text: String.localizedStringWithFormat(LocalizedStringKey.completeTargets.localized as String, targetCount))
                    }
                    .padding()
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                    
                    // About section
                    VStack(alignment: .leading, spacing: 14) {
                        Text(LocalizedStringKey.aboutAimTest.localized)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(LocalizedStringKey.aimTestDescription.localized)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
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
        .fullScreenCover(isPresented: $navigateToGame) {
            AimTrainerGameView(totalTargets: targetCount)
        }
        .onAppear {
            isAnimating = true
        }
    }
    
    private func instructionItem(number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Text(number)
                .font(.headline)
                .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.4))
                .frame(width: 36, height: 36)
                .background(Color.white)
                .clipShape(Circle())
            
            Text(text)
                .font(.body)
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        AimTrainerIntroView()
            .environmentObject(GameDataManager())
    }
} 