//
//  SchulteTableResultView.swift
//  mindplay
//
//  Created for MindPlay app.
//

import SwiftUI
import Charts

struct SchulteTableResultView: View {
    
    let completionTime: TimeInterval
    let tableSize: Int
    let onDismiss: () -> Void
    let onRestart: (Int) -> Void
    
    @EnvironmentObject var gameDataManager: GameDataManager
    @State private var showingShareSheet = false
    @State private var screenshot: UIImage? = nil
    @State private var isAnimating = false
    
    // 舒尔特表格游戏的主题渐变色 - 薄荷绿/青色
    private let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.2, green: 0.7, blue: 0.6),
            Color(red: 0.1, green: 0.5, blue: 0.8)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 渐变背景
                backgroundGradient
                    .ignoresSafeArea()
                
                // 背景装饰元素
                ZStack {
                    // 添加一些装饰性方格，代表舒尔特表格
                    ForEach(0..<8) { i in
                        let positions = [
                            CGPoint(x: geometry.size.width * 0.1, y: geometry.size.height * 0.2),
                            CGPoint(x: geometry.size.width * 0.9, y: geometry.size.height * 0.15),
                            CGPoint(x: geometry.size.width * 0.2, y: geometry.size.height * 0.85),
                            CGPoint(x: geometry.size.width * 0.8, y: geometry.size.height * 0.8),
                            CGPoint(x: geometry.size.width * 0.15, y: geometry.size.height * 0.5),
                            CGPoint(x: geometry.size.width * 0.85, y: geometry.size.height * 0.6),
                            CGPoint(x: geometry.size.width * 0.3, y: geometry.size.height * 0.3),
                            CGPoint(x: geometry.size.width * 0.7, y: geometry.size.height * 0.7)
                        ]
                        
                        let sizes: [CGFloat] = [60, 70, 50, 65, 55, 45, 50, 60]
                        let opacities: [Double] = [0.1, 0.08, 0.12, 0.06, 0.1, 0.07, 0.09, 0.11]
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.white.opacity(opacities[i]))
                                .frame(width: sizes[i], height: sizes[i])
                            
                            Text("\(i + 1)")
                                .font(.system(size: sizes[i] * 0.4, weight: .bold))
                                .foregroundColor(.white.opacity(opacities[i] * 2))
                        }
                        .position(positions[i])
                        .rotationEffect(.degrees(isAnimating ? Double(i * 8) : 0))
                        .animation(
                            Animation.easeInOut(duration: Double(i) + 4)
                                .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                    }
                }
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 结果标题区域
                        resultHeaderView
                        
                        // 表现等级与评价
                        performanceView
                        
                        // 历史记录和统计图表
                        statsView
                        
                        // 操作按钮
                        actionButtonsView
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 20)
                }
            }
            .onAppear {
                isAnimating = true
            }
            .sheet(isPresented: $showingShareSheet, onDismiss: {}) {
                if let image = screenshot {
                    ShareSheet(items: [image])
                }
            }
        }
    }
    
    // 结果标题视图
    private var resultHeaderView: some View {
        VStack(spacing: 10) {
            Text(LocalizedStringKey.results.localized)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 2)
            
            HStack(spacing: 15) {
                Image(systemName: "stopwatch.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.yellow)
                    .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
                
                Text(String(format: "%.2f s", completionTime))
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 2)
                    .scaleEffect(isAnimating ? 1.05 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 25)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.15))
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
            
            Text("\(tableSize)x\(tableSize) \(LocalizedStringKey.table.localized)")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white.opacity(0.9))
                .padding(.top, 5)
        }
        .padding(.bottom, 10)
    }
    
    // 表现评价视图
    private var performanceView: some View {
        VStack(spacing: 15) {
            Text(performanceLevel)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white.opacity(0.15))
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                )
                .padding(.horizontal)
            
            Text(performanceDescription)
                .font(.system(size: 17))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 3)
        )
    }
    
    // 统计视图
    private var statsView: some View {
        VStack(spacing: 15) {
            Text(LocalizedStringKey.history.localized)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 10)
            
            if let historicalData = getHistoricalData() {
                if historicalData.isEmpty {
                    Text(LocalizedStringKey.noData.localized)
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(20)
                } else {
                    chartView(data: historicalData)
                        .frame(height: 220)
                        .padding(.vertical, 10)
                }
            } else {
                Text(LocalizedStringKey.noData.localized)
                    .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(20)
            }
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 15)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 3)
        )
    }
    
    // 图表视图
    private func chartView(data: [GameResultData]) -> some View {
        VStack {
            Chart {
                ForEach(data.suffix(10)) { item in
                    LineMark(
                        x: .value("尝试", item.attempt),
                        y: .value("用时", item.score)
                    )
                    .foregroundStyle(Color.white.opacity(0.9))
                    .lineStyle(StrokeStyle(lineWidth: 2.5))
                    
                    PointMark(
                        x: .value("尝试", item.attempt),
                        y: .value("用时", item.score)
                    )
                    .foregroundStyle(Color.yellow)
                    .symbolSize(30)
                }
            }
            .chartYScale(domain: {
                if let maxScore = data.map({ $0.score }).max() {
                    return [0, maxScore * 1.2]
                }
                return [0, 100]
            }())
            .chartXAxis {
                AxisMarks(position: .bottom) { _ in
                    AxisValueLabel()
                        .foregroundStyle(Color.white)
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                        .foregroundStyle(Color.white)
                }
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white.opacity(0.1))
            )
        }
    }
    
    // 操作按钮视图
    private var actionButtonsView: some View {
        HStack(spacing: 20) {
            Button(action: {
                onRestart(tableSize)
            }) {
                HStack {
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                        .font(.system(size: 20))
                    Text(LocalizedStringKey.tryAgain.localized)
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(Color(red: 0.2, green: 0.7, blue: 0.6))
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 2)
            }
            
            Button(action: {
                onDismiss()
            }) {
                HStack {
                    Image(systemName: "house.fill")
                        .font(.system(size: 20))
                    Text(LocalizedStringKey.home.localized)
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(Color(red: 0.2, green: 0.7, blue: 0.6))
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 2)
            }
        }
        .padding(.top, 15)
    }
    
    // 获取相同表格大小的历史数据
    private func getHistoricalData() -> [GameResultData]? {
        // 获取舒尔特表格的历史数据，进行筛选并处理
        let historyData = gameDataManager.gameResults.filter { $0.gameType == GameType.schulteTable.rawValue }
        let filteredData = historyData.filter { $0.extraData == "\(tableSize)x\(tableSize)" }
        
        if filteredData.isEmpty {
            return []
        }
        
        return filteredData.enumerated().map { index, result in
            GameResultData(attempt: index + 1, score: result.score)
        }
    }
    
    // 表现等级评估
    private var performanceLevel: String {
        let threshold = getThreshold()
        
        if completionTime < threshold.excellent {
            return LocalizedStringKey.excellent.localized
        } else if completionTime < threshold.good {
            return LocalizedStringKey.good.localized
        } else if completionTime < threshold.average {
            return LocalizedStringKey.average.localized
        } else {
            return LocalizedStringKey.needsPractice.localized
        }
    }
    
    // 表现描述
    private var performanceDescription: String {
        let threshold = getThreshold()
        
        if completionTime < threshold.excellent {
            return LocalizedStringKey.excellentPerception.localized
        } else if completionTime < threshold.good {
            return LocalizedStringKey.goodPerception.localized
        } else if completionTime < threshold.average {
            return LocalizedStringKey.averagePerception.localized
        } else {
            return LocalizedStringKey.practicePerception.localized
        }
    }
    
    // 获取对应表格大小的阈值
    private func getThreshold() -> (excellent: Double, good: Double, average: Double) {
        // 根据表格大小提供不同的阈值标准
        switch tableSize {
        case 3:
            return (excellent: 5.0, good: 8.0, average: 12.0)
        case 4:
            return (excellent: 12.0, good: 18.0, average: 25.0)
        case 5:
            return (excellent: 22.0, good: 30.0, average: 40.0)
        case 6:
            return (excellent: 35.0, good: 45.0, average: 60.0)
        default:
            // 默认阈值
            return (excellent: 30.0, good: 45.0, average: 60.0)
        }
    }
}

// 用于图表的数据结构
struct GameResultData: Identifiable {
    let id = UUID()
    let attempt: Int
    let score: Double
}

// 用于分享的UIActivityViewController
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    SchulteTableResultView(
        completionTime: 35.5,
        tableSize: 5,
        onDismiss: {},
        onRestart: { _ in }
    )
    .environmentObject(GameDataManager())
} 