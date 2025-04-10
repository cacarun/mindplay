//
//  NumberMemoryIntroView.swift
//  mindplay
//
//  Created for MindPlay app.
//

import SwiftUI

struct NumberMemoryIntroView: View {
    @EnvironmentObject var gameDataManager: GameDataManager
    @State private var isShowingGame = false
    @State private var startLength = 7 // 默认起始长度为7
    
    // 可选的起始数字长度
    private let lengthOptions = [5, 7, 9, 12]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(LocalizedStringKey.numberMemoryTest.localized)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(LocalizedStringKey.rememberLongestNumber.localized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 8)
                
                // 自定义起始长度
                VStack(alignment: .leading, spacing: 12) {
                    Text(LocalizedStringKey.numberLength.localized)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 10) {
                        ForEach(lengthOptions, id: \.self) { length in
                            Button(action: {
                                startLength = length
                            }) {
                                Text("\(length)")
                                    .font(.headline)
                                    .frame(minWidth: 44, minHeight: 44)
                                    .background(startLength == length ? Color.blue : Color.gray.opacity(0.2))
                                    .foregroundColor(startLength == length ? .white : .primary)
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
                    if let bestScore = gameDataManager.getBestScore(for: .numberMemory) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(LocalizedStringKey.bestScore.localized)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("\(Int(bestScore)) digits")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // 开始测试按钮
                    Button(action: {
                        isShowingGame = true
                    }) {
                        Text(LocalizedStringKey.startNumberTest.localized)
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
                    
                    instructionItem(number: "1", text: LocalizedStringKey.memorizeNumber.localized)
                    instructionItem(number: "2", text: LocalizedStringKey.enterNumber.localized)
                    instructionItem(number: "3", text: LocalizedStringKey.timeRemaining.localized(with: 5))
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // About section
                VStack(alignment: .leading, spacing: 12) {
                    Text(LocalizedStringKey.aboutNumberTest.localized)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(LocalizedStringKey.numberTestDescription.localized)
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    // 评级标准
                    VStack(alignment: .leading, spacing: 8) {
                        scoreRangeRow(range: "> 11 digits", description: LocalizedStringKey.excellent.localized)
                        scoreRangeRow(range: "9-11 digits", description: LocalizedStringKey.good.localized)
                        scoreRangeRow(range: "7-8 digits", description: LocalizedStringKey.average.localized)
                        scoreRangeRow(range: "< 7 digits", description: LocalizedStringKey.belowAverage.localized)
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
            NumberMemoryGameView(startLength: startLength)
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
        NumberMemoryIntroView()
            .environmentObject(GameDataManager())
    }
} 