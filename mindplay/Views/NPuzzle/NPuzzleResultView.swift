//
//  NPuzzleResultView.swift
//  mindplay
//
//  Created for MindPlay app.
//

import SwiftUI
import Charts

struct NPuzzleResultView: View {
    @EnvironmentObject var gameDataManager: GameDataManager
    @Environment(\.dismiss) private var dismiss
    @State private var isAnimating = false
    @State private var chartAnimation = false
    
    let timeTaken: Int
    let moveCount: Int
    let gridSize: Int
    let onDismiss: () -> Void
    let onRestart: (Int) -> Void
    
    // 背景渐变
    private let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.1, green: 0.6, blue: 0.7),
            Color(red: 0.2, green: 0.4, blue: 0.6)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // 模拟历史数据
    private var historicalData: [HistoricalResult] {
        let results = gameDataManager.gameResults.filter {
            $0.gameType == GameType.nPuzzle.rawValue &&
            $0.extraData == String(gridSize)
        }
        
        return results.prefix(10).map { result in
            HistoricalResult(
                date: result.date,
                time: Int(result.score)
            )
        }
    }
    
    // 历史结果模型
    private struct HistoricalResult: Identifiable {
        let id = UUID()
        let date: Date
        let time: Int
    }
    
    var body: some View {
        ZStack {
            // 渐变背景
            backgroundGradient
                .ignoresSafeArea()
            
            // 背景装饰元素
            GeometryReader { geometry in
                ForEach(0..<8) { index in
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.1 + Double(index) * 0.01))
                        .frame(width: CGFloat(50 + index * 5), height: CGFloat(50 + index * 5))
                        .position(
                            x: geometry.size.width * getRandomPosition(seed: index),
                            y: geometry.size.height * getRandomPosition(seed: index + 10)
                        )
                        .rotationEffect(.degrees(isAnimating ? Double(index * 10) : 0))
                        .animation(
                            Animation.easeInOut(duration: Double(3 + index)).repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                }
            }
            
            ScrollView {
                VStack(spacing: 25) {
                    // 标题区域
                    Text(LocalizedStringKey.results.localized)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.2), radius: 2, x: 1, y: 1)
                        .padding(.top, 20)
                    
                    // 成绩卡片
                    VStack(spacing: 15) {
                        // 完成时间
                        Text(formatTime(seconds: timeTaken))
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(Color(red: 0.1, green: 0.6, blue: 0.7))
                            .opacity(isAnimating ? 1.0 : 0.0)
                            .scaleEffect(isAnimating ? 1.0 : 0.5)
                            .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0), value: isAnimating)
                        
                        Text(LocalizedStringKey.timeUsed.localized)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Divider()
                            .padding(.vertical, 5)
                        
                        // 统计数据
                        HStack(spacing: 30) {
                            // 网格大小
                            VStack {
                                Text("\(gridSize)×\(gridSize)")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(Color(red: 0.1, green: 0.6, blue: 0.7))
                                
                                Text(LocalizedStringKey.gridSize.localized)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            // 移动次数
                            VStack {
                                Text("\(moveCount)")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(Color(red: 0.1, green: 0.6, blue: 0.7))
                                
                                Text(LocalizedStringKey.movesMade.localized)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    )
                    .padding(.horizontal)
                    
                    // 表现评级卡片
                    VStack(alignment: .leading, spacing: 15) {
                        Text(LocalizedStringKey.performance.localized)
                            .font(.headline)
                            .foregroundColor(Color(red: 0.1, green: 0.6, blue: 0.7))
                        
                        HStack {
                            // 评级图标
                            ZStack {
                                Circle()
                                    .fill(getPerformanceColor())
                                    .frame(width: 60, height: 60)
                                
                                Image(systemName: getPerformanceIcon())
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 5) {
                                Text(getPerformanceTitle())
                                    .font(.headline)
                                    .foregroundColor(getPerformanceColor())
                                
                                Text(getPerformanceDescription())
                                    .font(.subheadline)
                                    .foregroundColor(.black.opacity(0.7))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(.leading, 10)
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    )
                    .padding(.horizontal)
                    
                    // 历史数据图表卡片
                    if !historicalData.isEmpty {
                        VStack(alignment: .leading, spacing: 15) {
                            Text(LocalizedStringKey.yourAttempts.localized)
                                .font(.headline)
                                .foregroundColor(Color(red: 0.1, green: 0.6, blue: 0.7))
                            
                            // 历史时间图表
                            Chart {
                                ForEach(historicalData.indices, id: \.self) { index in
                                    let result = historicalData[index]
                                    BarMark(
                                        x: .value("Attempt", index + 1),
                                        y: .value("Time", chartAnimation ? result.time : 0)
                                    )
                                    .foregroundStyle(
                                        index == 0 ? Color(red: 0.1, green: 0.6, blue: 0.7) : Color.blue.opacity(0.5)
                                    )
                                }
                            }
                            .frame(height: 200)
                            .chartYAxis {
                                AxisMarks(position: .leading) { value in
                                    if let time = value.as(Int.self) {
                                        AxisValueLabel {
                                            Text(formatTime(seconds: time))
                                                .font(.caption)
                                        }
                                    }
                                    AxisGridLine()
                                }
                            }
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    withAnimation(.spring(response: 1.0, dampingFraction: 0.8, blendDuration: 0)) {
                                        chartAnimation = true
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        )
                        .padding(.horizontal)
                    }
                    
                    // 说明卡片
                    VStack(alignment: .leading, spacing: 15) {
                        Text(LocalizedStringKey.whatThisMeans.localized)
                            .font(.headline)
                            .foregroundColor(Color(red: 0.1, green: 0.6, blue: 0.7))
                        
                        Text(LocalizedStringKey.nPuzzleExplanation.localized)
                            .font(.subheadline)
                            .foregroundColor(.black.opacity(0.7))
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.bottom, 5)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    )
                    .padding(.horizontal)
                    
                    // 操作按钮
                    HStack(spacing: 20) {
                        // 返回首页按钮
                        Button {
                            // 触觉反馈
                            let impactMed = UIImpactFeedbackGenerator(style: .medium)
                            impactMed.impactOccurred()
                            onDismiss()
                        } label: {
                            HStack {
                                Image(systemName: "house.fill")
                                Text(LocalizedStringKey.home.localized)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                            )
                            .foregroundColor(Color(red: 0.1, green: 0.6, blue: 0.7))
                        }
                        
                        // 再玩一次按钮
                        Button {
                            // 触觉反馈
                            let impactMed = UIImpactFeedbackGenerator(style: .medium)
                            impactMed.impactOccurred()
                            dismiss()
                            onRestart(gridSize)
                        } label: {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                Text(LocalizedStringKey.playAgain.localized)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 0.1, green: 0.6, blue: 0.7),
                                                Color(red: 0.2, green: 0.4, blue: 0.6)
                                            ]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
                            )
                            .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                }
            }
        }
        .onAppear {
            isAnimating = true
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(trailing: Button(action: {
            onDismiss()
        }) {
            Image(systemName: "xmark.circle.fill")
                .font(.title2)
                .foregroundColor(.white.opacity(0.7))
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        })
    }
    
    // 根据时间获取表现评级
    private func getPerformanceTitle() -> String {
        let seconds = Double(timeTaken)
        let threshold3x3 = gridSize == 3 ? 1.0 : (gridSize == 4 ? 2.0 : 3.0) // 难度系数
        
        if seconds < 30 * threshold3x3 {
            return LocalizedStringKey.excellent.localized
        } else if seconds < 60 * threshold3x3 {
            return LocalizedStringKey.good.localized
        } else if seconds < 120 * threshold3x3 {
            return LocalizedStringKey.average.localized
        } else {
            return LocalizedStringKey.belowAverage.localized
        }
    }
    
    // 根据时间获取表现描述
    private func getPerformanceDescription() -> String {
        let seconds = Double(timeTaken)
        let threshold3x3 = gridSize == 3 ? 1.0 : (gridSize == 4 ? 2.0 : 3.0) // 难度系数
        
        if seconds < 30 * threshold3x3 {
            return LocalizedStringKey.excellentNPuzzleSkill.localized
        } else if seconds < 60 * threshold3x3 {
            return LocalizedStringKey.goodNPuzzleSkill.localized
        } else if seconds < 120 * threshold3x3 {
            return LocalizedStringKey.averageNPuzzleSkill.localized
        } else {
            return LocalizedStringKey.belowAverageNPuzzleSkill.localized
        }
    }
    
    // 根据时间获取表现颜色
    private func getPerformanceColor() -> Color {
        let seconds = Double(timeTaken)
        let threshold3x3 = gridSize == 3 ? 1.0 : (gridSize == 4 ? 2.0 : 3.0) // 难度系数
        
        if seconds < 30 * threshold3x3 {
            return .purple
        } else if seconds < 60 * threshold3x3 {
            return .blue
        } else if seconds < 120 * threshold3x3 {
            return .green
        } else {
            return .orange
        }
    }
    
    // 根据时间获取表现图标
    private func getPerformanceIcon() -> String {
        let seconds = Double(timeTaken)
        let threshold3x3 = gridSize == 3 ? 1.0 : (gridSize == 4 ? 2.0 : 3.0) // 难度系数
        
        if seconds < 30 * threshold3x3 {
            return "star.fill"
        } else if seconds < 60 * threshold3x3 {
            return "hand.thumbsup.fill"
        } else if seconds < 120 * threshold3x3 {
            return "checkmark.circle.fill"
        } else {
            return "arrow.up.circle.fill"
        }
    }
    
    // 格式化时间
    private func formatTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
    // 根据种子生成随机位置 (0.1-0.9范围内)
    private func getRandomPosition(seed: Int) -> Double {
        let random = Double(((seed * 1234321) % 80) + 10) / 100.0
        return random
    }
}

#Preview {
    NPuzzleResultView(
        timeTaken: 45,
        moveCount: 120,
        gridSize: 3,
        onDismiss: {},
        onRestart: {_ in}
    )
    .environmentObject(GameDataManager())
} 