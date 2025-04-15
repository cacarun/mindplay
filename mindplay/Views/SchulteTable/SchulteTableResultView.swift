//
//  SchulteTableResultView.swift
//  mindplay
//
//  Created for MindPlay app.
//

import SwiftUI
import Charts

struct SchulteTableResultView: View {
    @EnvironmentObject var gameDataManager: GameDataManager
    @Environment(\.dismiss) private var dismiss
    
    let completionTime: TimeInterval
    let tableSize: Int
    let onDismiss: () -> Void
    let onRestart: (Int) -> Void
    
    // 性能评级文本
    private var percentileText: String {
        if tableSize == 3 {
            if completionTime < 10 {
                return LocalizedStringKey.elitePerformance.localized
            } else if completionTime < 15 {
                return LocalizedStringKey.advancedLevel.localized
            } else if completionTime < 25 {
                return LocalizedStringKey.averageProficiency.localized
            } else {
                return LocalizedStringKey.beginnerLevel.localized
            }
        } else if tableSize == 4 {
            if completionTime < 15 {
                return LocalizedStringKey.elitePerformance.localized
            } else if completionTime < 25 {
                return LocalizedStringKey.advancedLevel.localized
            } else if completionTime < 40 {
                return LocalizedStringKey.averageProficiency.localized
            } else {
                return LocalizedStringKey.beginnerLevel.localized
            }
        } else { // 5x5
            if completionTime < 25 {
                return LocalizedStringKey.elitePerformance.localized
            } else if completionTime < 40 {
                return LocalizedStringKey.advancedLevel.localized
            } else if completionTime < 60 {
                return LocalizedStringKey.averageProficiency.localized
            } else {
                return LocalizedStringKey.beginnerLevel.localized
            }
        }
    }
    
    // 性能说明
    private var performanceDescription: String {
        if tableSize == 3 {
            if completionTime < 10 {
                return LocalizedStringKey.excellentSchultePerformance.localized
            } else if completionTime < 15 {
                return LocalizedStringKey.goodSchultePerformance.localized
            } else if completionTime < 25 {
                return LocalizedStringKey.averageSchultePerformance.localized
            } else {
                return LocalizedStringKey.belowAverageSchultePerformance.localized
            }
        } else if tableSize == 4 {
            if completionTime < 15 {
                return LocalizedStringKey.excellentSchultePerformance.localized
            } else if completionTime < 25 {
                return LocalizedStringKey.goodSchultePerformance.localized
            } else if completionTime < 40 {
                return LocalizedStringKey.averageSchultePerformance.localized
            } else {
                return LocalizedStringKey.belowAverageSchultePerformance.localized
            }
        } else { // 5x5
            if completionTime < 25 {
                return LocalizedStringKey.excellentSchultePerformance.localized
            } else if completionTime < 40 {
                return LocalizedStringKey.goodSchultePerformance.localized
            } else if completionTime < 60 {
                return LocalizedStringKey.averageSchultePerformance.localized
            } else {
                return LocalizedStringKey.belowAverageSchultePerformance.localized
            }
        }
    }
    
    // 基于表现的颜色
    private var performanceColor: Color {
        if tableSize == 3 {
            if completionTime < 10 {
                return .green
            } else if completionTime < 15 {
                return .blue
            } else if completionTime < 25 {
                return .orange
            } else {
                return .red.opacity(0.8)
            }
        } else if tableSize == 4 {
            if completionTime < 15 {
                return .green
            } else if completionTime < 25 {
                return .blue
            } else if completionTime < 40 {
                return .orange
            } else {
                return .red.opacity(0.8)
            }
        } else { // 5x5
            if completionTime < 25 {
                return .green
            } else if completionTime < 40 {
                return .blue
            } else if completionTime < 60 {
                return .orange
            } else {
                return .red.opacity(0.8)
            }
        }
    }
    
    // 获取玩家的历史记录
    private var historyResults: [GameResult] {
        return gameDataManager.gameResults.filter { 
            $0.gameType == GameType.schulteTable.rawValue &&
            $0.extraData == "\(tableSize)x\(tableSize)"
        }.sorted(by: { $0.date > $1.date })
    }
    
    // 计算平均时间
    private var averageTime: Double {
        let filteredResults = historyResults
        if filteredResults.isEmpty {
            return completionTime
        }
        
        let sum = filteredResults.reduce(0) { $0 + $1.score }
        return sum / Double(filteredResults.count)
    }
    
    // 计算最快时间
    private var bestTime: Double {
        let filteredResults = historyResults
        return filteredResults.map { $0.score }.min() ?? completionTime
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with main result
                    VStack(spacing: 8) {
                        Text(LocalizedStringKey.yourTime.localized)
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(String(format: "%.1f s", completionTime))
                            .font(.system(size: 64, weight: .bold))
                            .foregroundColor(performanceColor)
                        
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
                        
                        HStack(spacing: 16) {
                            // 表格大小
                            statCard(title: LocalizedStringKey.tableSize.localized, value: "\(tableSize)×\(tableSize)")
                            
                            // 平均时间
                            statCard(title: LocalizedStringKey.averageTime.localized, value: String(format: "%.1f s", averageTime))
                            
                            // 最快时间
                            statCard(title: LocalizedStringKey.fastestTime.localized, value: String(format: "%.1f s", bestTime))
                        }
                        
                        // 如果有历史成绩就显示图表
                        if historyResults.count > 1 {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(LocalizedStringKey.yourResult.localized)
                                    .font(.headline)
                                
                                Chart {
                                    ForEach(Array(historyResults.prefix(10).reversed().enumerated()), id: \.element.id) { index, result in
                                        BarMark(
                                            x: .value("Attempt", "\(index + 1)"),
                                            y: .value("Time", result.score)
                                        )
                                        .foregroundStyle(performanceColor.gradient)
                                    }
                                    
                                    RuleMark(y: .value("Current", completionTime))
                                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                                        .foregroundStyle(.primary)
                                        .annotation(position: .automatic) {
                                            Text(LocalizedStringKey.yourTime.localized)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                }
                                .frame(height: 250)
                                .chartYAxis {
                                    AxisMarks(position: .leading)
                                }
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                        }
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
                        
                        Text(LocalizedStringKey.schulteTestDescription.localized)
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
                            onRestart(tableSize)
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
    
    private func statCard(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    SchulteTableResultView(
        completionTime: 22.5,
        tableSize: 5,
        onDismiss: {},
        onRestart: { _ in }
    )
    .environmentObject(GameDataManager())
} 