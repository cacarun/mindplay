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
    
    let totalTimeElapsed: TimeInterval
    let hitTimes: [TimeInterval]
    
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
    
    // 性能评级
    private var performanceRating: String {
        if averageTimePerTarget < 600 {
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
        if averageTimePerTarget < 600 {
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
        ScrollView {
            VStack(spacing: 25) {
                // 标题和主要成绩
                VStack(spacing: 8) {
                    Text(LocalizedStringKey.results.localized)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(String(format: "%.1f ms", averageTimePerTarget))
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.blue)
                    
                    Text(LocalizedStringKey.avgTimePerTarget.localized)
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    // 评级
                    Text(performanceRating)
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 5)
                }
                .padding(.top, 10)
                
                // 统计数据卡片
                VStack(spacing: 15) {
                    Text(LocalizedStringKey.statistics.localized)
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // 两列统计
                    HStack(alignment: .top, spacing: 20) {
                        // 左列
                        VStack(alignment: .leading, spacing: 10) {
                            StatisticRow(
                                title: LocalizedStringKey.totalTime.localized,
                                value: String(format: "%.1f s", totalTimeElapsed)
                            )
                            
                            if let fastest = clickIntervals.min() {
                                StatisticRow(
                                    title: LocalizedStringKey.fastestClick.localized,
                                    value: String(format: "%.1f ms", fastest)
                                )
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // 右列
                        VStack(alignment: .leading, spacing: 10) {
                            StatisticRow(
                                title: LocalizedStringKey.totalTargets.localized,
                                value: "\(hitTimes.count)"
                            )
                            
                            if let slowest = clickIntervals.max() {
                                StatisticRow(
                                    title: LocalizedStringKey.slowestClick.localized,
                                    value: String(format: "%.1f ms", slowest)
                                )
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                
                // 图表
                VStack(alignment: .leading, spacing: 15) {
                    Text(LocalizedStringKey.distribution.localized)
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if !clickIntervals.isEmpty {
                        Chart(prepareHistogramData()) { bin in
                            BarMark(
                                x: .value("Time (ms)", "\(bin.startValue)-\(bin.endValue)"),
                                y: .value("Count", bin.count)
                            )
                            .foregroundStyle(Color.blue.gradient)
                        }
                        .frame(height: 200)
                        .chartYAxis {
                            AxisMarks(position: .leading)
                        }
                        .chartXAxis {
                            AxisMarks { value in
                                if let label = value.as(String.self), 
                                   ["0-200", "600-800", "1200-1400", "1800-2000"].contains(label) {
                                    AxisValueLabel(label)
                                }
                            }
                        }
                    } else {
                        Text("没有足够的数据显示图表")
                            .foregroundColor(.secondary)
                            .frame(height: 200, alignment: .center)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                
                // 解释
                VStack(alignment: .leading, spacing: 15) {
                    Text(LocalizedStringKey.whatThisMeans.localized)
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(performanceDescription)
                        .foregroundColor(.secondary)
                    
                    Divider()
                        .padding(.vertical, 5)
                    
                    Text(LocalizedStringKey.aimExplanation1.localized)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 5)
                    
                    Text(LocalizedStringKey.aimExplanation2.localized)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                
                // 按钮
                HStack(spacing: 20) {
                    // 返回主菜单
                    Button {
                        // 回到主菜单
                        dismiss()
                    } label: {
                        Text(LocalizedStringKey.backToMenu.localized)
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.primary)
                            .cornerRadius(10)
                    }
                    
                    // 再玩一次
                    NavigationLink {
                        AimTrainerGameView()
                    } label: {
                        Text(LocalizedStringKey.playAgain.localized)
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 30)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}

// 统计行视图
struct StatisticRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
        }
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
            totalTimeElapsed: 25.7,
            hitTimes: [1.0, 1.85, 2.6, 3.5, 4.3, 5.1, 5.8, 6.7, 7.5, 8.3]
        )
        .environmentObject(GameDataManager())
    }
} 