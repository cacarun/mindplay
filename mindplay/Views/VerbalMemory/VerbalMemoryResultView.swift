//
//  VerbalMemoryResultView.swift
//  mindplay
//
//  Created for MindPlay app.
//

import SwiftUI

struct VerbalMemoryResultView: View {
    let score: Int
    let onDismiss: () -> Void
    let onRestart: () -> Void
    
    @State private var isAnimating = false
    @State private var showConfetti = false
    
    // 词汇记忆的主题色 - 使用黄色和橙色
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
            
            // 装饰元素
            GeometryReader { geometry in
                ZStack {
                    // 装饰圆形 - 拆分复杂表达式
                    ForEach(0..<8) { i in
                        // 拆分为多个变量声明，避免复杂嵌套表达式
                        let sizes: [CGFloat] = [80, 120, 100, 140, 110, 90, 130, 70]
                        let posX: [CGFloat] = [0.1, 0.8, 0.3, 0.9, 0.2, 0.7, 0.5, 0.85]
                        let posY: [CGFloat] = [0.2, 0.3, 0.85, 0.7, 0.6, 0.15, 0.4, 0.75]
                        let rotations: [Double] = [15, -10, 20, -15, 8, -12, 5, -8]
                        let durations: [Double] = [7, 8, 6.5, 9, 7.5, 8.5, 6, 9.5]
                        
                        let size = sizes[i]
                        let xPos = geometry.size.width * posX[i]
                        let yPos = geometry.size.height * posY[i]
                        let rotation = rotations[i]
                        let duration = durations[i]
                        let animationValue = isAnimating ? rotation : 0
                        
                        // 使用单独变量，避免嵌套表达式
                        let animation = Animation.easeInOut(duration: duration)
                            .repeatForever(autoreverses: true)
                        
                        Circle()
                            .stroke(Color.white.opacity(0.08), lineWidth: 2)
                            .frame(width: size, height: size)
                            .position(x: xPos, y: yPos)
                            .rotationEffect(.degrees(animationValue))
                            .animation(animation, value: isAnimating)
                    }
                    
                    // 漂浮的"单词泡泡"效果
                    if showConfetti {
                        ForEach(0..<20) { i in
                            // 将复杂表达式拆分为明确的变量
                            let words = ["Memory", "Words", "Brain", "Think", "Learn", "Mind", "Smart", "Read", "Know", "Focus"]
                            let sizes: [CGFloat] = [24, 28, 22, 30, 26, 20, 32, 25, 27, 23]
                            
                            let wordIndex = i % words.count
                            let sizeIndex = i % sizes.count
                            let word = words[wordIndex]
                            let size = sizes[sizeIndex]
                            
                            // 创建单独的位置变量
                            let xPos = CGFloat.random(in: 0...geometry.size.width)
                            let yPos = CGFloat.random(in: 0...geometry.size.height)
                            let position = CGPoint(x: xPos, y: yPos)
                            
                            // 创建单独的动画变量
                            let duration = Double.random(in: 2.5...5.0)
                            let delay = Double.random(in: 0...2.0)
                            let animation = Animation.easeInOut(duration: duration)
                                .delay(delay)
                                .repeatForever(autoreverses: false)
                            
                            Text(word)
                                .font(.system(size: size, weight: .bold))
                                .foregroundColor(.white.opacity(0.3))
                                .position(position)
                                .offset(y: isAnimating ? -100 : 100)
                                .opacity(isAnimating ? 0 : 0.3)
                                .animation(animation, value: isAnimating)
                        }
                    }
                }
            }
            
            // 内容
            VStack(spacing: 25) {
                // 顶部标题
                VStack(spacing: 10) {
                    Text(LocalizedStringKey.testComplete.localized)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 1, y: 1)
                        .multilineTextAlignment(.center)
                    
                    Text(LocalizedStringKey.verbalMemoryTest.localized)
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.9))
                        .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                }
                .padding(.top, 40)
                
                Spacer()
                
                // 结果显示卡片
                VStack(spacing: 30) {
                    // 图标和分数
                    VStack(spacing: 15) {
                        // 脑图标
                        let brainIconAnimation = Animation.easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true)
                        let brainIconScale = isAnimating ? 1.1 : 0.9
                        
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 65))
                            .foregroundColor(.white)
                            .padding(25)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.15))
                                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                            )
                            .scaleEffect(brainIconScale)
                            .animation(brainIconAnimation, value: isAnimating)
                        
                        // 分数显示
                        Text(LocalizedStringKey.yourScore.localized)
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.9))
                        
                        let scoreTextAnimation = Animation.easeInOut(duration: 2.0)
                            .repeatForever(autoreverses: true)
                        let scoreTextScale = isAnimating ? 1.05 : 1.0
                        
                        Text("\(score)")
                            .font(.system(size: 60, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 1, y: 1)
                            .scaleEffect(scoreTextScale)
                            .animation(scoreTextAnimation, value: isAnimating)
                    }
                    
                    // 鼓励信息
                    Text(score > 10 ? LocalizedStringKey.excellentMemory.localized : LocalizedStringKey.goodJob.localized)
                        .font(.headline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.white.opacity(0.15))
                        .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: 10)
                )
                .padding(.horizontal, 20)
                
                Spacer()
                
                // 底部按钮
                VStack(spacing: 15) {
                    // 重新开始按钮
                    Button(action: {
                        // 触觉反馈
                        let impactMed = UIImpactFeedbackGenerator(style: .medium)
                        impactMed.impactOccurred()
                        onRestart()
                    }) {
                        Text(LocalizedStringKey.tryAgain.localized)
                            .font(.headline)
                            .foregroundColor(Color(red: 0.95, green: 0.6, blue: 0.2))
                            .padding(.vertical, 16)
                            .frame(width: 220)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 3)
                    }
                    
                    // 返回主菜单按钮
                    Button(action: {
                        // 触觉反馈
                        let impactMed = UIImpactFeedbackGenerator(style: .medium)
                        impactMed.impactOccurred()
                        onDismiss()
                    }) {
                        Text(LocalizedStringKey.backToMenu.localized)
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.vertical, 16)
                            .frame(width: 220)
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                    }
                }
                .padding(.bottom, 40)
            }
            .padding()
        }
        .onAppear {
            isAnimating = true
            // 延迟启动漂浮词效果，让主UI先显示
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showConfetti = true
            }
        }
    }
}

#Preview {
    VerbalMemoryResultView(
        score: 15,
        onDismiss: {},
        onRestart: {}
    )
} 