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
    @State private var roundCount = 3 // 默认回合数为3次
    
    // 可选的回合次数范围
    private let roundOptions = [1, 3, 5, 10]
    
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
                
                // 自定义回合次数
                VStack(alignment: .leading, spacing: 12) {
                    Text("回合次数")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 10) {
                        ForEach(roundOptions, id: \.self) { count in
                            Button(action: {
                                roundCount = count
                            }) {
                                Text("\(count)")
                                    .font(.headline)
                                    .frame(minWidth: 44, minHeight: 44)
                                    .background(roundCount == count ? Color.blue : Color.gray.opacity(0.2))
                                    .foregroundColor(roundCount == count ? .white : .primary)
                                    .cornerRadius(8)
                            }
                        }
                        
                        Spacer()
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // 最佳成绩和开始按钮
                HStack(spacing: 15) {
                    // 最佳成绩
                    if let bestScore = gameDataManager.getBestScore(for: .reactionTime) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("最佳成绩")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text(String(format: "%.0f ms", bestScore))
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // 开始测试按钮
                    Button(action: {
                        isShowingGame = true
                    }) {
                        Text("开始测试")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(height: 44)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // 游戏说明
                VStack(alignment: .leading, spacing: 16) {
                    Text("How to Play")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    instructionItem(number: "1", text: "Wait for the screen to turn green")
                    instructionItem(number: "2", text: "Tap the screen as quickly as you can when it changes")
                    instructionItem(number: "3", text: "Your reaction time will be measured in milliseconds")
                    instructionItem(number: "4", text: "Complete \(roundCount) rounds for an average score")
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
                
                // 删除这里的开始按钮，因为我们已经移动到上面了
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarTitle("", displayMode: .inline)
        .fullScreenCover(isPresented: $isShowingGame) {
            ReactionTimeGameView(totalRounds: roundCount)
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
