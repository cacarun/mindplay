//
//  VisualMemoryIntroView.swift
//  mindplay
//
//  Created for MindPlay app.
//

import SwiftUI

struct VisualMemoryIntroView: View {
    @EnvironmentObject var gameDataManager: GameDataManager
    @State private var isShowingGame = false
    @State private var selectedGridSize = 3 // 默认网格大小为3x3
    
    // 可选的网格大小范围
    private let gridOptions = [3, 4, 5]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(LocalizedStringKey.visualMemoryTest.localized)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(LocalizedStringKey.memorizeSquares.localized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 8)
                
                // 自定义起始网格大小
                VStack(alignment: .leading, spacing: 12) {
                    Text(LocalizedStringKey.startingGridSize.localized)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 10) {
                        ForEach(gridOptions, id: \.self) { size in
                            Button(action: {
                                selectedGridSize = size
                            }) {
                                Text("\(size)×\(size)")
                                    .font(.headline)
                                    .frame(minWidth: 44, minHeight: 44)
                                    .background(selectedGridSize == size ? Color.blue : Color.gray.opacity(0.2))
                                    .foregroundColor(selectedGridSize == size ? .white : .primary)
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
                    if let bestScore = gameDataManager.getBestScore(for: .visualMemory) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(LocalizedStringKey.bestScore.localized)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text(String(format: LocalizedStringKey.level.localized + ": %d", Int(bestScore)))
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // 开始测试按钮
                    Button(action: {
                        isShowingGame = true
                    }) {
                        Text(LocalizedStringKey.startTest.localized)
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
                    Text(LocalizedStringKey.howToPlay.localized)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    instructionItem(number: "1", text: LocalizedStringKey.tilesFlashWhite.localized)
                    instructionItem(number: "2", text: LocalizedStringKey.memorizeAndPick.localized)
                    instructionItem(number: "3", text: LocalizedStringKey.levelProgressivelyHarder.localized)
                    instructionItem(number: "4", text: LocalizedStringKey.missThreeTilesLoseLife.localized)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // About section
                VStack(alignment: .leading, spacing: 12) {
                    Text(LocalizedStringKey.aboutTheTest.localized)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(LocalizedStringKey.visualMemoryExplanation1.localized)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 4)
                        
                    Text(LocalizedStringKey.visualMemoryExplanation2.localized)
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(LocalizedStringKey.performanceLevel.localized)
                            .font(.headline)
                            .padding(.top, 12)
                            .padding(.bottom, 4)
                            
                        scoreRangeRow(range: "> 12", description: LocalizedStringKey.excellent.localized)
                        scoreRangeRow(range: "9-12", description: LocalizedStringKey.good.localized)
                        scoreRangeRow(range: "6-8", description: LocalizedStringKey.average.localized)
                        scoreRangeRow(range: "< 6", description: LocalizedStringKey.belowAverage.localized)
                    }
                    .padding(.top, 8)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarTitle("", displayMode: .inline)
        .fullScreenCover(isPresented: $isShowingGame) {
            VisualMemoryGameView(gridSize: selectedGridSize)
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
        VisualMemoryIntroView()
            .environmentObject(GameDataManager())
    }
} 