//
//  AimTrainerIntroView.swift
//  mindplay
//
//  Created for MindPlay app.
//

import SwiftUI

struct AimTrainerIntroView: View {
    @EnvironmentObject var gameDataManager: GameDataManager
    @State private var navigateToGame = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 标题区域
                VStack(spacing: 5) {
                    Text(LocalizedStringKey.aimTrainerTest.localized)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    Text(LocalizedStringKey.hitTargets.localized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 10)
                
                // 示例目标
                ZStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: 60, height: 60)
                    
                    Circle()
                        .stroke(Color.white, lineWidth: 1)
                        .frame(width: 40, height: 40)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 10, height: 10)
                }
                .padding()
                
                // 最佳成绩和开始按钮卡片
                VStack {
                    HStack {
                        // 最佳成绩
                        VStack(alignment: .leading, spacing: 5) {
                            Text(LocalizedStringKey.bestScore.localized)
                                .font(.headline)
                            
                            if let bestScore = gameDataManager.getBestScore(for: .aimTrainer) {
                                Text("\(String(format: "%.1f", bestScore)) ms")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            } else {
                                Text("--")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // 开始测试按钮
                        Button {
                            navigateToGame = true
                        } label: {
                            Text(LocalizedStringKey.startTest.localized)
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                }
                .padding(.horizontal)
                
                // 游戏说明
                VStack(alignment: .leading, spacing: 15) {
                    Text(LocalizedStringKey.howToPlay.localized)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    GameInstructionRow(
                        iconName: "1.circle.fill",
                        text: LocalizedStringKey.clickToBegin.localized
                    )
                    
                    GameInstructionRow(
                        iconName: "hand.tap.fill",
                        text: "点击出现的目标，越快越好"
                    )
                    
                    GameInstructionRow(
                        iconName: "repeat",
                        text: "完成30个目标后游戏结束"
                    )
                    
                    Divider()
                        .padding(.vertical, 5)
                    
                    Text(LocalizedStringKey.aboutAimTest.localized)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(LocalizedStringKey.aimTestDescription.localized)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                
                Spacer(minLength: 30)
            }
            .padding(.bottom, 20)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToGame) {
            AimTrainerGameView()
        }
    }
}

struct GameInstructionRow: View {
    let iconName: String
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: iconName)
                .font(.system(size: 24))
                .foregroundColor(.blue)
                .frame(width: 30)
            
            Text(text)
                .font(.body)
        }
    }
}

#Preview {
    NavigationStack {
        AimTrainerIntroView()
            .environmentObject(GameDataManager())
    }
} 