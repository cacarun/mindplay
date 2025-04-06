//
//  SequenceMemoryIntroView.swift
//  mindplay
//
//  Created for MindPlay app.
//

import SwiftUI

struct SequenceMemoryIntroView: View {
    @EnvironmentObject var gameDataManager: GameDataManager
    @State private var isShowingGame = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(LocalizedStringKey.sequenceMemoryTest.localized)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(LocalizedStringKey.rememberPattern.localized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                // 最佳成绩
                if let bestScore = gameDataManager.getBestScore(for: .sequenceMemory) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(LocalizedStringKey.bestScore.localized)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(String(format: LocalizedStringKey.level.localized + ": %d", Int(bestScore)))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                }
                
                // 开始按钮
                Button(action: {
                    isShowingGame = true
                }) {
                    Text(LocalizedStringKey.startSequence.localized)
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 44)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // 游戏说明
                VStack(alignment: .leading, spacing: 16) {
                    Text(LocalizedStringKey.howToPlay.localized)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    instructionItem(number: "1", text: LocalizedStringKey.watchSequence.localized)
                    instructionItem(number: "2", text: LocalizedStringKey.repeatSequence.localized)
                    instructionItem(number: "3", text: LocalizedStringKey.sequenceWillGetLonger.localized)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                
                // About section
                VStack(alignment: .leading, spacing: 12) {
                    Text(LocalizedStringKey.aboutSequenceTest.localized)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(LocalizedStringKey.sequenceTestDescription.localized)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                
                Spacer(minLength: 40)
            }
            .padding(.vertical)
        }
        .navigationBarTitle("", displayMode: .inline)
        .fullScreenCover(isPresented: $isShowingGame) {
            SequenceMemoryGameView()
        }
    }
    
    private func instructionItem(number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Text(number)
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
                .background(Color.blue)
                .clipShape(Circle())
            
            Text(text)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
}

#Preview {
    SequenceMemoryIntroView()
        .environmentObject(GameDataManager())
}
