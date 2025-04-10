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
            return "Your number memory is excellent, significantly above average."
        } else if digitsRemembered >= 9 {
            return "Your number memory is good, better than most people."
        } else if digitsRemembered >= 7 {
            return "Your number memory is average, on par with most people."
        } else {
            return "Your number memory is below average, but can be improved with practice."
        }
    }
    
    // 模拟分布数据
    private let distributionData = [
        (digits: "1-4", percentage: 5),
        (digits: "5-6", percentage: 20),
        (digits: "7-8", percentage: 35),
        (digits: "9-11", percentage: 30),
        (digits: "12+", percentage: 10)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with main result
                    VStack(spacing: 8) {
                        Text(LocalizedStringKey.digitsRemembered.localized)
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("\(digitsRemembered)")
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
                        
                        HStack {
                            statCard(title: LocalizedStringKey.digitsRemembered.localized, value: "\(digitsRemembered)")
                            statCard(title: LocalizedStringKey.levelReached.localized, value: "\(level)")
                        }
                        
                        // Chart of distribution
                        VStack(alignment: .leading, spacing: 8) {
                            Text(LocalizedStringKey.distribution.localized)
                                .font(.headline)
                            
                            Chart(distributionData, id: \.digits) { item in
                                BarMark(
                                    x: .value("Digits", item.digits),
                                    y: .value("Percentage", item.percentage)
                                )
                                .foregroundStyle(Color.blue.gradient)
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
                            let userCategory = getUserCategory(digits: digitsRemembered)
                            Text("Your result: \(userCategory)")
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
                        
                        Text(LocalizedStringKey.numberExplanation.localized)
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
                            onRestart()
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
    
    private func statCard(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    NumberMemoryResultView(
        level: 8,
        digitsRemembered: 11,
        onDismiss: {},
        onRestart: {}
    )
    .environmentObject(GameDataManager())
} 