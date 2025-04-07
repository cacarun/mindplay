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
    case preparing   // 准备开始新一轮，等待短暂延迟
    case watching    // 用户观看序列
    case repeating   // 用户重复序列
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
    private let buttonColor = Color(red: 0.0, green: 0.3, blue: 0.7) // 统一的按钮颜色（深蓝色）
    private let highlightColor = Color.white // 高亮时的颜色（白色）
    private let sequenceDisplayTime: Double = 0.7
    private let pauseBetweenButtons: Double = 0.3
    private let newRoundDelay: Double = 1.2 // 新一轮开始前的延迟时间
    
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
                
                // 状态提示 - 固定高度区域
                VStack {
                    statusText
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .animation(.easeInOut, value: gameState)
                }
                .frame(height: 80) // 固定高度，防止布局移动
                
                Spacer()
                
                // 游戏按钮网格 - 九宮格布局
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                    ForEach(0..<buttonCount, id: \.self) { index in
                        // 使用ZStack替代Button，避免禁用状态下的颜色变化
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(highlightedButton == index ? highlightColor : buttonColor)
                                .aspectRatio(1.0, contentMode: .fit) // 保持正方形
                                .shadow(radius: highlightedButton == index ? 8 : 2)
                        }
                        .onTapGesture {
                            if gameState == .repeating {
                                buttonPressed(index)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // 底部按钮区域 - 固定高度
                VStack {
                    if gameState == .intro || gameState == .gameOver {
                        Button(action: {
                            if gameState == .intro {
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
                        .transition(.opacity)
                        .animation(.easeInOut, value: gameState)
                    } else {
                        // 空占位符，保持高度一致
                        Color.clear
                            .frame(height: 50)
                    }
                }
                .frame(height: 70) // 固定高度
                .padding(.horizontal)
                
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
        case .preparing:
            return Text(LocalizedStringKey.getReady.localized)
        case .watching:
            // 在观看序列时不再显示“观看序列”提示
            return Text("") // 空文本，保持高度不变
        case .repeating:
            return Text(LocalizedStringKey.yourTurn.localized)
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
        
        // 先进入准备状态，给用户一点时间准备
        gameState = .preparing
        
        // 延迟后开始显示序列
        DispatchQueue.main.asyncAfter(deadline: .now() + newRoundDelay) {
            self.gameState = .watching
            self.showSequence()
        }
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
                    currentLevel += 1
                    
                    // 保存最高分
                    gameDataManager.saveResult(gameType: .sequenceMemory, score: Double(currentLevel - 1))
                    
                    // 自动进入下一轮
                    startNextLevel()
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
