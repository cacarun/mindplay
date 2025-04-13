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
    
    // 基于图片的分布数据模型
    private struct DistributionData: Identifiable {
        let id = UUID()
        let level: String
        let percentage: Double
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
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with main result
                    VStack(spacing: 8) {
                        Text(LocalizedStringKey.levelReached.localized)
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("\(level)")
                            .font(.system(size: 64, weight: .bold))
                            .foregroundColor(.blue)
                        
                        Text(percentileText)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
                    // Statistics
                    VStack(alignment: .leading, spacing: 16) {
                        Text(LocalizedStringKey.statistics.localized)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        // Chart of distribution
                        VStack(alignment: .leading, spacing: 8) {
                            Text(LocalizedStringKey.distribution.localized)
                                .font(.headline)
                            
                            Chart {
                                ForEach(distributionData) { item in
                                    LineMark(
                                        x: .value("Level", item.level),
                                        y: .value("Percentage", item.percentage)
                                    )
                                    .foregroundStyle(Color.blue.gradient)
                                    .interpolationMethod(.catmullRom)
                                    
                                    AreaMark(
                                        x: .value("Level", item.level),
                                        y: .value("Percentage", item.percentage)
                                    )
                                    .foregroundStyle(Color.blue.opacity(0.1).gradient)
                                    .interpolationMethod(.catmullRom)
                                    
                                    if item.level == String(level) {
                                        PointMark(
                                            x: .value("Level", item.level),
                                            y: .value("Percentage", item.percentage)
                                        )
                                        .foregroundStyle(Color.blue)
                                        .symbolSize(100)
                                    }
                                }
                            }
                            .frame(height: 250)
                            .chartYAxis {
                                AxisMarks(position: .leading, values: .automatic(desiredCount: 5)) { value in
                                    if let percentage = value.as(Double.self) {
                                        AxisValueLabel("\(Int(percentage))")
                                    }
                                    AxisGridLine()
                                }
                            }
                            .chartXAxis {
                                AxisMarks(values: .stride(by: 4)) { value in
                                    if let level = value.as(String.self) {
                                        AxisValueLabel(level)
                                    }
                                    AxisGridLine()
                                }
                            }
                            
                            // 标记用户所在区间
                            HStack {
                                Spacer()
                                Text(LocalizedStringKey.yourResult.localized + ": " + getUserCategory(level: level))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 5)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
                    // Interpretation
                    VStack(alignment: .leading, spacing: 12) {
                        Text(LocalizedStringKey.whatThisMeans.localized)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(performanceDescription)
                            .font(.body)
                        
                        Text("Visual memory is our ability to recall what we have seen. It plays a key role in everyday tasks, from remembering where we put our keys to navigating familiar routes.")
                            .font(.body)
                            .padding(.top, 4)
                        
                        Text("Spatial memory is closely tied to our hippocampus, and regular practice can help maintain and improve this cognitive ability.")
                            .font(.body)
                            .padding(.top, 4)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
                    // Action buttons
                    HStack(spacing: 16) {
                        Button(action: {
                            onDismiss()
                        }) {
                            Text(LocalizedStringKey.backToMenu.localized)
                                .font(.headline)
                                .foregroundColor(.blue)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(12)
                        }
                        
                        Button(action: {
                            dismiss()
                            onRestart(level)
                        }) {
                            Text(LocalizedStringKey.playAgain.localized)
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationBarTitle(LocalizedStringKey.results.localized, displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                onDismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
            })
        }
    }
    
    // 获取用户所在分布区间
    private func getUserCategory(level: Int) -> String {
        if level <= 5 {
            return "Below Average"
        } else if level <= 8 {
            return "Average"
        } else if level <= 12 {
            return "Good"
        } else {
            return "Excellent"
        }
    }
}

#Preview {
    VisualMemoryResultView(
        level: 8,
        onDismiss: {},
        onRestart: { _ in }
    )
} 