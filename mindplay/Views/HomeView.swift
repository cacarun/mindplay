//
//  HomeView.swift
//  mindplay
//
//  Created for MindPlay app.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var gameDataManager: GameDataManager
    @State private var isAnimating = false
    
    // 使用更紧凑的网格布局
    private let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 170), spacing: 18)
    ]
    
    // 背景渐变色
    private let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.3, green: 0.7, blue: 0.9),
            Color(red: 0.5, green: 0.3, blue: 0.9)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 彩色渐变背景
                backgroundGradient
                    .ignoresSafeArea()
                
                // 背景装饰元素 - 悬浮气泡
                GeometryReader { geometry in
                    ZStack {
                        // 几个装饰性的圆形
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 100, height: 100)
                            .position(x: geometry.size.width * 0.1, y: geometry.size.height * 0.2)
                            .offset(y: isAnimating ? -20 : 0)
                            .animation(Animation.easeInOut(duration: 4).repeatForever(autoreverses: true), value: isAnimating)
                        
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 80, height: 80)
                            .position(x: geometry.size.width * 0.8, y: geometry.size.height * 0.3)
                            .offset(y: isAnimating ? 15 : -15)
                            .animation(Animation.easeInOut(duration: 3).repeatForever(autoreverses: true), value: isAnimating)
                        
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 120, height: 120)
                            .position(x: geometry.size.width * 0.7, y: geometry.size.height * 0.7)
                            .offset(y: isAnimating ? 20 : 0)
                            .animation(Animation.easeInOut(duration: 5).repeatForever(autoreverses: true), value: isAnimating)
                    }
                }
                
                ScrollView {
                    VStack(spacing: 25) {
                        // 应用标题
                        VStack(spacing: 6) {
                            Text(LocalizedStringKey.appName.localized)
                                .font(.system(size: 38, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: Color.black.opacity(0.2), radius: 2, x: 1, y: 1)
                                .padding(.top, 25)
                            
                            Text(LocalizedStringKey.trainYourBrain.localized)
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.9))
                                .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                                .padding(.bottom, 10)
                        }
                        .scaleEffect(isAnimating ? 1.0 : 0.95)
                        .animation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
                        
                        // 使用网格布局展示游戏卡片
                        LazyVGrid(columns: columns, spacing: 18) {
                            ForEach(GameType.allCases) { gameType in
                                GameCardView(gameType: gameType)
                                    .transition(.scale)
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 50)
                    }
                }
            }
            .navigationBarTitle("", displayMode: .inline)
            .onAppear {
                isAnimating = true
            }
        }
    }
}

struct GameCardView: View {
    let gameType: GameType
    @EnvironmentObject var gameDataManager: GameDataManager
    @State private var isHovering = false
    
    // 根据游戏类型返回不同的卡片背景色
    private var cardGradient: LinearGradient {
        switch gameType {
        case .reactionTime:
            return LinearGradient(gradient: Gradient(colors: [Color.orange, Color.red]), startPoint: .topLeading, endPoint: .bottomTrailing)
        case .sequenceMemory:
            return LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
        case .aimTrainer:
            return LinearGradient(gradient: Gradient(colors: [Color.green, Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing)
        case .numberMemory:
            return LinearGradient(gradient: Gradient(colors: [Color.purple, Color.pink]), startPoint: .topLeading, endPoint: .bottomTrailing)
        case .verbalMemory:
            return LinearGradient(gradient: Gradient(colors: [Color.yellow, Color.orange]), startPoint: .topLeading, endPoint: .bottomTrailing)
        case .chimpTest:
            return LinearGradient(gradient: Gradient(colors: [Color.teal, Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing)
        case .visualMemory:
            return LinearGradient(gradient: Gradient(colors: [Color.indigo, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
        case .schulteTable:
            return LinearGradient(gradient: Gradient(colors: [Color.mint, Color.cyan]), startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
    
    var body: some View {
        NavigationLink(destination: destinationView) {
            // 创意游戏卡片设计
            VStack(spacing: 12) {
                // 图标
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 72, height: 72)
                    
                    Image(systemName: gameType.iconName)
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
                }
                .padding(.top, 8)
                
                // 游戏名称
                Text(gameType.localizedName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .frame(height: 40)
                    .padding(.horizontal, 5)
                    .padding(.bottom, 8)
            }
            .frame(minWidth: 130, minHeight: 140)
            .background(cardGradient)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
            .scaleEffect(isHovering ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isHovering)
            .onHover { hovering in
                isHovering = hovering
            }
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
        case .chimpTest:
            return AnyView(ChimpTestIntroView())
        case .visualMemory:
            return AnyView(VisualMemoryIntroView())
        case .schulteTable:
            return AnyView(SchulteTableIntroView())
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(GameDataManager())
}
