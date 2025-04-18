//
//  SequenceMemoryResultView.swift
//  mindplay
//
//  Created for MindPlay app.
//

import SwiftUI
import Charts

struct SequenceMemoryResultView: View {
    @EnvironmentObject var gameDataManager: GameDataManager
    @Environment(\.dismiss) private var dismiss
    
    let level: Int
    let gridSize: Int
    let onDismiss: () -> Void
    
    @State private var isAnimating = false
    
    // 背景渐变色 - 使用紫蓝色渐变表示成就感
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
                ratingColorBars(width: geometry.size.width)
                
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
    
    // 分解评级颜色条
    private func ratingColorBars(width: CGFloat) -> some View {
        HStack(spacing: 0) {
            // 五个评级区域
            Rectangle()
                .fill(Color.red.opacity(0.8))
                .frame(width: width * 0.2, height: 10)
            
            Rectangle()
                .fill(Color.orange.opacity(0.8))
                .frame(width: width * 0.2, height: 10)
            
            Rectangle()
                .fill(Color.yellow.opacity(0.8))
                .frame(width: width * 0.2, height: 10)
            
            Rectangle()
                .fill(Color.green.opacity(0.8))
                .frame(width: width * 0.2, height: 10)
            
            Rectangle()
                .fill(Color.blue.opacity(0.8))
                .frame(width: width * 0.2, height: 10)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // 计算指示器位置
    private func indicatorPosition(in width: CGFloat) -> CGFloat {
        let position: CGFloat
        if level < 7 {
            // 需要练习区域 (0-20%)
            position = width * 0.1
        } else if level < 11 {
            // 一般记忆区域 (20-40%)
            position = width * 0.3
        } else if level < 16 {
            // 良好记忆区域 (40-60%)
            position = width * 0.5
        } else if level < 21 {
            // 优秀记忆区域 (60-80%)
            position = width * 0.7
        } else {
            // 卓越记忆区域 (80-100%)
            position = width * 0.9
        }
        return max(10, min(width - 10, position)) // 确保不超出边界
    }
    
    // 根据级别确定评级
    private var ratingDescription: String {
        if level < 7 {
            return LocalizedStringKey.needsPractice.localized
        } else if level < 11 {
            return LocalizedStringKey.fairMemory.localized
        } else if level < 16 {
            return LocalizedStringKey.goodMemory.localized
        } else if level < 21 {
            return LocalizedStringKey.greatMemory.localized
        } else {
            return LocalizedStringKey.exceptionalMemory.localized
        }
    }
    
    // 根据级别确定评级详细描述
    private var ratingDetailedDescription: String {
        if level < 7 {
            return LocalizedStringKey.needsPracticeDesc.localized
        } else if level < 11 {
            return LocalizedStringKey.fairMemoryDesc.localized
        } else if level < 16 {
            return LocalizedStringKey.goodMemoryDesc.localized
        } else if level < 21 {
            return LocalizedStringKey.greatMemoryDesc.localized
        } else {
            return LocalizedStringKey.exceptionalMemoryDesc.localized
        }
    }
    
    var body: some View {
        ZStack {
            // 渐变背景
            backgroundGradient
                .ignoresSafeArea()
            
            // 背景装饰元素
            GeometryReader { geometry in
                ZStack {
                    // 装饰性图形
                    decorativeShapes(in: geometry)
                }
            }
            
            ScrollView {
                VStack(spacing: 24) {
                    // 结果标题
                    Text(LocalizedStringKey.sequenceResults.localized)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.top, 30)
                        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 1, y: 1)
                    
                    // 达到的级别
                    levelDisplay
                    
                    // 记忆表现指标
                    memoryPerformancePanel
                    
                    // 统计信息
                    statisticsPanel
                    
                    // 分布图
                    distributionChart
                    
                    // 说明部分
                    interpretationPanel
                    
                    // 操作按钮
                    actionButtons
                }
                .padding()
            }
        }
        .navigationBarTitle(LocalizedStringKey.results.localized, displayMode: .inline)
        .navigationBarItems(trailing: Button(action: {
            onDismiss()
        }) {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.gray)
        })
        .onAppear {
            isAnimating = true
        }
    }
    
    // 分解为子视图 - 装饰性形状
    private func decorativeShapes(in geometry: GeometryProxy) -> some View {
        ZStack {
            ForEach(0..<5, id: \.self) { i in
                decorativeShape(for: i, in: geometry)
            }
        }
    }
    
    private func decorativeShape(for index: Int, in geometry: GeometryProxy) -> some View {
        let shapes = [
            RoundedRectangle(cornerRadius: 10).path(in: CGRect(x: 0, y: 0, width: 40, height: 40)),
            Circle().path(in: CGRect(x: 0, y: 0, width: 40, height: 40)),
            RoundedRectangle(cornerRadius: 20).path(in: CGRect(x: 0, y: 0, width: 30, height: 50)),
            Circle().path(in: CGRect(x: 0, y: 0, width: 30, height: 30)),
            RoundedRectangle(cornerRadius: 8).path(in: CGRect(x: 0, y: 0, width: 25, height: 25))
        ]
        
        let widthFactors: [CGFloat] = [0.1, 0.9, 0.15, 0.85, 0.2]
        let heightFactors: [CGFloat] = [0.1, 0.15, 0.9, 0.85, 0.2]
        let rotationDegrees: [Double] = [10, -8, 15, -12, 5]
        let animationDurations: [Double] = [4, 5, 6, 4.5, 5.5]
        
        return shapes[index % shapes.count]
            .fill(Color.white.opacity(0.1))
            .position(
                x: geometry.size.width * widthFactors[index],
                y: geometry.size.height * heightFactors[index]
            )
            .rotationEffect(.degrees(isAnimating ? rotationDegrees[index] : 0))
            .animation(
                Animation.easeInOut(duration: animationDurations[index])
                    .repeatForever(autoreverses: true),
                value: isAnimating
            )
    }
    
    // 分解为子视图 - 级别显示
    private var levelDisplay: some View {
        VStack(spacing: 8) {
            Text(LocalizedStringKey.level.localized)
                .font(.headline)
                .foregroundColor(.white.opacity(0.9))
            
            Text("\(level)")
                .font(.system(size: 64, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.2), radius: 2, x: 1, y: 1)
                .scaleEffect(isAnimating ? 1.05 : 0.95)
                .animation(
                    Animation.easeInOut(duration: 2)
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )
        }
    }
    
    // 分解为子视图 - 记忆表现面板
    private var memoryPerformancePanel: some View {
        VStack(spacing: 10) {
            Text(LocalizedStringKey.memory.localized)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            // 表现评级条
            performanceRatingView
                .padding(.horizontal)
            
            // 评级描述
            Text(ratingDescription)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.top, 10)
                .padding(.bottom, 5)
            
            // 评级详细描述
            Text(ratingDetailedDescription)
                .font(.headline)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .background(Color.white.opacity(0.15))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
    
    // 分解为子视图 - 统计面板
    private var statisticsPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(LocalizedStringKey.statistics.localized)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            HStack(spacing: 20) {
                // 最大级别
                VStack(alignment: .center, spacing: 5) {
                    Text(LocalizedStringKey.level.localized)
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text("\(level)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                
                // 记忆单元数
                VStack(alignment: .center, spacing: 5) {
                    Text(LocalizedStringKey.cells.localized)
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text("\(level)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(Color.white.opacity(0.15))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
    
    // 分解为子视图 - 分布图
    private var distributionChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(LocalizedStringKey.distribution.localized)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.top, 8)
            
            // 分布图内容
            distributionChartContent
        }
        .padding()
        .background(Color.white.opacity(0.15))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
    
    // 分布图内容
    private var distributionChartContent: some View {
        ZStack(alignment: .bottomLeading) {
            // 背景网格线
            VStack(spacing: 0) {
                ForEach(0..<5, id: \.self) { _ in
                    Divider()
                        .background(Color.white.opacity(0.3))
                    Spacer()
                }
                Divider()
                    .background(Color.white.opacity(0.3))
            }
            
            HStack(spacing: 0) {
                ForEach(0..<30, id: \.self) { _ in
                    Divider()
                        .background(Color.white.opacity(0.1))
                    Spacer()
                }
                Divider()
                    .background(Color.white.opacity(0.1))
            }
            
            // 分布曲线和用户指示器
            bellCurvePath
            userPositionIndicator
            
            // X轴标签
            distributionChartLabels
        }
        .frame(height: 150)
        .padding(.horizontal, 10)
    }
    
    // 分布曲线路径
    private var bellCurvePath: some View {
        ZStack {
            // 贝尔曲线填充
            Path { path in
                let width: CGFloat = 300
                let height: CGFloat = 120
                
                // 起点 (左下)
                path.move(to: CGPoint(x: 0, y: height))
                
                // 初始小峰值 (极低分数不太常见)
                path.addLine(to: CGPoint(x: width * 0.1, y: height * 0.7))
                path.addLine(to: CGPoint(x: width * 0.15, y: height * 0.4))
                
                // 第一个小峰值后的下降
                path.addLine(to: CGPoint(x: width * 0.2, y: height * 0.65))
                
                // 主曲线上升
                path.addLine(to: CGPoint(x: width * 0.3, y: height * 0.3))
                path.addLine(to: CGPoint(x: width * 0.4, y: height * 0.1))
                
                // 主曲线峰值
                path.addLine(to: CGPoint(x: width * 0.5, y: height * 0.05))
                
                // 主曲线下降
                path.addLine(to: CGPoint(x: width * 0.6, y: height * 0.1))
                path.addLine(to: CGPoint(x: width * 0.7, y: height * 0.3))
                path.addLine(to: CGPoint(x: width * 0.8, y: height * 0.5))
                path.addLine(to: CGPoint(x: width * 0.9, y: height * 0.7))
                path.addLine(to: CGPoint(x: width, y: height * 0.8))
                
                // 完成路径回到起点以填充
                path.addLine(to: CGPoint(x: width, y: height))
                path.closeSubpath()
            }
            .fill(Color.white.opacity(0.2))
            
            // 贝尔曲线描边
            Path { path in
                let width: CGFloat = 300
                let height: CGFloat = 120
                
                // 起点 (左下)
                path.move(to: CGPoint(x: 0, y: height))
                
                // 初始小峰值 (极低分数不太常见)
                path.addLine(to: CGPoint(x: width * 0.1, y: height * 0.7))
                path.addLine(to: CGPoint(x: width * 0.15, y: height * 0.4))
                
                // 第一个小峰值后的下降
                path.addLine(to: CGPoint(x: width * 0.2, y: height * 0.65))
                
                // 主曲线上升
                path.addLine(to: CGPoint(x: width * 0.3, y: height * 0.3))
                path.addLine(to: CGPoint(x: width * 0.4, y: height * 0.1))
                
                // 主曲线峰值
                path.addLine(to: CGPoint(x: width * 0.5, y: height * 0.05))
                
                // 主曲线下降
                path.addLine(to: CGPoint(x: width * 0.6, y: height * 0.1))
                path.addLine(to: CGPoint(x: width * 0.7, y: height * 0.3))
                path.addLine(to: CGPoint(x: width * 0.8, y: height * 0.5))
                path.addLine(to: CGPoint(x: width * 0.9, y: height * 0.7))
                path.addLine(to: CGPoint(x: width, y: height * 0.8))
            }
            .stroke(Color.white, lineWidth: 2)
            
            // 数据点
            distributionDataPoints
        }
    }
    
    // 分布图上的数据点
    private var distributionDataPoints: some View {
        ZStack {
            ForEach(0..<12, id: \.self) { i in
                let width: CGFloat = 300
                let height: CGFloat = 120
                let x = width * (0.15 + CGFloat(i) * 0.07)
                let y: CGFloat = dataPointYPosition(for: i, height: height)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 6, height: 6)
                    .position(x: x, y: y)
            }
        }
    }
    
    // 计算数据点的Y坐标
    private func dataPointYPosition(for index: Int, height: CGFloat) -> CGFloat {
        if index < 1 {
            return height * 0.4
        } else if index < 4 {
            return height * (0.3 - CGFloat(index) * 0.06)
        } else if index < 7 {
            return height * (0.05 + (CGFloat(index) - 4) * 0.05)
        } else {
            return height * (0.2 + (CGFloat(index) - 7) * 0.1)
        }
    }
    
    // 用户位置指示器
    private var userPositionIndicator: some View {
        ZStack {
            let width: CGFloat = 300
            let height: CGFloat = 120
            let userPositionX = getUserPositionX()
            
            // 用户位置垂直线
            Rectangle()
                .fill(Color.white)
                .frame(width: 2, height: height * 0.9)
                .position(x: width * userPositionX, y: height * 0.45)
            
            // 用户位置标记
            Circle()
                .fill(Color.white)
                .frame(width: 12, height: 12)
                .position(x: width * userPositionX, y: height * getUserPositionY())
        }
    }
    
    // X轴标签
    private var distributionChartLabels: some View {
        HStack(spacing: 0) {
            ForEach(0..<7) { i in
                Text("\(i * 5)")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
                    .frame(width: 20, alignment: .center)
                
                if i < 6 {
                    Spacer()
                }
            }
        }
        .padding(.top, 125)
    }
    
    // 分解为子视图 - 解释面板
    private var interpretationPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(LocalizedStringKey.whatThisMeans.localized)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(performanceDescription)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                
            // 关于记忆的其他解释
            Text(LocalizedStringKey.memoryExplanation.localized)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .padding(.top, 4)
        }
        .padding()
        .background(Color.white.opacity(0.15))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
    
    // 分解为子视图 - 操作按钮
    private var actionButtons: some View {
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
        }
        .padding(.horizontal)
        .padding(.vertical, 20)
    }
    
    // MARK: - Helper Methods
    
    // 获取用户在分布图中的X坐标位置
    private func getUserPositionX() -> CGFloat {
        // 根据等级确定用户在分布图中的位置
        // 最大值为1.0 (右边缘)
        switch level {
        case 0...2: return 0.2  // 较低水平在左侧
        case 3...5: return 0.35 // 低于平均水平
        case 6...8: return 0.5  // 平均水平在中间
        case 9...12: return 0.7 // 高于平均水平
        default: return 0.85    // 极高水平在右侧
        }
    }
    
    // 获取用户在分布图中的Y坐标位置
    private func getUserPositionY() -> CGFloat {
        // 根据等级确定用户在曲线上的高度
        // 曲线最高点约为0.05，最低点为1.0
        switch level {
        case 0...2: return 0.65  // 第一个小峰值
        case 3...5: return 0.3   // 主曲线上升段
        case 6...8: return 0.05  // 主曲线顶点
        case 9...12: return 0.15 // 主曲线下降段
        default: return 0.4      // 曲线尾部
        }
    }
    
    // 表现描述
    private var performanceDescription: String {
        switch level {
        case 0...6: return LocalizedStringKey.needsPracticeDesc.localized
        case 7...10: return LocalizedStringKey.fairMemoryDesc.localized
        case 11...15: return LocalizedStringKey.goodMemoryDesc.localized
        case 16...20: return LocalizedStringKey.greatMemoryDesc.localized
        default: return LocalizedStringKey.exceptionalMemoryDesc.localized
        }
    }
}

#Preview {
    SequenceMemoryResultView(level: 9, gridSize: 9) {
        // Dismiss action
    }
    .environmentObject(GameDataManager())
}
