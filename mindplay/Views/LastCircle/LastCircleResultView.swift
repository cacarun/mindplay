//
//  LastCircleResultView.swift
//  mindplay
//
//  Created for MindPlay app.
//

import SwiftUI
import Charts

struct LastCircleResultView: View {
    @EnvironmentObject var gameDataManager: GameDataManager
    @Environment(\.dismiss) private var dismiss
    @State private var isAnimating = false
    @State private var chartAnimation = false
    
    let score: Int
    let rounds: Int
    let circleCount: Int
    let reactionTimes: [Double]
    let onDismiss: () -> Void
    let onRestart: (Int) -> Void  // 添加 onRestart 回调函数
    
    // 背景渐变
    private let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.3, green: 0.6, blue: 0.9),
            Color(red: 0.5, green: 0.2, blue: 0.8)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var avgReactionTime: Double {
        guard !reactionTimes.isEmpty else { return 0 }
        return reactionTimes.reduce(0, +) / Double(reactionTimes.count)
    }
    
    var body: some View {
        ZStack {
            // 渐变背景
            backgroundGradient
                .ignoresSafeArea()
            
            // 背景装饰元素
            GeometryReader { geometry in
                ForEach(0..<8) { index in
                    Circle()
                        .fill(Color.white.opacity(0.1 + Double(index) * 0.01))
                        .frame(width: CGFloat(40 + index * 5), height: CGFloat(40 + index * 5))
                        .position(
                            x: geometry.size.width * getRandomPosition(seed: index + 5),
                            y: geometry.size.height * getRandomPosition(seed: index + 15)
                        )
                        .offset(y: isAnimating ? CGFloat(10 + index * 2) : CGFloat(-10 - index * 2))
                        .animation(
                            Animation.easeInOut(duration: Double(3 + index)).repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                }
            }
            
            ScrollView {
                VStack(spacing: 25) {
                    // 标题区域
                    Text(LocalizedStringKey.results.localized)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.2), radius: 2, x: 1, y: 1)
                        .padding(.top, 20)
                    
                    // 成绩卡片
                    VStack(spacing: 15) {
                        // 分数显示
                        Text("\(score)")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.8))
                            .opacity(isAnimating ? 1.0 : 0.0)
                            .scaleEffect(isAnimating ? 1.0 : 0.5)
                            .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0), value: isAnimating)
                        
                        Text(LocalizedStringKey.pointsScored.localized)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Divider()
                            .padding(.vertical, 5)
                        
                        // 统计数据
                        HStack(spacing: 30) {
                            // 回合数
                            VStack {
                                Text("\(rounds)")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.8))
                                
                                Text(LocalizedStringKey.level.localized)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            // 平均反应时间
                            VStack {
                                Text(String(format: "%.2f", avgReactionTime))
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.8))
                                
                                Text(LocalizedStringKey.seconds.localized)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            // 圆圈数量
                            VStack {
                                Text("\(circleCount)")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.8))
                                
                                Text(LocalizedStringKey.circlesCount.localized)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    )
                    .padding(.horizontal)
                    
                    // 表现评级卡片
                    VStack(alignment: .leading, spacing: 15) {
                        Text(LocalizedStringKey.performance.localized)
                            .font(.headline)
                            .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.8))
                        
                        HStack {
                            // 评级图标
                            ZStack {
                                Circle()
                                    .fill(getPerformanceColor())
                                    .frame(width: 60, height: 60)
                                
                                Image(systemName: getPerformanceIcon())
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 5) {
                                Text(getPerformanceTitle())
                                    .font(.headline)
                                    .foregroundColor(getPerformanceColor())
                                
                                Text(getPerformanceDescription())
                                    .font(.subheadline)
                                    .foregroundColor(.black.opacity(0.7))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(.leading, 10)
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    )
                    .padding(.horizontal)
                    
                    // 反应时间图表卡片
                    if !reactionTimes.isEmpty {
                        VStack(alignment: .leading, spacing: 15) {
                            Text(LocalizedStringKey.yourAttempts.localized)
                                .font(.headline)
                                .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.8))
                            
                            // 反应时间图表
                            Chart {
                                ForEach(Array(reactionTimes.enumerated()), id: \.offset) { index, time in
                                    LineMark(
                                        x: .value("Round", index + 1),
                                        y: .value("Time", chartAnimation ? time : 0)
                                    )
                                    .foregroundStyle(Color.blue.gradient)
                                    
                                    PointMark(
                                        x: .value("Round", index + 1),
                                        y: .value("Time", chartAnimation ? time : 0)
                                    )
                                    .foregroundStyle(Color.blue)
                                }
                            }
                            .frame(height: 200)
                            .chartYScale(domain: 0...(reactionTimes.max() ?? 3.0) * 1.1)
                            .chartXAxis {
                                AxisMarks(values: .automatic) { _ in
                                    AxisValueLabel()
                                    AxisGridLine()
                                }
                            }
                            .chartYAxis {
                                AxisMarks(values: .automatic) { value in
                                    AxisValueLabel() {
                                        if let timeValue = value.as(Double.self) {
                                            Text(String(format: "%.1f", timeValue))
                                        }
                                    }
                                    AxisGridLine()
                                }
                            }
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    withAnimation(.spring(response: 1.0, dampingFraction: 0.8, blendDuration: 0)) {
                                        chartAnimation = true
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        )
                        .padding(.horizontal)
                    }
                    
                    // 说明卡片
                    VStack(alignment: .leading, spacing: 15) {
                        Text(LocalizedStringKey.whatThisMeans.localized)
                            .font(.headline)
                            .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.8))
                        
                        Text(LocalizedStringKey.lastCircleExplanation.localized)
                            .font(.subheadline)
                            .foregroundColor(.black.opacity(0.7))
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.bottom, 5)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    )
                    .padding(.horizontal)
                    
                    // 操作按钮
                    HStack(spacing: 20) {
                        // 返回首页按钮
                        Button {
                            // 触觉反馈
                            let impactMed = UIImpactFeedbackGenerator(style: .medium)
                            impactMed.impactOccurred()
                            onDismiss()
                        } label: {
                            HStack {
                                Image(systemName: "house.fill")
                                Text(LocalizedStringKey.home.localized)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                            )
                            .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.8))
                        }
                        
                        // 再玩一次按钮 - 修改实现方式
                        Button {
                            // 触觉反馈
                            let impactMed = UIImpactFeedbackGenerator(style: .medium)
                            impactMed.impactOccurred()
                            dismiss()
                            onRestart(circleCount)
                        } label: {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                Text(LocalizedStringKey.playAgain.localized)
                            }
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
                            .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                }
            }
        }
        .onAppear {
            isAnimating = true
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(trailing: Button(action: {
            onDismiss()
        }) {
            Image(systemName: "xmark.circle.fill")
                .font(.title2)
                .foregroundColor(.white.opacity(0.7))
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        })
    }
    
    // 根据分数获取表现评级
    private func getPerformanceTitle() -> String {
        if score >= 2500 {
            return LocalizedStringKey.excellent.localized
        } else if score >= 1800 {
            return LocalizedStringKey.good.localized
        } else if score >= 1200 {
            return LocalizedStringKey.average.localized
        } else {
            return LocalizedStringKey.belowAverage.localized
        }
    }
    
    // 根据分数获取表现描述
    private func getPerformanceDescription() -> String {
        if score >= 2500 {
            return LocalizedStringKey.excellentLastCircleMemory.localized
        } else if score >= 1800 {
            return LocalizedStringKey.goodLastCircleMemory.localized
        } else if score >= 1200 {
            return LocalizedStringKey.averageLastCircleMemory.localized
        } else {
            return LocalizedStringKey.belowAverageLastCircleMemory.localized
        }
    }
    
    // 根据分数获取表现颜色
    private func getPerformanceColor() -> Color {
        if score >= 2500 {
            return .purple
        } else if score >= 1800 {
            return .blue
        } else if score >= 1200 {
            return .green
        } else {
            return .orange
        }
    }
    
    // 根据分数获取表现图标
    private func getPerformanceIcon() -> String {
        if score >= 2500 {
            return "star.fill"
        } else if score >= 1800 {
            return "hand.thumbsup.fill"
        } else if score >= 1200 {
            return "checkmark.circle.fill"
        } else {
            return "arrow.up.circle.fill"
        }
    }
    
    // 根据种子生成随机位置 (0.1-0.9范围内)
    private func getRandomPosition(seed: Int) -> Double {
        let random = Double(((seed * 1234321) % 80) + 10) / 100.0
        return random
    }
}

#Preview {
    LastCircleResultView(
        score: 1850,
        rounds: 12,
        circleCount: 10,
        reactionTimes: [1.2, 1.1, 0.9, 1.3, 1.0, 0.8, 0.9, 1.2, 0.7, 1.1, 0.9, 1.0],
        onDismiss: {},
        onRestart: {_ in}
    )
    .environmentObject(GameDataManager())
} 