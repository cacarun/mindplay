//
//  ChimpTestResultView.swift
//  mindplay
//
//  Created for MindPlay app.
//

import SwiftUI
import Charts

struct ChimpTestResultView: View {
    @EnvironmentObject var gameDataManager: GameDataManager
    @Environment(\.dismiss) private var dismiss
    
    let maxLevel: Int
    let onDismiss: () -> Void
    let onRestart: () -> Void
    
    @State private var isAnimating = false
    @State private var showChart = false
    
    // 猩猩测试的主题色 - 使用蓝绿色和蓝色组合
    private let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.2, green: 0.6, blue: 0.8),
            Color(red: 0.1, green: 0.3, blue: 0.7)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // 性能评级文本
    private var percentileText: String {
        if maxLevel > 12 {
            return LocalizedStringKey.percentileExcellent.localized
        } else if maxLevel >= 9 {
            return LocalizedStringKey.percentileGood.localized
        } else if maxLevel >= 6 {
            return LocalizedStringKey.percentileAverage.localized
        } else {
            return LocalizedStringKey.percentileBelowAverage.localized
        }
    }
    
    // 性能说明
    private var performanceDescription: String {
        if maxLevel > 12 {
            return LocalizedStringKey.excellentChimpMemory.localized
        } else if maxLevel >= 9 {
            return LocalizedStringKey.goodChimpMemory.localized
        } else if maxLevel >= 6 {
            return LocalizedStringKey.averageChimpMemory.localized
        } else {
            return LocalizedStringKey.belowAverageChimpMemory.localized
        }
    }
    
    // 性能评级图标
    private var performanceIcon: String {
        if maxLevel > 12 {
            return "star.fill"
        } else if maxLevel >= 9 {
            return "hand.thumbsup.fill"
        } else if maxLevel >= 6 {
            return "checkmark.circle.fill"
        } else {
            return "arrow.up.circle.fill"
        }
    }
    
    // 模拟分布数据 - 基于图片中的分布曲线
    private let distributionData = [
        (level: 4, percentage: 5),
        (level: 5, percentage: 10),
        (level: 6, percentage: 15),
        (level: 7, percentage: 20),
        (level: 8, percentage: 25),
        (level: 9, percentage: 35),
        (level: 10, percentage: 25),
        (level: 11, percentage: 20),
        (level: 12, percentage: 15),
        (level: 13, percentage: 10),
        (level: 14, percentage: 5)
    ]
    
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
                            CGPoint(x: geometry.size.width * 0.5, y: geometry.size.height * 0.4),
                            CGPoint(x: geometry.size.width * 0.9, y: geometry.size.height * 0.6)
                        ]
                        
                        let sizes: [CGFloat] = [100, 80, 120, 90, 70, 110]
                        let opacities: [Double] = [0.08, 0.06, 0.1, 0.05, 0.08, 0.07]
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
                    
                    // 漂浮的数字
                    if showChart {
                        ForEach(0..<10) { i in
                            let numbers = [4, 5, 6, 7, 8, 9, 10, 11, 12, 13]
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
            
            // 内容视图
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
                        Text("\(maxLevel)")
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
                                ForEach(distributionData, id: \.level) { item in
                                    BarMark(
                                        x: .value(LocalizedStringKey.level.localized, String(item.level)),
                                        y: .value("", item.percentage)
                                    )
                                    .foregroundStyle(
                                        isHighlighted(level: item.level) ?
                                        Color.yellow.gradient : Color.white.opacity(0.5).gradient
                                    )
                                    .cornerRadius(6)
                                }
                            }
                            .chartYAxis {
                                AxisMarks(position: .leading, values: .automatic(desiredCount: 5)) { value in
                                    if let percentage = value.as(Int.self) {
                                        AxisValueLabel {
                                            Text("\(percentage)%")
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                    }
                                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [5]))
                                        .foregroundStyle(Color.white.opacity(0.3))
                                }
                            }
                            .chartXAxis {
                                AxisMarks { value in
                                    AxisValueLabel {
                                        if let level = value.as(String.self) {
                                            Text(level)
                                                .font(.caption)
                                                .foregroundColor(
                                                    isHighlighted(level: Int(level) ?? 0) ?
                                                    .yellow : .white.opacity(0.7)
                                                )
                                        }
                                    }
                                }
                            }
                            .frame(height: 220)
                            .padding(.bottom, 5)
                            
                            // 标记用户所在区间
                            Text(LocalizedStringKey.yourResult.localized + ": " + getUserCategory(level: maxLevel))
                                .font(.callout)
                                .foregroundColor(.white.opacity(0.9))
                                .padding(.bottom, 5)
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
                        
                        Text(LocalizedStringKey.chimpOutperformHumans.localized)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.bottom, 5)
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
                            onRestart()
                        }) {
                            HStack {
                                Image(systemName: "play.fill")
                                    .font(.headline)
                                
                                Text(LocalizedStringKey.playAgain.localized)
                                    .font(.headline)
                            }
                            .foregroundColor(Color(red: 0.1, green: 0.3, blue: 0.7))
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
    
    // 判断当前条形是否为用户所在区间
    private func isHighlighted(level: Int) -> Bool {
        if maxLevel == level {
            return true
        } else if maxLevel > 14 && level == 14 { // 对于超过14的情况，高亮14+的区间
            return true
        }
        return false
    }
    
    // 获取用户所在分布区间
    private func getUserCategory(level: Int) -> String {
        if level <= 5 {
            return "5"
        } else if level <= 6 {
            return "6"
        } else if level <= 7 {
            return "7"
        } else if level <= 8 {
            return "8"
        } else if level <= 9 {
            return "9"
        } else if level <= 10 {
            return "10"
        } else if level <= 11 {
            return "11" 
        } else if level <= 12 {
            return "12"
        } else if level <= 13 {
            return "13"
        } else {
            return "14+"
        }
    }
}

#Preview {
    ChimpTestResultView(
        maxLevel: 9,
        onDismiss: {},
        onRestart: {}
    )
    .environmentObject(GameDataManager())
} 