//
//  ReactionTimeIntroView.swift
//  mindplay
//
//  Created for MindPlay app.
//

import SwiftUI

struct ReactionTimeIntroView: View {
    @EnvironmentObject var gameDataManager: GameDataManager
    @State private var isShowingGame = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Reaction Time Test")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Test your visual reaction speed")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 8)
                
                // Best score
                if let bestScore = gameDataManager.getBestScore(for: .reactionTime) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Your Best")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text(String(format: "%.0f ms", bestScore))
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.blue)
                        }
                        
                        Spacer()
                        
                        // Add percentile comparison here when implemented
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
                
                // Game instructions
                VStack(alignment: .leading, spacing: 16) {
                    Text("How to Play")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    instructionItem(number: "1", text: "Wait for the screen to turn green")
                    instructionItem(number: "2", text: "Tap the screen as quickly as you can when it changes")
                    instructionItem(number: "3", text: "Your reaction time will be measured in milliseconds")
                    instructionItem(number: "4", text: "Complete 5 rounds for an average score")
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // About section
                VStack(alignment: .leading, spacing: 12) {
                    Text("About the Test")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("This test measures your visual reaction time - how quickly you respond to a visual stimulus. The average reaction time is around 250 milliseconds, but can vary based on many factors including age, fatigue, and practice.")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        scoreRangeRow(range: "< 200 ms", description: "Excellent")
                        scoreRangeRow(range: "200-250 ms", description: "Good")
                        scoreRangeRow(range: "250-300 ms", description: "Average")
                        scoreRangeRow(range: "> 300 ms", description: "Below Average")
                    }
                    .padding(.top, 8)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Start button
                Button(action: {
                    isShowingGame = true
                }) {
                    Text("Start Test")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.top, 16)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarTitle("", displayMode: .inline)
        .fullScreenCover(isPresented: $isShowingGame) {
            ReactionTimeGameView()
        }
    }
    
    private func instructionItem(number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Text(number)
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(Color.blue)
                .clipShape(Circle())
            
            Text(text)
                .font(.body)
            
            Spacer()
        }
    }
    
    private func scoreRangeRow(range: String, description: String) -> some View {
        HStack {
            Text(range)
                .font(.subheadline)
                .frame(width: 100, alignment: .leading)
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        ReactionTimeIntroView()
            .environmentObject(GameDataManager())
    }
}
