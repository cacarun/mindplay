//
//  VisualMemoryResultView.swift
//  mindplay
//
//  Created for MindPlay app.
//

import SwiftUI
import Charts

struct VisualMemoryResultView: View {
    @EnvironmentObject var gameDataManager: GameDataManager
    @Environment(\.dismiss) private var dismiss
    
    let level: Int
    let onDismiss: () -> Void
    let onRestart: (Int) -> Void
    
    @State private var isAnimating = false
    @State private var showChart = false
    
    // 视觉记忆的主题渐变色 - 紫色/靛蓝色
    private let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.4, green: 0.2, blue: 0.8),
            Color(red: 0.2, green: 0.3, blue: 0.7)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // 性能评级文本
    private var percentileText: String {
        if level > 12 {
            return LocalizedStringKey.percentileExcellent.localized
        } else if level >= 9 {
            return LocalizedStringKey.percentileGood.localized
        } else if level >= 6 {
            return LocalizedStringKey.percentileAverage.localized
        } else {
            return LocalizedStringKey.percentileBelowAverage.localized
        }
    }
    
    // 性能说明
    private var performanceDescription: String {
        if level > 12 {
            return LocalizedStringKey.excellentVisualMemory.localized
        } else if level >= 9 {
            return LocalizedStringKey.goodVisualMemory.localized
        } else if level >= 6 {
            return LocalizedStringKey.averageVisualMemory.localized
        } else {
            return LocalizedStringKey.belowAverageVisualMemory.localized
        }
    }
    
    // 性能评级图标
    private var performanceIcon: String {
        if level > 12 {
            return "star.fill"
        } else if level >= 9 {
            return "hand.thumbsup.fill"
        } else if level >= 6 {
            return "checkmark.circle.fill"
        } else {
            return "arrow.up.circle.fill"
        }
    }
    
    // 模拟分布数据 - 基于提供的图片中的分布曲线
    private let distributionData: [DistributionData] = [
        DistributionData(level: "0", percentage: 0),
        DistributionData(level: "1", percentage: 1),
        DistributionData(level: "2", percentage: 2),
        DistributionData(level: "3", percentage: 4),
        DistributionData(level: "4", percentage: 6),
        DistributionData(level: "5", percentage: 8),
        DistributionData(level: "6", percentage: 12),
        DistributionData(level: "7", percentage: 18),
        DistributionData(level: "8", percentage: 30),
        DistributionData(level: "9", percentage: 42),
        DistributionData(level: "10", percentage: 38),
        DistributionData(level: "11", percentage: 26),
        DistributionData(level: "12", percentage: 18),
        DistributionData(level: "13", percentage: 16),
        DistributionData(level: "14", percentage: 24),
        DistributionData(level: "15", percentage: 16),
        DistributionData(level: "16", percentage: 10),
        DistributionData(level: "17", percentage: 7),
        DistributionData(level: "18", percentage: 5),
        DistributionData(level: "19", percentage: 3),
        DistributionData(level: "20", percentage: 3),
        DistributionData(level: "21", percentage: 2),
        DistributionData(level: "22", percentage: 1),
        DistributionData(level: "23", percentage: 1),
        DistributionData(level: "24", percentage: 0)
    ]
    
    // 基于图片的分布数据模型
    private struct DistributionData: Identifiable {
        let id = UUID()
        let level: String
        let percentage: Double
    }
    
    var body: some View {
        ZStack {
            // 渐变背景
            backgroundGradient
                .ignoresSafeArea()
            
            // 背景装饰元素
            GeometryReader { geometry in
                ZStack {
                    // 添加一些装饰性方块
                    ForEach(0..<8) { i in
                        let positions = [
                            CGPoint(x: geometry.size.width * 0.1, y: geometry.size.height * 0.2),
                            CGPoint(x: geometry.size.width * 0.85, y: geometry.size.height * 0.15),
                            CGPoint(x: geometry.size.width * 0.25, y: geometry.size.height * 0.8),
                            CGPoint(x: geometry.size.width * 0.75, y: geometry.size.height * 0.75),
                            CGPoint(x: geometry.size.width * 0.5, y: geometry.size.height * 0.4),
                            CGPoint(x: geometry.size.width * 0.9, y: geometry.size.height * 0.6),
                            CGPoint(x: geometry.size.width * 0.15, y: geometry.size.height * 0.5),
                            CGPoint(x: geometry.size.width * 0.6, y: geometry.size.height * 0.1)
                        ]
                        
                        let sizes: [CGFloat] = [60, 70, 50, 65, 55, 45, 50, 60]
                        let opacities: [Double] = [0.1, 0.08, 0.12, 0.06, 0.1, 0.07, 0.08, 0.1]
                        
                        // 记忆方块装饰
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(opacities[i]))
                            .frame(width: sizes[i], height: sizes[i])
                            .position(positions[i])
                            .rotationEffect(.degrees(isAnimating ? Double(i * 5) : 0))
                            .animation(
                                Animation.easeInOut(duration: Double.random(in: 3...6))
                                    .repeatForever(autoreverses: true)
                                    .delay(Double.random(in: 0...1)),
                                value: isAnimating
                            )
                    }
                    
                    // 漂浮的数字
                    if showChart {
                        ForEach(0..<12) { i in
                            let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
                            let positions = [
                                CGPoint(x: CGFloat.random(in: 50...geometry.size.width-50),
                                       y: CGFloat.random(in: 50...geometry.size.height-50))
                            ]
                            
                            Text("\(numbers[i % numbers.count])")
                                .font(.system(size: CGFloat.random(in: 15...28), weight: .bold))
                                .foregroundColor(.white.opacity(0.15))
                                .position(positions[0])
                                .offset(y: isAnimating ? -30 : 30)
                                .animation(
                                    Animation.easeInOut(duration: Double.random(in: 3...6))
                                        .repeatForever(autoreverses: true)
                                        .delay(Double.random(in: 0...2)),
                                    value: isAnimating
                                )
                        }
                    }
                }
            }
            
            ScrollView {
                VStack(spacing: 25) {
                    // 顶部标题
                    Text(LocalizedStringKey.results.localized)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 1, y: 1)
                        .padding(.top, 20)
                    
                    // 结果区域
                    VStack(spacing: 15) {
                        Text(LocalizedStringKey.levelReached.localized)
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.9))
                        
                        // 大数字显示
                        Text("\(level)")
                            .font(.system(size: 70, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.2), radius: 3, x: 1, y: 2)
                            .scaleEffect(isAnimating ? 1.05 : 1.0)
                            .animation(
                                Animation.easeInOut(duration: 2.0)
                                    .repeatForever(autoreverses: true),
                                value: isAnimating
                            )
                        
                        // 性能评级
                        HStack {
                            Image(systemName: performanceIcon)
                                .foregroundColor(.yellow)
                                .font(.title)
                                .shadow(color: Color.black.opacity(0.2), radius: 2, x: 1, y: 1)
                            
                            Text(percentileText)
                                .font(.headline)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, 5)
                    }
                    .padding(.vertical, 25)
                    .padding(.horizontal, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.15))
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                    )
                    .padding(.horizontal, 20)
                    
                    // 图表区域
                    VStack(alignment: .leading, spacing: 15) {
                        Text(LocalizedStringKey.statistics.localized)
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                        
                        // 图表卡片
                        VStack(alignment: .leading, spacing: 15) {
                            Text(LocalizedStringKey.distribution.localized)
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.9))
                            
                            // 图表视图
                            Chart {
                                ForEach(distributionData) { item in
                                    AreaMark(
                                        x: .value("Level", item.level),
                                        y: .value("Percentage", item.percentage)
                                    )
                                    .foregroundStyle(Color.purple.opacity(0.2).gradient)
                                    .interpolationMethod(.catmullRom)
                                    
                                    LineMark(
                                        x: .value("Level", item.level),
                                        y: .value("Percentage", item.percentage)
                                    )
                                    .foregroundStyle(Color.white.opacity(0.7).gradient)
                                    .interpolationMethod(.catmullRom)
                                    
                                    if item.level == String(level) {
                                        PointMark(
                                            x: .value("Level", item.level),
                                            y: .value("Percentage", item.percentage)
                                        )
                                        .foregroundStyle(Color.yellow)
                                        .symbolSize(100)
                                    }
                                }
                            }
                            .frame(height: 250)
                            .chartYAxis {
                                AxisMarks(position: .leading, values: .automatic(desiredCount: 5)) { value in
                                    if let percentage = value.as(Double.self) {
                                        AxisValueLabel {
                                            Text("\(Int(percentage))")
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                    }
                                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [5]))
                                        .foregroundStyle(Color.white.opacity(0.3))
                                }
                            }
                            .chartXAxis {
                                AxisMarks(values: .stride(by: 4)) { value in
                                    if let level = value.as(String.self) {
                                        AxisValueLabel {
                                            Text(level)
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                    }
                                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [5]))
                                        .foregroundStyle(Color.white.opacity(0.3))
                                }
                            }
                            
                            // 标记用户所在区间
                            HStack {
                                Spacer()
                                Text(LocalizedStringKey.yourResult.localized + ": " + getUserCategory(level: level))
                                    .font(.callout)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 10)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(8)
                            }
                            .padding(.top, 5)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white.opacity(0.1))
                        )
                        .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 10)
                    
                    // 解释区域
                    VStack(alignment: .leading, spacing: 15) {
                        Text(LocalizedStringKey.whatThisMeans.localized)
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        
                        Text(performanceDescription)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.bottom, 5)
                        
                        Text(LocalizedStringKey.visualMemoryExplanation1.localized)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.top, 4)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.15))
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                    )
                    .padding(.horizontal, 20)
                    
                    // 按钮区域
                    HStack(spacing: 20) {
                        // 返回菜单按钮
                        Button(action: {
                            // 触觉反馈
                            let impactMed = UIImpactFeedbackGenerator(style: .medium)
                            impactMed.impactOccurred()
                            onDismiss()
                        }) {
                            HStack {
                                Image(systemName: "house.fill")
                                    .font(.headline)
                                
                                Text(LocalizedStringKey.backToMenu.localized)
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                        }
                        
                        // 再次游戏按钮
                        Button(action: {
                            // 触觉反馈
                            let impactMed = UIImpactFeedbackGenerator(style: .medium)
                            impactMed.impactOccurred()
                            dismiss()
                            onRestart(level)
                        }) {
                            HStack {
                                Image(systemName: "play.fill")
                                    .font(.headline)
                                
                                Text(LocalizedStringKey.playAgain.localized)
                                    .font(.headline)
                            }
                            .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.8))
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 3)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(trailing: Button(action: {
            onDismiss()
        }) {
            Image(systemName: "xmark.circle.fill")
                .font(.title2)
                .foregroundColor(.white.opacity(0.7))
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        })
        .onAppear {
            isAnimating = true
            // 稍微延迟显示图表，以便有一个逐步显示的效果
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    showChart = true
                }
            }
        }
    }
    
    // 获取用户所在分布区间
    private func getUserCategory(level: Int) -> String {
        if level <= 5 {
            return LocalizedStringKey.belowAverage.localized
        } else if level <= 8 {
            return LocalizedStringKey.average.localized
        } else if level <= 12 {
            return LocalizedStringKey.good.localized
        } else {
            return LocalizedStringKey.excellent.localized
        }
    }
}

#Preview {
    VisualMemoryResultView(
        level: 12,
        onDismiss: {},
        onRestart: {_ in}
    )
    .environmentObject(GameDataManager())
} 