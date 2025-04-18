//
//  ReactionTimeResultView.swift
//  mindplay
//
//  Created for MindPlay app.
//

import SwiftUI
import Charts

struct ReactionTimeResultView: View {
    @Environment(\.dismiss) private var dismiss
    let reactionTimes: [Double]
    let totalRounds: Int
    let onDismiss: () -> Void
    let onRestart: (Int) -> Void // Add a callback to restart with a given number of rounds
    
    @State private var isAnimating = false
    
    private var averageTime: Double {
        reactionTimes.reduce(0, +) / Double(reactionTimes.count)
    }
    
    private var bestTime: Double {
        reactionTimes.min() ?? 0
    }
    
    // 评级描述
    private var percentileDescription: String {
        if averageTime < 200 {
            return LocalizedStringKey.percentileExcellent.localized
        } else if averageTime < 250 {
            return LocalizedStringKey.percentileGood.localized
        } else if averageTime < 300 {
            return LocalizedStringKey.percentileAverage.localized
        } else {
            return LocalizedStringKey.percentileBelowAverage.localized
        }
    }
    
    // 背景渐变色 - 使用暖色调渐变表示成就和结果
    private let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.4, green: 0.2, blue: 0.9),
            Color(red: 0.6, green: 0.3, blue: 0.8)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // 构建表现评级条
    private var performanceRatingView: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // 背景条
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.2))
                    .frame(height: 10)
                
                // 评级指示器
                HStack(spacing: 0) {
                    // 四个评级区域
                    Rectangle()
                        .fill(Color.red.opacity(0.8))
                        .frame(width: geometry.size.width * 0.25, height: 10)
                    
                    Rectangle()
                        .fill(Color.orange.opacity(0.8))
                        .frame(width: geometry.size.width * 0.25, height: 10)
                    
                    Rectangle()
                        .fill(Color.yellow.opacity(0.8))
                        .frame(width: geometry.size.width * 0.25, height: 10)
                    
                    Rectangle()
                        .fill(Color.green.opacity(0.8))
                        .frame(width: geometry.size.width * 0.25, height: 10)
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // 指示器
                Circle()
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
                    .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 3)
                    )
                    .position(x: indicatorPosition(in: geometry.size.width), y: 5)
            }
        }
        .frame(height: 20)
        .padding(.vertical, 10)
    }
    
    // 计算指示器位置
    private func indicatorPosition(in width: CGFloat) -> CGFloat {
        let position: CGFloat
        if averageTime < 200 {
            // 优秀区域 (0-25%)
            position = width * (0.125 + (1 - averageTime/200) * 0.125)
        } else if averageTime < 250 {
            // 良好区域 (25-50%)
            position = width * (0.375 - (averageTime - 200) / 200)
        } else if averageTime < 300 {
            // 平均区域 (50-75%)
            position = width * (0.625 - (averageTime - 250) / 200)
        } else {
            // 低于平均区域 (75-100%)
            let cappedTime = min(averageTime, 400) // Cap at 400ms for display
            position = width * (0.875 - (cappedTime - 300) / 400)
        }
        return max(10, min(width - 10, position)) // 确保不超出边界
    }
    
    var body: some View {
        ZStack {
            // 背景渐变
            backgroundGradient
                .ignoresSafeArea()
            
            // 背景装饰元素
            GeometryReader { geometry in
                ZStack {
                    // 装饰性圆形
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 150, height: 150)
                        .position(x: geometry.size.width * 0.1, y: geometry.size.height * 0.1)
                        .offset(y: isAnimating ? -10 : 5)
                        .animation(Animation.easeInOut(duration: 4).repeatForever(autoreverses: true), value: isAnimating)
                    
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 100, height: 100)
                        .position(x: geometry.size.width * 0.85, y: geometry.size.height * 0.85)
                        .offset(y: isAnimating ? 10 : -10)
                        .animation(Animation.easeInOut(duration: 3.5).repeatForever(autoreverses: true), value: isAnimating)
                }
            }
            
            ScrollView {
                VStack(spacing: 24) {
                    // 结果标题
                    Text(LocalizedStringKey.yourAverageReactionTime.localized)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.top, 30)
                    
                    // 平均反应时间
                    Text(String(format: "%.0f ms", averageTime))
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 1, y: 1)
                        .padding(.top, 5)
                        .scaleEffect(isAnimating ? 1.05 : 0.95)
                        .animation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
                    
                    // 表现评级条
                    performanceRatingView
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                    
                    // 表现描述
                    Text(percentileDescription)
                        .font(.headline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 5)
                    
                    // 统计部分
                    VStack(alignment: .leading, spacing: 16) {
                        Text(LocalizedStringKey.statistics.localized)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        HStack(spacing: 30) {
                            // 最佳时间
                            VStack(alignment: .center, spacing: 5) {
                                Text(LocalizedStringKey.bestTime.localized)
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.9))
                                
                                Text(String(format: "%.0f ms", bestTime))
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            
                            // 尝试次数
                            VStack(alignment: .center, spacing: 5) {
                                Text(LocalizedStringKey.attempts.localized)
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.9))
                                
                                Text("\(reactionTimes.count)/\(totalRounds)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.vertical, 10)
                        
                        // 尝试图表
                        VStack(alignment: .leading, spacing: 10) {
                            Text(LocalizedStringKey.yourAttempts.localized)
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            // 图表视图
                            Chart {
                                ForEach(Array(reactionTimes.enumerated()), id: \.offset) { index, time in
                                    BarMark(
                                        x: .value("Round", index + 1),
                                        y: .value("Time", time)
                                    )
                                    .foregroundStyle(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.white.opacity(0.9),
                                                Color.white.opacity(0.7)
                                            ]),
                                            startPoint: .bottom,
                                            endPoint: .top
                                        )
                                    )
                                    .cornerRadius(6)
                                }
                                
                                RuleMark(y: .value("Average", averageTime))
                                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                                    .foregroundStyle(Color.yellow)
                                    .annotation(position: .top, alignment: .trailing) {
                                        Text("Average")
                                            .font(.caption)
                                            .foregroundStyle(Color.yellow)
                                    }
                            }
                            .frame(height: 180)
                            .chartYScale(domain: 0...(reactionTimes.max() ?? 500) * 1.2)
                            .chartYAxis {
                                AxisMarks(position: .leading)
                            }
                            .chartXAxis {
                                AxisMarks(preset: .aligned, position: .bottom)
                            }
                            .padding(8)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(16)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                    
                    // 说明部分
                    VStack(alignment: .leading, spacing: 14) {
                        Text(LocalizedStringKey.whatThisMeans.localized)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(LocalizedStringKey.resultExplanation.localized)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text(LocalizedStringKey.resultFactors.localized)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.top, 4)
                    }
                    .padding()
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                    
                    // Action buttons
                    HStack(spacing: 16) {
                        // 返回主菜单按钮
                        Button(action: {
                            onDismiss()
                            // 添加触觉反馈
                            let impactMed = UIImpactFeedbackGenerator(style: .medium)
                            impactMed.impactOccurred()
                        }) {
                            HStack {
                                Image(systemName: "house.fill")
                                    .font(.headline)
                                
                                Text(LocalizedStringKey.backToMenu.localized)
                                    .font(.headline)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 3)
                        }
                        
                        // 再玩一次按钮
                        Button(action: {
                            dismiss()
                            onRestart(totalRounds)
                            // 添加触觉反馈
                            let impactMed = UIImpactFeedbackGenerator(style: .medium)
                            impactMed.impactOccurred()
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                    .font(.headline)
                                
                                Text(LocalizedStringKey.playAgain.localized)
                                    .font(.headline)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.9))
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 3)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct ReactionTimeResultView_Previews: PreviewProvider {
    static var previews: some View {
        ReactionTimeResultView(
            reactionTimes: [245, 231, 265],
            totalRounds: 3,
            onDismiss: {},
            onRestart: { _ in }
        )
    }
}
