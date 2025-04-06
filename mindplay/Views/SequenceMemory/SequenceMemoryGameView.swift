//
//  SequenceMemoryGameView.swift
//  mindplay
//
//  Created for MindPlay app.
//

import SwiftUI
import AVFoundation

enum SequenceGameState {
    case intro       // 初始状态，显示开始按钮
    case watching    // 用户观看序列
    case repeating   // 用户重复序列
    case correct     // 用户正确重复了序列
    case wrong       // 用户错误重复了序列
    case gameOver    // 游戏结束
}

struct SequenceMemoryGameView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var gameDataManager: GameDataManager
    
    // 游戏状态
    @State private var gameState: SequenceGameState = .intro
    @State private var currentLevel = 1
    @State private var sequence: [Int] = []
    @State private var userSequence: [Int] = []
    @State private var isShowingSequence = false
    @State private var currentIndex = 0
    @State private var highlightedButton: Int? = nil
    
    // 游戏配置
    private let buttonCount = 9 // 九宮格
    private let buttonColor = Color(red: 0.3, green: 0.5, blue: 0.8) // 统一的按钮颜色
    private let highlightColor = Color.white // 高亮时的颜色
    private let sequenceDisplayTime: Double = 0.7
    private let pauseBetweenButtons: Double = 0.3
    
    // 音效服务
    private let soundService = SoundService.shared
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            VStack(spacing: 20) {
                // 顶部信息
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Text(String(format: "%@ %d", LocalizedStringKey.level.localized, currentLevel))
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // 占位，保持对称
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.clear)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // 状态提示
                statusText
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .animation(.easeInOut, value: gameState)
                
                Spacer()
                
                // 游戏按钮网格 - 九宮格布局
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                    ForEach(0..<buttonCount, id: \.self) { index in
                        Button(action: {
                            if gameState == .repeating {
                                buttonPressed(index)
                            }
                        }) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(highlightedButton == index ? highlightColor : buttonColor)
                                .aspectRatio(1.0, contentMode: .fit) // 保持正方形
                                .shadow(radius: highlightedButton == index ? 8 : 2)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(gameState != .repeating)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // 底部按钮
                if gameState == .intro || gameState == .correct || gameState == .gameOver {
                    Button(action: {
                        if gameState == .intro || gameState == .correct {
                            startNextLevel()
                        } else if gameState == .gameOver {
                            dismiss()
                        }
                    }) {
                        Text(buttonText)
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(height: 50)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .transition(.opacity)
                    .animation(.easeInOut, value: gameState)
                }
                
                Spacer()
            }
            .padding(.vertical)
        }
        .onAppear {
            prepareGame()
        }
    }
    
    // MARK: - Computed Properties
    
    private var statusText: Text {
        switch gameState {
        case .intro:
            return Text(LocalizedStringKey.watchSequence.localized)
        case .watching:
            return Text(LocalizedStringKey.watchSequence.localized)
        case .repeating:
            return Text(LocalizedStringKey.yourTurn.localized)
        case .correct:
            return Text(LocalizedStringKey.correct.localized)
        case .wrong:
            return Text(LocalizedStringKey.wrong.localized)
        case .gameOver:
            return Text(String(format: LocalizedStringKey.finalLevel.localized, currentLevel - 1))
        }
    }
    
    private var buttonText: String {
        switch gameState {
        case .intro:
            return LocalizedStringKey.startSequence.localized
        case .correct:
            return LocalizedStringKey.nextRound.localized
        case .gameOver:
            return LocalizedStringKey.backToMenu.localized
        default:
            return ""
        }
    }
    
    // MARK: - Game Logic
    
    private func prepareGame() {
        currentLevel = 1
        sequence = []
        userSequence = []
        gameState = .intro
    }
    
    private func startNextLevel() {
        // 添加一个新的随机按钮到序列中
        sequence.append(Int.random(in: 0..<buttonCount))
        userSequence = []
        currentIndex = 0
        gameState = .watching
        
        // 开始显示序列
        showSequence()
    }
    
    private func showSequence() {
        // 重置高亮按钮
        highlightedButton = nil
        
        // 如果已经显示完所有序列，切换到用户输入模式
        if currentIndex >= sequence.count {
            gameState = .repeating
            return
        }
        
        // 高亮当前按钮
        highlightedButton = sequence[currentIndex]
        
        // 播放音效
        soundService.playSound(named: "tile_tap")
        
        // 延迟后取消高亮并显示下一个按钮
        DispatchQueue.main.asyncAfter(deadline: .now() + sequenceDisplayTime) {
            highlightedButton = nil
            
            DispatchQueue.main.asyncAfter(deadline: .now() + pauseBetweenButtons) {
                currentIndex += 1
                showSequence()
            }
        }
    }
    
    private func buttonPressed(_ index: Int) {
        // 高亮被按下的按钮
        highlightedButton = index
        
        // 播放音效
        soundService.playSound(named: "tile_tap")
        
        // 添加到用户序列
        userSequence.append(index)
        
        // 检查是否正确
        let userIndex = userSequence.count - 1
        if userIndex < sequence.count && sequence[userIndex] == index {
            // 正确的按钮
            
            // 短暂延迟后取消高亮
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                highlightedButton = nil
                
                // 检查是否完成当前序列
                if userSequence.count == sequence.count {
                    // 完成当前级别
                    gameState = .correct
                    currentLevel += 1
                    
                    // 保存最高分
                    gameDataManager.saveResult(gameType: .sequenceMemory, score: Double(currentLevel - 1))
                }
            }
        } else {
            // 错误的按钮
            gameState = .wrong
            
            // 短暂延迟后显示游戏结束
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                gameState = .gameOver
                
                // 保存最高分
                gameDataManager.saveResult(gameType: .sequenceMemory, score: Double(currentLevel - 1))
            }
        }
    }
}

#Preview {
    SequenceMemoryGameView()
        .environmentObject(GameDataManager())
}
