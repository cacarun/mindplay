//
//  VerbalMemoryResultView.swift
//  mindplay
//
//  Created for MindPlay app.
//

import SwiftUI
import Charts

struct VerbalMemoryResultView: View {
    @EnvironmentObject var gameDataManager: GameDataManager
    @Environment(\.dismiss) private var dismiss
    
    let score: Int
    let onDismiss: () -> Void
    let onRestart: () -> Void
    
    // 性能评级文本
    private var percentileText: String {
        if score > 100 {
            return LocalizedStringKey.percentileExcellent.localized
        } else if score >= 70 {
            return LocalizedStringKey.percentileGood.localized
        } else if score >= 40 {
            return LocalizedStringKey.percentileAverage.localized
        } else {
            return LocalizedStringKey.percentileBelowAverage.localized
        }
    }
    
    // 性能说明
    private var performanceDescription: String {
        if score > 100 {
            return LocalizedStringKey.excellentVerbalMemory.localized
        } else if score >= 70 {
            return LocalizedStringKey.goodVerbalMemory.localized
        } else if score >= 40 {
            return LocalizedStringKey.averageVerbalMemory.localized
        } else {
            return LocalizedStringKey.belowAverageVerbalMemory.localized
        }
    }
    
    // 模拟分布数据
    private let distributionData = [
        (words: "1-20", percentage: 5),
        (words: "21-40", percentage: 15),
        (words: "41-70", percentage: 35),
        (words: "71-100", percentage: 30),
        (words: "101+", percentage: 15)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with main result
                    VStack(spacing: 8) {
                        Text(LocalizedStringKey.wordsRemembered.localized)
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("\(score)")
                            .font(.system(size: 64, weight: .bold))
                            .foregroundColor(.indigo)
                        
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
                            
                            Chart(distributionData, id: \.words) { item in
                                BarMark(
                                    x: .value("Words", item.words),
                                    y: .value("Percentage", item.percentage)
                                )
                                .foregroundStyle(Color.indigo.gradient)
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
                            let userCategory = getUserCategory(score: score)
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
                        
                        Text(LocalizedStringKey.wordExplanation.localized)
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
                                .foregroundColor(.indigo)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.indigo.opacity(0.1))
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
                                .background(Color.indigo)
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
    private func getUserCategory(score: Int) -> String {
        if score <= 20 {
            return "1-20"
        } else if score <= 40 {
            return "21-40"
        } else if score <= 70 {
            return "41-70"
        } else if score <= 100 {
            return "71-100"
        } else {
            return "101+"
        }
    }
}

#Preview {
    VerbalMemoryResultView(
        score: 85,
        onDismiss: {},
        onRestart: {}
    )
    .environmentObject(GameDataManager())
} 