//
//  SequenceMemoryResultView.swift
//  mindplay
//
//  Created for MindPlay app.
//

import SwiftUI

struct SequenceMemoryResultView: View {
    @EnvironmentObject var gameDataManager: GameDataManager
    
    let level: Int
    let onDismiss: () -> Void
    let gridSize: Int
    
    let onRestart: (Int) -> Void
    
    @State private var startNewGame = false
    
    init(level: Int, gridSize: Int = 9, onDismiss: @escaping () -> Void, onRestart: @escaping (Int) -> Void) {
        self.level = level
        self.gridSize = gridSize
        self.onDismiss = onDismiss
        self.onRestart = onRestart
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {                
                    // Header with main result
                    VStack(spacing: 8) {
                        Text(LocalizedStringKey.levelReached.localized)
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(String(level))
                            .font(.system(size: 64, weight: .bold))
                            .foregroundColor(scoreColor)
                        
                        Text(performanceText)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(scoreColor)
                            .padding(.top, 4)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
                    // Statistics section
                    VStack(alignment: .leading, spacing: 16) {
                        Text(LocalizedStringKey.statistics.localized)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        // Performance rating
                        VStack(alignment: .leading, spacing: 12) {
                            Text(LocalizedStringKey.rating.localized)
                                .font(.headline)
                                
                            HStack(spacing: 10) {
                                ForEach(0..<5, id: \.self) { index in
                                    Image(systemName: index < ratingStars ? "star.fill" : "star")
                                        .font(.title)
                                        .foregroundColor(.yellow)
                                }
                                
                                Spacer()
                                
                                Text(performanceText)
                                    .font(.headline)
                                    .foregroundColor(scoreColor)
                            }
                            .padding(.top, 4)
                        }
                        
                        // Distribution chart
                    VStack(alignment: .leading, spacing: 8) {
                        Text(LocalizedStringKey.distribution.localized)
                            .font(.headline)
                            .padding(.top, 8)
                        
                        // Distribution bell curve chart
                        ZStack(alignment: .bottomLeading) {
                            // Background grid lines
                            VStack(spacing: 0) {
                                ForEach(0..<5, id: \.self) { _ in
                                    Divider()
                                    Spacer()
                                }
                                Divider()
                            }
                            
                            HStack(spacing: 0) {
                                ForEach(0..<30, id: \.self) { _ in
                                    Divider()
                                    Spacer()
                                }
                                Divider()
                            }
                            
                            // Bell curve
                            Path { path in
                                let width: CGFloat = 300
                                let height: CGFloat = 120
                                
                                // Start at 0,0 (bottom left)
                                path.move(to: CGPoint(x: 0, y: height))
                                
                                // Initial small peak (less common very low scores)
                                path.addLine(to: CGPoint(x: width * 0.1, y: height * 0.7))
                                path.addLine(to: CGPoint(x: width * 0.15, y: height * 0.4))
                                
                                // Dip after first small peak
                                path.addLine(to: CGPoint(x: width * 0.2, y: height * 0.65))
                                
                                // Main bell curve up
                                path.addLine(to: CGPoint(x: width * 0.3, y: height * 0.3))
                                path.addLine(to: CGPoint(x: width * 0.4, y: height * 0.1))
                                
                                // Main bell curve peak
                                path.addLine(to: CGPoint(x: width * 0.5, y: height * 0.05))
                                
                                // Main bell curve down
                                path.addLine(to: CGPoint(x: width * 0.6, y: height * 0.1))
                                path.addLine(to: CGPoint(x: width * 0.7, y: height * 0.3))
                                path.addLine(to: CGPoint(x: width * 0.8, y: height * 0.5))
                                path.addLine(to: CGPoint(x: width * 0.9, y: height * 0.7))
                                path.addLine(to: CGPoint(x: width, y: height * 0.8))
                                
                                // Complete the path back to start for filling
                                path.addLine(to: CGPoint(x: width, y: height))
                                path.closeSubpath()
                            }
                            .fill(Color.blue.opacity(0.2))
                            
                            // Bell curve stroke
                            Path { path in
                                let width: CGFloat = 300
                                let height: CGFloat = 120
                                
                                // Start at 0,0 (bottom left)
                                path.move(to: CGPoint(x: 0, y: height))
                                
                                // Initial small peak (less common very low scores)
                                path.addLine(to: CGPoint(x: width * 0.1, y: height * 0.7))
                                path.addLine(to: CGPoint(x: width * 0.15, y: height * 0.4))
                                
                                // Dip after first small peak
                                path.addLine(to: CGPoint(x: width * 0.2, y: height * 0.65))
                                
                                // Main bell curve up
                                path.addLine(to: CGPoint(x: width * 0.3, y: height * 0.3))
                                path.addLine(to: CGPoint(x: width * 0.4, y: height * 0.1))
                                
                                // Main bell curve peak
                                path.addLine(to: CGPoint(x: width * 0.5, y: height * 0.05))
                                
                                // Main bell curve down
                                path.addLine(to: CGPoint(x: width * 0.6, y: height * 0.1))
                                path.addLine(to: CGPoint(x: width * 0.7, y: height * 0.3))
                                path.addLine(to: CGPoint(x: width * 0.8, y: height * 0.5))
                                path.addLine(to: CGPoint(x: width * 0.9, y: height * 0.7))
                                path.addLine(to: CGPoint(x: width, y: height * 0.8))
                            }
                            .stroke(Color.blue, lineWidth: 2)
                            
                            // Data points
                            ZStack {
                                ForEach(0..<12, id: \.self) { i in
                                    let width: CGFloat = 300
                                    let height: CGFloat = 120
                                    let x = width * (0.15 + CGFloat(i) * 0.07)
                                    let y: CGFloat = {
                                        if i < 1 {
                                            return height * 0.4
                                        } else if i < 4 {
                                            return height * (0.3 - CGFloat(i) * 0.06)
                                        } else if i < 7 {
                                            return height * (0.05 + (CGFloat(i) - 4) * 0.05)
                                        } else {
                                            return height * (0.2 + (CGFloat(i) - 7) * 0.1)
                                        }
                                    }()
                                    
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: 6, height: 6)
                                        .position(x: x, y: y)
                                }
                            }
                            
                            // User position indicator
                            ZStack {
                                let width: CGFloat = 300
                                let height: CGFloat = 120
                                let userPosition = getUserPositionX()
                                
                                // Vertical line at user position
                                Rectangle()
                                    .fill(scoreColor)
                                    .frame(width: 2, height: height * 0.9)
                                    .position(x: width * userPosition, y: height * 0.45)
                                
                                // User marker
                                Circle()
                                    .fill(scoreColor)
                                    .frame(width: 12, height: 12)
                                    .position(x: width * userPosition, y: height * getUserPositionY())
                            }
                            
                            // X-axis labels
                            HStack(spacing: 0) {
                                Text("0")
                                    .font(.caption2)
                                    .frame(width: 20, alignment: .center)
                                Spacer()
                                Text("5")
                                    .font(.caption2)
                                    .frame(width: 20, alignment: .center)
                                Spacer()
                                Text("10")
                                    .font(.caption2)
                                    .frame(width: 20, alignment: .center)
                                Spacer()
                                Text("15")
                                    .font(.caption2)
                                    .frame(width: 20, alignment: .center)
                                Spacer()
                                Text("20")
                                    .font(.caption2)
                                    .frame(width: 20, alignment: .center)
                                Spacer()
                                Text("25")
                                    .font(.caption2)
                                    .frame(width: 20, alignment: .center)
                                Spacer()
                                Text("30")
                                    .font(.caption2)
                                    .frame(width: 20, alignment: .center)
                            }
                            .padding(.top, 125)
                        }
                        .frame(height: 150)
                        .padding(.horizontal, 10)
                    }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
                    // Interpretation
                    VStack(alignment: .leading, spacing: 12) {
                        Text(LocalizedStringKey.whatThisMeans.localized)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(performanceDescription)
                            .font(.body)
                            
                        // Additional explanation about memory
                        Text(LocalizedStringKey.memoryExplanation.localized)
                            .font(.body)
                            .padding(.top, 4)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    

                    
                    // Action buttons
                    HStack(spacing: 16) {
                        Button(action: {
                            onDismiss()
                        }) {
                            Text(LocalizedStringKey.backToMenu.localized)
                                .font(.headline)
                                .foregroundColor(.blue)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(12)
                        }
                        
                        Button(action: {
                            // 调用重新开始游戏的回调
                            onRestart(gridSize)
                        }) {
                            Text(LocalizedStringKey.playAgain.localized)
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationBarTitle(LocalizedStringKey.results.localized, displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                onDismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
            })
        }
    }
    
    // MARK: - Computed Properties
    
    private var ratingStars: Int {
        switch level {
        case 0...2: return 1
        case 3...5: return 2
        case 6...8: return 3
        case 9...12: return 4
        default: return 5
        }
    }
    
    private var scoreColor: Color {
        switch ratingStars {
        case 1: return .red
        case 2: return .orange
        case 3: return .blue
        case 4: return .green
        case 5: return .purple
        default: return .blue
        }
    }
    
    private var performanceText: String {
        switch ratingStars {
        case 1: return LocalizedStringKey.needsPractice.localized
        case 2: return LocalizedStringKey.fairMemory.localized
        case 3: return LocalizedStringKey.goodMemory.localized
        case 4: return LocalizedStringKey.greatMemory.localized
        case 5: return LocalizedStringKey.exceptionalMemory.localized
        default: return LocalizedStringKey.goodMemory.localized
        }
    }
    
    private var performanceDescription: String {
        switch ratingStars {
        case 1: return LocalizedStringKey.needsPracticeDesc.localized
        case 2: return LocalizedStringKey.fairMemoryDesc.localized
        case 3: return LocalizedStringKey.goodMemoryDesc.localized
        case 4: return LocalizedStringKey.greatMemoryDesc.localized
        case 5: return LocalizedStringKey.exceptionalMemoryDesc.localized
        default: return LocalizedStringKey.goodMemoryDesc.localized
        }
    }
    
    private var memoryCells: Int {
        return level
    }
    
    private var performancePercentage: Int {
        // Simple formula for performance percentage based on level
        let basePerfomance = min(level * 8, 95) // Max 95%
        return max(basePerfomance, 20) // Min 20%
    }
    
    // 获取用户在分布图中的X坐标位置
    private func getUserPositionX() -> CGFloat {
        // 根据等级确定用户在分布图中的位置
        // 最大值为1.0 (右边缘)
        switch level {
        case 0...2: return 0.2  // 较低水平在左侧
        case 3...5: return 0.35 // 低于平均水平
        case 6...8: return 0.5  // 平均水平在中间
        case 9...12: return 0.7 // 高于平均水平
        default: return 0.85    // 极高水平在右侧
        }
    }
    
    // 获取用户在分布图中的Y坐标位置
    private func getUserPositionY() -> CGFloat {
        // 根据等级确定用户在曲线上的高度
        // 曲线最高点约为0.05，最低点为1.0
        switch level {
        case 0...2: return 0.65  // 第一个小峰值
        case 3...5: return 0.3   // 主曲线上升段
        case 6...8: return 0.05  // 主曲线顶点
        case 9...12: return 0.15 // 主曲线下降段
        default: return 0.4      // 曲线尾部
        }
    }
    
    // MARK: - Helper Views
    
    private func statCard(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private func statisticRow(title: String, value: String, subtitle: String) -> some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

#Preview {
    SequenceMemoryResultView(level: 9, gridSize: 9) {
        // Dismiss action
    } onRestart: { _ in
        // Restart action
    }
    .environmentObject(GameDataManager())
}
