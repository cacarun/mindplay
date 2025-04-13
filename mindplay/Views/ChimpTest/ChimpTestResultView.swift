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
    
    // 模拟分布数据 - 基于图片中的分布曲线
    private let distributionData = [
        (level: "4", percentage: 5),
        (level: "5", percentage: 10),
        (level: "6", percentage: 15),
        (level: "7", percentage: 20),
        (level: "8", percentage: 25),
        (level: "9", percentage: 35),
        (level: "10", percentage: 25),
        (level: "11", percentage: 20),
        (level: "12", percentage: 15),
        (level: "13", percentage: 10),
        (level: "14+", percentage: 5)
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
                        
                        Text("\(maxLevel)")
                            .font(.system(size: 64, weight: .bold))
                            .foregroundColor(.purple)
                        
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
                            
                            Chart(distributionData, id: \.level) { item in
                                BarMark(
                                    x: .value("Level", item.level),
                                    y: .value("Percentage", item.percentage)
                                )
                                .foregroundStyle(Color.purple.gradient)
                                .cornerRadius(4)
                            }
                            .frame(height: 200)
                            .chartYAxis {
                                AxisMarks(position: .leading, values: .automatic(desiredCount: 5)) { value in
                                    if let percentage = value.as(Int.self) {
                                        AxisValueLabel("\(percentage)%")
                                    }
                                    AxisGridLine()
                                }
                            }
                            
                            // 标记用户所在区间
                            let userCategory = getUserCategory(level: maxLevel)
                            Text(LocalizedStringKey.yourResult.localized + ": " + userCategory)
                                .font(.caption)
                                .foregroundColor(.secondary)
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
                        
                        Text(LocalizedStringKey.chimpOutperformHumans.localized)
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
                                .foregroundColor(.purple)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.purple.opacity(0.1))
                                .cornerRadius(12)
                        }
                        
                        Button(action: {
                            dismiss()
                            onRestart()
                        }) {
                            Text(LocalizedStringKey.playAgain.localized)
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.purple)
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