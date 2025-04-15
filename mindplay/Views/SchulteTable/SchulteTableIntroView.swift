//
//  SchulteTableIntroView.swift
//  mindplay
//
//  Created for MindPlay app.
//

import SwiftUI

struct SchulteTableIntroView: View {
    @EnvironmentObject var gameDataManager: GameDataManager
    @State private var isShowingGame = false
    @State private var tableSize = 5 // 默认表格大小为5x5
    
    // 可选的表格大小范围
    private let tableSizeOptions = [3, 4, 5]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(LocalizedStringKey.schulteTableTest.localized)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(LocalizedStringKey.enhanceAttention.localized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 8)
                
                // 自定义表格大小
                VStack(alignment: .leading, spacing: 12) {
                    Text(LocalizedStringKey.tableSize.localized)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 10) {
                        ForEach(tableSizeOptions, id: \.self) { size in
                            Button(action: {
                                tableSize = size
                            }) {
                                Text("\(size)×\(size)")
                                    .font(.headline)
                                    .frame(minWidth: 44, minHeight: 44)
                                    .background(tableSize == size ? Color.blue : Color.gray.opacity(0.2))
                                    .foregroundColor(tableSize == size ? .white : .primary)
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
                    VStack(alignment: .leading, spacing: 4) {
                        Text(LocalizedStringKey.bestScore.localized)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if let bestScore = gameDataManager.getBestScore(for: .schulteTable, with: "\(tableSize)x\(tableSize)") {
                            Text(String(format: "%.1f s", bestScore))
                                .font(.headline)
                                .foregroundColor(.blue)
                        } else {
                            Text("-")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
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
                    
                    instructionItem(number: "1", text: String.localizedStringWithFormat(LocalizedStringKey.findNumbers.localized as String, "1", String(tableSize * tableSize)))
                    instructionItem(number: "2", text: LocalizedStringKey.usePeripheralVision.localized)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // 速度标准
                VStack(alignment: .leading, spacing: 12) {
                    Text(LocalizedStringKey.aboutSchulteTest.localized)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(LocalizedStringKey.schulteTestDescription.localized)
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        // 通用标准（偏向儿童）
                        Text("评估标准")
                            .font(.headline)
                            .padding(.top, 8)
                        
                        // 根据表格大小调整标准
                        if tableSize == 3 {
                            scoreRangeRow(level: LocalizedStringKey.elitePerformance.localized, value: "< 10 s")
                            scoreRangeRow(level: LocalizedStringKey.advancedLevel.localized, value: "10-15 s")
                            scoreRangeRow(level: LocalizedStringKey.averageProficiency.localized, value: "15-25 s")
                            scoreRangeRow(level: LocalizedStringKey.beginnerLevel.localized, value: "> 25 s")
                        } else if tableSize == 4 {
                            scoreRangeRow(level: LocalizedStringKey.elitePerformance.localized, value: "< 15 s")
                            scoreRangeRow(level: LocalizedStringKey.advancedLevel.localized, value: "15-25 s")
                            scoreRangeRow(level: LocalizedStringKey.averageProficiency.localized, value: "25-40 s")
                            scoreRangeRow(level: LocalizedStringKey.beginnerLevel.localized, value: "> 40 s")
                        } else { // 5x5
                            scoreRangeRow(level: LocalizedStringKey.elitePerformance.localized, value: "< 25 s")
                            scoreRangeRow(level: LocalizedStringKey.advancedLevel.localized, value: "25-40 s")
                            scoreRangeRow(level: LocalizedStringKey.averageProficiency.localized, value: "40-60 s")
                            scoreRangeRow(level: LocalizedStringKey.beginnerLevel.localized, value: "> 60 s")
                        }
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
            SchulteTableGameView(tableSize: tableSize)
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
    
    private func scoreRangeRow(level: String, value: String) -> some View {
        HStack {
            Text(level)
                .font(.subheadline)
                .frame(width: 150, alignment: .leading)
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .leading)
            
            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        SchulteTableIntroView()
            .environmentObject(GameDataManager())
    }
} 