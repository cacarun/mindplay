//
//  NumberMemoryResultView.swift
//  mindplay
//
//  Created for MindPlay app.
//

import SwiftUI
import Charts

struct NumberMemoryResultView: View {
    @EnvironmentObject var gameDataManager: GameDataManager
    @Environment(\.dismiss) private var dismiss
    
    let level: Int
    let digitsRemembered: Int
    let onDismiss: () -> Void
    let onRestart: () -> Void
    @State private var isAnimating = false
    
    // 性能评级文本
    private var percentileText: String {
        if digitsRemembered > 11 {
            return LocalizedStringKey.percentileExcellent.localized
        } else if digitsRemembered >= 9 {
            return LocalizedStringKey.percentileGood.localized
        } else if digitsRemembered >= 7 {
            return LocalizedStringKey.percentileAverage.localized
        } else {
            return LocalizedStringKey.percentileBelowAverage.localized
        }
    }
    
    // 性能说明
    private var performanceDescription: String {
        if digitsRemembered > 11 {
            return LocalizedStringKey.excellentNumberMemory.localized
        } else if digitsRemembered >= 9 {
            return LocalizedStringKey.goodNumberMemory.localized
        } else if digitsRemembered >= 7 {
            return LocalizedStringKey.averageNumberMemory.localized
        } else {
            return LocalizedStringKey.belowAverageNumberMemory.localized
        }
    }
    
    // 背景渐变色 - 使用紫色和蓝色渐变表示记忆和数字
    private let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.6, green: 0.4, blue: 0.8),
            Color(red: 0.3, green: 0.4, blue: 0.9)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // 模拟分布数据
    private let distributionData = [
        (digits: "1-4", percentage: 5),
        (digits: "5-6", percentage: 20),
        (digits: "7-8", percentage: 35),
        (digits: "9-11", percentage: 30),
        (digits: "12+", percentage: 10)
    ]
    
    var body: some View {
        ZStack {
            // 渐变背景
            backgroundGradient
                .ignoresSafeArea()
            
            // 背景装饰元素
            GeometryReader { geometry in
                ZStack {
                    // 添加数字装饰元素
                    ForEach(0..<10) { i in
                        let numbers = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
                        let sizes: [CGFloat] = [28, 36, 24, 32, 40, 30, 26, 34, 38, 28]
                        let positions = generateRandomPositions(count: 10, in: geometry.size)
                        let rotations: [Double] = [-10, 15, -5, 20, -15, 10, -20, 5, -25, 30]
                        let opacities: [Double] = [0.15, 0.1, 0.12, 0.08, 0.14, 0.09, 0.13, 0.11, 0.07, 0.16]
                        let durations: [Double] = [8, 7, 9, 6, 10, 7.5, 8.5, 6.5, 9.5, 7]
                        
                        Text(numbers[i])
                            .font(.system(size: sizes[i], weight: .bold))
                            .foregroundColor(.white.opacity(opacities[i]))
                            .position(positions[i])
                            .rotationEffect(.degrees(rotations[i]))
                            .offset(y: isAnimating ? 10 : -10)
                            .animation(
                                Animation.easeInOut(duration: durations[i])
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
                VStack(spacing: 24) {
                    // 结果标题
                    Text(LocalizedStringKey.results.localized)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.top, 30)
                        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 1, y: 1)
                    
                    // Header with main result
                    VStack(spacing: 10) {
                        Text(LocalizedStringKey.digitsRemembered.localized)
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text("\(digitsRemembered)")
                            .font(.system(size: 72, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 1, y: 1)
                            .scaleEffect(isAnimating ? 1.05 : 0.95)
                            .animation(
                                Animation.easeInOut(duration: 2)
                                    .repeatForever(autoreverses: true),
                                value: isAnimating
                            )
                        
                        Text(percentileText)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.top, 4)
                    }
                    .padding(20)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                    
                    // 表现评级
                    VStack(alignment: .leading, spacing: 16) {
                        Text(LocalizedStringKey.performance.localized)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        // 表现指示器
                        performanceIndicator
                            .padding(.vertical, 10)
                        
                        Text(performanceDescription)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.top, 5)
                    }
                    .padding()
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                    
                    // 统计数据
                    VStack(alignment: .leading, spacing: 16) {
                        Text(LocalizedStringKey.statistics.localized)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        // Chart of distribution
                        VStack(alignment: .leading, spacing: 8) {
                            Text(LocalizedStringKey.distribution.localized)
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.9))
                            
                            // 图表容器
                            VStack {
                                HStack(alignment: .bottom, spacing: 4) {
                                    ForEach(distributionData, id: \.digits) { item in
                                        // 每个柱子
                                        VStack(spacing: 4) {
                                            // 条形图
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(getBarColor(for: item.digits))
                                                .frame(height: CGFloat(item.percentage) * 2)
                                            
                                            // X轴标签
                                            Text(item.digits)
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.8))
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                }
                                .padding(.top, 20)
                                .padding(.horizontal, 5)
                                
                                // Y轴线
                                HStack {
                                    // Y轴刻度
                                    VStack(alignment: .trailing, spacing: 15) {
                                        Text("50%")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.6))
                                        
                                        Text("25%")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.6))
                                        
                                        Text("0%")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                    .frame(width: 30)
                                    
                                    // 网格线
                                    VStack(alignment: .leading, spacing: 0) {
                                        Rectangle()
                                            .frame(height: 1)
                                            .foregroundColor(.white.opacity(0.2))
                                            .padding(.bottom, 24)
                                        
                                        Rectangle()
                                            .frame(height: 1)
                                            .foregroundColor(.white.opacity(0.2))
                                            .padding(.bottom, 24)
                                        
                                        Rectangle()
                                            .frame(height: 1)
                                            .foregroundColor(.white.opacity(0.2))
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                .frame(height: 100)
                                .padding(.bottom, 10)
                                .overlay(
                                    yourResultOverlay,
                                    alignment: .topTrailing
                                )
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 5)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                    
                    // 解释
                    VStack(alignment: .leading, spacing: 16) {
                        Text(LocalizedStringKey.whatThisMeans.localized)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(LocalizedStringKey.numberExplanation.localized)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                    
                    // Action buttons
                    HStack(spacing: 16) {
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
                        
                        Button(action: {
                            dismiss()
                            onRestart()
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
                            .foregroundColor(Color(red: 0.5, green: 0.3, blue: 0.8))
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 3)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 20)
                }
                .padding(.bottom, 30)
            }
        }
        .navigationBarTitle(LocalizedStringKey.results.localized, displayMode: .inline)
        .navigationBarItems(trailing: Button(action: {
            onDismiss()
        }) {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.white)
        })
        .onAppear {
            isAnimating = true
        }
    }
    
    // 表现评级指示器
    private var performanceIndicator: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // 背景条
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.2))
                    .frame(height: 10)
                
                // 评级指示器
                performanceColorBars(width: geometry.size.width)
                
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
    }
    
    // 分解评级颜色条
    private func performanceColorBars(width: CGFloat) -> some View {
        HStack(spacing: 0) {
            // 四个评级区域
            Rectangle()
                .fill(Color.red.opacity(0.8))
                .frame(width: width * 0.25, height: 10)
            
            Rectangle()
                .fill(Color.orange.opacity(0.8))
                .frame(width: width * 0.25, height: 10)
            
            Rectangle()
                .fill(Color.green.opacity(0.8))
                .frame(width: width * 0.25, height: 10)
            
            Rectangle()
                .fill(Color.blue.opacity(0.8))
                .frame(width: width * 0.25, height: 10)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // 计算指示器位置
    private func indicatorPosition(in width: CGFloat) -> CGFloat {
        let position: CGFloat
        if digitsRemembered <= 4 {
            // 初级水平 (0-25%)
            position = width * 0.125
        } else if digitsRemembered <= 6 {
            // 基础水平 (25-50%)
            position = width * 0.375
        } else if digitsRemembered <= 8 {
            // 普通水平 (50-75%)
            position = width * 0.625
        } else {
            // 高级水平 (75-100%)
            position = width * 0.875
        }
        return max(10, min(width - 10, position)) // 确保不超出边界
    }
    
    // 您的结果覆盖层
    private var yourResultOverlay: some View {
        // 用户所在区间
        let userCategory = getUserCategory(digits: digitsRemembered)
        let index = distributionData.firstIndex { $0.digits == userCategory }
        let xOffset = CGFloat(index ?? 2) / CGFloat(distributionData.count) * 0.9 + 0.05
        
        return Text(LocalizedStringKey.yourResult.localized)
            .font(.caption)
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(Color(red: 0.5, green: 0.3, blue: 0.8))
            .cornerRadius(8)
            .offset(x: -55)
            .offset(x: UIScreen.main.bounds.width * xOffset * 0.82)
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
    
    // 获取用户所在分布区间
    private func getUserCategory(digits: Int) -> String {
        if digits <= 4 {
            return "1-4"
        } else if digits <= 6 {
            return "5-6"
        } else if digits <= 8 {
            return "7-8"
        } else if digits <= 11 {
            return "9-11"
        } else {
            return "12+"
        }
    }
    
    // 根据类别获取柱状图颜色
    private func getBarColor(for category: String) -> Color {
        let userCategory = getUserCategory(digits: digitsRemembered)
        if category == userCategory {
            return Color(red: 0.5, green: 0.3, blue: 0.8)
        } else {
            return Color.white.opacity(0.6)
        }
    }
}

#Preview {
    NavigationStack {
        NumberMemoryResultView(
            level: 8,
            digitsRemembered: 11,
            onDismiss: {},
            onRestart: {}
        )
        .environmentObject(GameDataManager())
    }
} 