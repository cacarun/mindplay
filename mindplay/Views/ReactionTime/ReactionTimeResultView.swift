//
//  ReactionTimeResultView.swift
//  mindplay
//
//  Created for MindPlay app.
//

import SwiftUI
import Charts

struct ReactionTimeResultView: View {
    @EnvironmentObject var gameDataManager: GameDataManager
    let reactionTimes: [Double]
    let onDismiss: () -> Void
    let totalRounds: Int
    
    let onRestart: (Int) -> Void
    
    @State private var startNewGame = false
    
    init(reactionTimes: [Double], totalRounds: Int = 3, onDismiss: @escaping () -> Void, onRestart: @escaping (Int) -> Void) {
        self.reactionTimes = reactionTimes
        self.totalRounds = totalRounds
        self.onDismiss = onDismiss
        self.onRestart = onRestart
    }
    
    private var averageTime: Double {
        reactionTimes.reduce(0, +) / Double(reactionTimes.count)
    }
    
    private var bestTime: Double {
        reactionTimes.min() ?? 0
    }
    
    private var percentileText: String {
        let avg = averageTime
        switch avg {
        case ..<200:
            return LocalizedStringKey.percentileExcellent.localized
        case 200..<250:
            return LocalizedStringKey.percentileGood.localized
        case 250..<300:
            return LocalizedStringKey.percentileAverage.localized
        case 300..<350:
            return LocalizedStringKey.percentileBelowAverage.localized
        default:
            return LocalizedStringKey.percentileBelowAverage.localized
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with main result
                    VStack(spacing: 8) {
                        Text(LocalizedStringKey.yourAverageReactionTime.localized)
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(String(format: "%.0f ms", averageTime))
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
                            statCard(title: LocalizedStringKey.bestTime.localized, value: String(format: "%.0f ms", bestTime))
                            statCard(title: LocalizedStringKey.attempts.localized, value: "\(reactionTimes.count)")
                        }
                        
                        // Chart of reaction times
                        VStack(alignment: .leading, spacing: 8) {
                            Text(LocalizedStringKey.yourAttempts.localized)
                                .font(.headline)
                            
                            Chart {
                                ForEach(Array(reactionTimes.enumerated()), id: \.offset) { index, time in
                                    BarMark(
                                        x: .value("Attempt", "\(index + 1)"),
                                        y: .value("Time (ms)", time)
                                    )
                                    .foregroundStyle(Color.blue.gradient)
                                }
                                
                                RuleMark(
                                    y: .value("Average", averageTime)
                                )
                                .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                                .foregroundStyle(.red)
                                .annotation(position: .top, alignment: .trailing) {
                                    Text(LocalizedStringKey.average.localized)
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                            .frame(height: 200)
                            .chartYScale(domain: 0...(reactionTimes.max() ?? 500) * 1.2)
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
                        
                        Text(LocalizedStringKey.resultExplanation.localized)
                            .font(.body)
                        
                        Text(LocalizedStringKey.resultFactors.localized)
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
                            onRestart(totalRounds)
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
    ReactionTimeResultView(
        reactionTimes: [234, 256, 198, 287, 212],
        totalRounds: 5,
        onDismiss: {},
        onRestart: { _ in }
    )
    .environmentObject(GameDataManager())
}
