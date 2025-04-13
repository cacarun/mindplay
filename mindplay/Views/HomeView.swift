//
//  HomeView.swift
//  mindplay
//
//  Created for MindPlay app.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var gameDataManager: GameDataManager
    
    // 使用更紧凑的网格布局
    private let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 170), spacing: 15)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text(LocalizedStringKey.appName.localized)
                        .font(.system(size: 36, weight: .bold))
                        .padding(.top, 20)
                    
                    Text(LocalizedStringKey.trainYourBrain.localized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 10)
                    
                    // 使用网格布局展示游戏卡片
                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(GameType.allCases) { gameType in
                            GameCardView(gameType: gameType)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 40)
                }
            }
            .navigationBarTitle("", displayMode: .inline)
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
        }
    }
}

struct GameCardView: View {
    let gameType: GameType
    @EnvironmentObject var gameDataManager: GameDataManager
    
    var body: some View {
        NavigationLink(destination: destinationView) {
            // 简化的游戏卡片设计
            VStack(spacing: 10) {
                // 图标
                Image(systemName: gameType.iconName)
                    .font(.system(size: 30))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                
                // 游戏名称 - 使用游戏类型对应的本地化字符串
                Text(gameType.localizedName)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(minWidth: 120, minHeight: 120)
            .padding(12)
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var destinationView: some View {
        switch gameType {
        case .reactionTime:
            return AnyView(ReactionTimeIntroView())
        case .sequenceMemory:
            return AnyView(SequenceMemoryIntroView())
        case .aimTrainer:
            return AnyView(AimTrainerIntroView())
        case .numberMemory:
            return AnyView(NumberMemoryIntroView())
        case .verbalMemory:
            return AnyView(VerbalMemoryIntroView())
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(GameDataManager())
}
