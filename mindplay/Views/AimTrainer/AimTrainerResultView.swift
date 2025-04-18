//
//  AimTrainerResultView.swift
//  mindplay
//
//  Created for MindPlay app.
//

import SwiftUI
import Charts

struct AimTrainerResultView: View {
    @EnvironmentObject var gameDataManager: GameDataManager
    @Environment(\.dismiss) private var dismiss
    let onDismiss: () -> Void
    
    // 添加重新开始游戏的回调函数
    let onRestart: () -> Void
    
    // 新增变量用于控制导航到新游戏
    @State private var startNewGame = false
    @State private var isAnimating = false
    
    let totalTimeElapsed: TimeInterval
    let hitTimes: [TimeInterval]
    
    init(onDismiss: @escaping () -> Void, onRestart: @escaping () -> Void, totalTimeElapsed: TimeInterval, hitTimes: [TimeInterval]) {
        self.onDismiss = onDismiss
        self.onRestart = onRestart
        self.totalTimeElapsed = totalTimeElapsed
        self.hitTimes = hitTimes
    }
    
    // 背景渐变色 - 使用绿色和蓝色渐变表示瞄准和准确性
    private let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.2, green: 0.7, blue: 0.4),
            Color(red: 0.1, green: 0.5, blue: 0.9)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // 派生数据
    private var averageTimePerTarget: Double {
        guard !hitTimes.isEmpty else { return 0 }
        return totalTimeElapsed / Double(hitTimes.count) * 1000 // 转换为毫秒
    }
    
    // 计算点击时间间隔（毫秒）
    private var clickIntervals: [Double] {
        var intervals: [Double] = []
        if hitTimes.count > 1 {
            for i in 1..<hitTimes.count {
                let interval = (hitTimes[i] - hitTimes[i-1]) * 1000 // 转换为毫秒
                intervals.append(interval)
            }
        }
        return intervals
    }
    
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
        // 反向评级，因为时间越低越好
        if averageTimePerTarget > 1000 {
            // 需要练习区域 (0-20%)
            position = width * 0.1
        } else if averageTimePerTarget > 800 {
            // 一般区域 (20-40%)
            position = width * 0.3
        } else if averageTimePerTarget > 600 {
            // 良好区域 (40-60%)
            position = width * 0.5
        } else if averageTimePerTarget > 400 {
            // 优秀区域 (60-80%)
            position = width * 0.7
        } else {
            // 卓越区域 (80-100%)
            position = width * 0.9
        }
        return max(10, min(width - 10, position)) // 确保不超出边界
    }
    
    // 性能评级
    private var performanceRating: String {
        if averageTimePerTarget < 400 {
            return LocalizedStringKey.exceptional.localized
        } else if averageTimePerTarget < 600 {
            return LocalizedStringKey.excellent.localized
        } else if averageTimePerTarget < 800 {
            return LocalizedStringKey.good.localized
        } else if averageTimePerTarget < 1000 {
            return LocalizedStringKey.average.localized
        } else {
            return LocalizedStringKey.belowAverage.localized
        }
    }
    
    // 性能评级描述
    private var performanceDescription: String {
        if averageTimePerTarget < 400 {
            return LocalizedStringKey.exceptionalAim.localized
        } else if averageTimePerTarget < 600 {
            return LocalizedStringKey.excellentAim.localized
        } else if averageTimePerTarget < 800 {
            return LocalizedStringKey.goodAim.localized
        } else if averageTimePerTarget < 1000 {
            return LocalizedStringKey.averageAim.localized
        } else {
            return LocalizedStringKey.belowAverageAim.localized
        }
    }
    
    // 柱状图数据处理
    private func prepareHistogramData() -> [HistogramBin] {
        guard !clickIntervals.isEmpty else { return [] }
        
        // 按200毫秒进行分组
        let bins = stride(from: 0, through: 2000, by: 200).map { startValue -> HistogramBin in
            let endValue = startValue + 200
            let count = clickIntervals.filter { $0 >= Double(startValue) && $0 < Double(endValue) }.count
            return HistogramBin(
                startValue: startValue,
                endValue: endValue,
                count: count
            )
        }
        
        return bins
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
                    Text(LocalizedStringKey.results.localized)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.top, 30)
                        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 1, y: 1)
                    
                    // 平均时间显示
                    VStack(spacing: 8) {
                        Text(LocalizedStringKey.avgTimePerTarget.localized)
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text(String(format: "%.1f ms", averageTimePerTarget))
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
                    
                    // 表现评级面板
                    VStack(spacing: 10) {
                        Text(LocalizedStringKey.performance.localized)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        // 表现评级条
                        performanceRatingView
                            .padding(.horizontal)
                        
                        // 评级描述
                        Text(performanceRating)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.top, 10)
                            .padding(.bottom, 5)
                        
                        // 评级详细描述
                        Text(performanceDescription)
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
                    
                    // 统计数据
                    VStack(alignment: .leading, spacing: 16) {
                        Text(LocalizedStringKey.statistics.localized)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        HStack(spacing: 20) {
                            // 左列
                            VStack(alignment: .center, spacing: 5) {
                                Text(LocalizedStringKey.totalTime.localized)
                                    .font(.headline)
                                    .foregroundColor(.white.opacity(0.9))
                                
                                Text(String(format: "%.1f s", totalTimeElapsed))
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            
                            // 右列
                            VStack(alignment: .center, spacing: 5) {
                                Text(LocalizedStringKey.totalTargets.localized)
                                    .font(.headline)
                                    .foregroundColor(.white.opacity(0.9))
                                
                                Text("\(hitTimes.count)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        // 第二行
                        if let fastest = clickIntervals.min(), let slowest = clickIntervals.max() {
                            HStack(spacing: 20) {
                                // 最快点击
                                VStack(alignment: .center, spacing: 5) {
                                    Text(LocalizedStringKey.fastestClick.localized)
                                        .font(.headline)
                                        .foregroundColor(.white.opacity(0.9))
                                    
                                    Text(String(format: "%.1f ms", fastest))
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity)
                                
                                // 最慢点击
                                VStack(alignment: .center, spacing: 5) {
                                    Text(LocalizedStringKey.slowestClick.localized)
                                        .font(.headline)
                                        .foregroundColor(.white.opacity(0.9))
                                    
                                    Text(String(format: "%.1f ms", slowest))
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                    
                    // 分布图
                    VStack(alignment: .leading, spacing: 15) {
                        Text(LocalizedStringKey.distribution.localized)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        if !clickIntervals.isEmpty {
                            // 定制化图表
                            distributionChartView
                                .frame(height: 200)
                        } else {
                            Text(LocalizedStringKey.noData.localized)
                                .foregroundColor(.white.opacity(0.9))
                                .frame(height: 200, alignment: .center)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                    
                    // 解释
                    VStack(alignment: .leading, spacing: 15) {
                        Text(LocalizedStringKey.whatThisMeans.localized)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(performanceDescription)
                            .foregroundColor(.white.opacity(0.9))
                        
                        Divider()
                            .background(Color.white.opacity(0.3))
                            .padding(.vertical, 5)
                        
                        Text(LocalizedStringKey.aimExplanation1.localized)
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.bottom, 5)
                        
                        Text(LocalizedStringKey.aimExplanation2.localized)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding()
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                    
                    // 按钮
                    HStack(spacing: 20) {
                        // 返回主菜单
                        Button {
                            // 回到主菜单
                            onDismiss()
                            // 添加触觉反馈
                            let impactMed = UIImpactFeedbackGenerator(style: .medium)
                            impactMed.impactOccurred()
                        } label: {
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
                        
                        // 再玩一次
                        Button {
                            // 重新开始游戏
                            onRestart()
                            dismiss()
                            // 添加触觉反馈
                            let impactMed = UIImpactFeedbackGenerator(style: .medium)
                            impactMed.impactOccurred()
                        } label: {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                    .font(.headline)
                                Text(LocalizedStringKey.playAgain.localized)
                                    .font(.headline)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.4))
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
            Circle().path(in: CGRect(x: 0, y: 0, width: 40, height: 40)),
            RoundedRectangle(cornerRadius: 10).path(in: CGRect(x: 0, y: 0, width: 40, height: 40)),
            Circle().path(in: CGRect(x: 0, y: 0, width: 30, height: 30)),
            RoundedRectangle(cornerRadius: 20).path(in: CGRect(x: 0, y: 0, width: 30, height: 50)),
            Circle().path(in: CGRect(x: 0, y: 0, width: 25, height: 25))
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
    
    // 自定义分布图视图
    private var distributionChartView: some View {
        let data = prepareHistogramData()
        let maxCount = data.map { $0.count }.max() ?? 0
        
        return VStack(spacing: 5) {
            // 绘制条形图
            HStack(alignment: .bottom, spacing: 2) {
                ForEach(data) { bin in
                    VStack {
                        // 计算条形图高度比例
                        let heightPercentage = maxCount > 0 ? Double(bin.count) / Double(maxCount) : 0
                        
                        // 条形图
                        RoundedRectangle(cornerRadius: 3)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.7),
                                        Color.white.opacity(0.3)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: CGFloat(heightPercentage) * 150)
                        
                        // 标签 - 只显示一部分
                        if shouldShowLabel(for: bin) {
                            Text("\(bin.startValue)")
                                .font(.system(size: 9))
                                .foregroundColor(.white.opacity(0.8))
                                .rotationEffect(.degrees(-45))
                                .offset(y: 5)
                        } else {
                            Spacer().frame(height: 20)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 10)
            .padding(.horizontal, 5)
            
            // X轴标签说明
            Text(LocalizedStringKey.msPerClick.localized)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 5)
        }
    }
    
    // 决定是否显示特定间隔的标签
    private func shouldShowLabel(for bin: HistogramBin) -> Bool {
        // 只显示特定位置的标签以避免拥挤
        return [0, 400, 800, 1200, 1600, 2000].contains(bin.startValue)
    }
}

// 直方图数据结构
struct HistogramBin: Identifiable {
    let id = UUID()
    let startValue: Int
    let endValue: Int
    let count: Int
}

#Preview {
    NavigationStack {
        AimTrainerResultView(
            onDismiss: {},
            onRestart: {},
            totalTimeElapsed: 15.5,
            hitTimes: [0.5, 1.0, 1.5, 2.0, 2.6, 3.1, 3.7, 4.2, 4.8, 5.3]
        )
        .environmentObject(GameDataManager())
    }
} 