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
    @State private var gridSize = 9 // 默认使用3x3宫格（9个格子）
    @State private var isAnimating = false
    
    // 可选的宫格数量选项
    private let gridOptions = [4, 9, 16] // 2x2, 3x3, 4x4
    
    // 背景渐变色 - 使用蓝紫色渐变，呼应记忆和思考的主题
    private let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.3, green: 0.4, blue: 0.9),
            Color(red: 0.6, green: 0.3, blue: 0.9)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        ZStack {
            // 渐变背景
            backgroundGradient
                .ignoresSafeArea()
            
            // 背景装饰元素
            GeometryReader { geometry in
                ZStack {
                    // 装饰性图形
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 120, height: 120)
                        .position(x: geometry.size.width * 0.85, y: geometry.size.height * 0.15)
                        .rotationEffect(.degrees(isAnimating ? 10 : -10))
                        .animation(
                            Animation.easeInOut(duration: 6)
                                .repeatForever(autoreverses: true), 
                            value: isAnimating
                        )
                    
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 100, height: 100)
                        .position(x: geometry.size.width * 0.15, y: geometry.size.height * 0.8)
                        .offset(y: isAnimating ? 20 : -20)
                        .animation(
                            Animation.easeInOut(duration: 5)
                                .repeatForever(autoreverses: true), 
                            value: isAnimating
                        )
                    
                    // 添加一些小方块作为记忆主题的装饰
                    decorativeSquares(for: geometry)
                }
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(LocalizedStringKey.sequenceMemoryTest.localized)
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 1, y: 1)
                        
                        Text(LocalizedStringKey.rememberPattern.localized)
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.9))
                            .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // 自定义宫格数量
                    VStack(alignment: .leading, spacing: 14) {
                        Text(LocalizedStringKey.gridSize.localized)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        HStack(spacing: 12) {
                            ForEach(gridOptions, id: \.self) { size in
                                Button(action: {
                                    gridSize = size
                                    // 添加触觉反馈
                                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                    impactMed.impactOccurred()
                                }) {
                                    gridButton(for: size)
                                }
                                .scaleEffect(gridSize == size ? 1.1 : 1.0)
                                .animation(
                                    .spring(response: 0.3, dampingFraction: 0.6),
                                    value: gridSize
                                )
                            }
                            
                            Spacer()
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                    
                    // 最佳成绩和开始按钮
                    HStack(spacing: 15) {
                        // 最佳成绩
                        if let bestScore = gameDataManager.getBestScore(for: .sequenceMemory) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(LocalizedStringKey.bestScore.localized)
                                    .font(.headline)
                                    .foregroundColor(.white.opacity(0.9))
                                
                                Text(String(format: LocalizedStringKey.level.localized + ": %d", Int(bestScore)))
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // 开始测试按钮
                        Button(action: {
                            isShowingGame = true
                            // 添加触觉反馈
                            let impactMed = UIImpactFeedbackGenerator(style: .medium)
                            impactMed.impactOccurred()
                        }) {
                            Text(LocalizedStringKey.startSequence.localized)
                                .font(.headline)
                                .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.9))
                                .frame(height: 55)
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                    
                    // 游戏说明
                    VStack(alignment: .leading, spacing: 18) {
                        Text(LocalizedStringKey.howToPlay.localized)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        instructionItem(number: "1", text: LocalizedStringKey.watchSequence.localized)
                        instructionItem(number: "2", text: LocalizedStringKey.repeatSequence.localized)
                        instructionItem(number: "3", text: LocalizedStringKey.sequenceWillGetLonger.localized)
                    }
                    .padding()
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                    
                    // About section
                    VStack(alignment: .leading, spacing: 14) {
                        Text(LocalizedStringKey.aboutSequenceTest.localized)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(LocalizedStringKey.sequenceTestDescription.localized)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding()
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                    
                    Spacer(minLength: 40)
                }
                .padding(.vertical)
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .fullScreenCover(isPresented: $isShowingGame) {
            SequenceMemoryGameView(gridSize: gridSize)
        }
        .onAppear {
            isAnimating = true
        }
    }
    
    // 分解复杂表达式 - 装饰性小方块
    private func decorativeSquares(for geometry: GeometryProxy) -> some View {
        ZStack {
            ForEach(0..<3, id: \.self) { i in
                let yOffsets: [CGFloat] = [10, -15, 5]
                let durations: [Double] = [4, 5, 6]
                let widthFactors: [CGFloat] = [0.2, 0.5, 0.7]
                let heightFactors: [CGFloat] = [0.2, 0.1, 0.3]
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 40, height: 40)
                    .position(
                        x: geometry.size.width * widthFactors[i],
                        y: geometry.size.height * heightFactors[i]
                    )
                    .offset(y: isAnimating ? yOffsets[i] : 0)
                    .animation(
                        Animation.easeInOut(duration: durations[i])
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
            }
        }
    }
    
    // 分解复杂表达式 - 网格按钮
    private func gridButton(for size: Int) -> some View {
        // 创建一个视觉上的网格图案
        VStack(spacing: 3) {
            let rows = Int(sqrt(Double(size)))
            
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: 3) {
                    ForEach(0..<rows, id: \.self) { col in
                        let sizeIndex = min(rows-2, 2)
                        let cellSize: CGFloat = [14, 10, 8][sizeIndex]
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.white)
                            .frame(width: cellSize, height: cellSize)
                    }
                }
            }
        }
        .padding(10)
        .background(gridSize == size ? 
                   Color.white.opacity(0.4) : Color.white.opacity(0.1))
        .foregroundColor(gridSize == size ? .white : .white.opacity(0.7))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.5), lineWidth: gridSize == size ? 2 : 0)
        )
        .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
    }
    
    private func instructionItem(number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Text(number)
                .font(.headline)
                .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.9))
                .frame(width: 36, height: 36)
                .background(Color.white)
                .clipShape(Circle())
            
            Text(text)
                .font(.body)
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
}

#Preview {
    SequenceMemoryIntroView()
        .environmentObject(GameDataManager())
}
