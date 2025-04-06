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
            return "Excellent! You're in the top 10% of people."
        case 200..<250:
            return "Great! You're in the top 30% of people."
        case 250..<300:
            return "Good. You're around average."
        case 300..<350:
            return "You're in the lower 40% of people."
        default:
            return "You're in the lower 30% of people."
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with main result
                    VStack(spacing: 8) {
                        Text("Your Average Reaction Time")
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
                        Text("Statistics")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        HStack {
                            statCard(title: "Best Time", value: String(format: "%.0f ms", bestTime))
                            statCard(title: "Attempts", value: "\(reactionTimes.count)")
                        }
                        
                        // Chart of reaction times
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your Attempts")
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
                                    Text("Average")
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
                        Text("What Does This Mean?")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Reaction time is how quickly you respond to a stimulus. The average adult has a visual reaction time of 250 milliseconds.")
                            .font(.body)
                        
                        Text("Factors that can affect your reaction time include age, fatigue, caffeine intake, and practice. Professional athletes often have reaction times below 200ms.")
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
                            Text("Back to Menu")
                                .font(.headline)
                                .foregroundColor(.blue)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(12)
                        }
                        
                        Button(action: {
                            // Dismiss this view and start a new game
                            onDismiss()
                            // The navigation back to the intro view is handled by the onDismiss closure
                        }) {
                            Text("Play Again")
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
            .navigationBarTitle("Results", displayMode: .inline)
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
        onDismiss: {}
    )
    .environmentObject(GameDataManager())
}
