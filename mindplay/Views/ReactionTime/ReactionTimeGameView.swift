//
//  ReactionTimeGameView.swift
//  mindplay
//
//  Created for MindPlay app.
//

import SwiftUI

enum GameState {
    case waiting      // Waiting to start the test
    case ready        // Ready to start, showing red screen
    case go           // Screen has turned green, waiting for tap
    case tooEarly     // User tapped too early
    case result       // Showing result for this round
    case finished     // All rounds completed
}

struct ReactionTimeGameView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var gameDataManager: GameDataManager
    
    @State private var gameState: GameState = .waiting
    @State private var startTime: Date? = nil
    @State private var reactionTime: Double? = nil
    @State private var roundTimes: [Double] = []
    @State private var currentRound: Int = 1
    @State private var waitTime: Double = 0
    
    private let totalRounds = 5
    private let minWaitTime = 1.5  // Minimum wait time in seconds
    private let maxWaitTime = 4.0  // Maximum wait time in seconds
    
    var body: some View {
        ZStack {
            // Background color based on game state
            backgroundColor
                .ignoresSafeArea()
                .onTapGesture {
                    handleTap()
                }
            
            VStack {
                // Game content based on state
                switch gameState {
                case .waiting:
                    waitingContent
                case .ready:
                    readyContent
                case .go:
                    goContent
                case .tooEarly:
                    tooEarlyContent
                case .result:
                    resultContent
                case .finished:
                    // This is handled by a sheet presentation
                    EmptyView()
                }
            }
            .padding()
        }
        .onAppear {
            startGame()
        }
        .fullScreenCover(isPresented: Binding<Bool>(
            get: { gameState == .finished },
            set: { if !$0 { gameState = .waiting } }
        )) {
            ReactionTimeResultView(reactionTimes: roundTimes, onDismiss: { self.dismiss() })
        }
    }
    
    // Background color based on game state
    private var backgroundColor: Color {
        switch gameState {
        case .waiting, .result:
            return Color(.systemBackground)
        case .ready:
            return Color.red
        case .go:
            return Color.green
        case .tooEarly:
            return Color.orange
        case .finished:
            return Color(.systemBackground)
        }
    }
    
    // MARK: - Content Views for Different Game States
    
    private var waitingContent: some View {
        VStack(spacing: 24) {
            Text("Get Ready")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Tap the screen when it turns green")
                .font(.title3)
                .multilineTextAlignment(.center)
            
            Button(action: {
                startRound()
            }) {
                Text("Tap to Start Round \(currentRound) of \(totalRounds)")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 5)
        .padding()
    }
    
    private var readyContent: some View {
        VStack {
            Text("Wait...")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
    
    private var goContent: some View {
        VStack {
            Text("TAP NOW!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
    
    private var tooEarlyContent: some View {
        VStack(spacing: 24) {
            Text("Too Early!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("You tapped before the screen turned green. Let's try again.")
                .font(.title3)
                .multilineTextAlignment(.center)
            
            Button(action: {
                startRound()
            }) {
                Text("Try Again")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 5)
        .padding()
    }
    
    private var resultContent: some View {
        VStack(spacing: 24) {
            if let reactionTime = reactionTime {
                Text(String(format: "%.0f ms", reactionTime))
                    .font(.system(size: 64, weight: .bold))
                    .foregroundColor(.blue)
                
                Text("Your reaction time")
                    .font(.title3)
            }
            
            Text("Round \(currentRound) of \(totalRounds) completed")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Button(action: {
                if currentRound < totalRounds {
                    currentRound += 1
                    gameState = .waiting
                } else {
                    gameState = .finished
                    // Save the average score
                    let averageTime = roundTimes.reduce(0, +) / Double(roundTimes.count)
                    gameDataManager.saveResult(gameType: .reactionTime, score: averageTime)
                }
            }) {
                Text(currentRound < totalRounds ? "Next Round" : "See Results")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 5)
        .padding()
    }
    
    // MARK: - Game Logic
    
    private func startGame() {
        roundTimes = []
        currentRound = 1
        gameState = .waiting
    }
    
    private func startRound() {
        gameState = .ready
        
        // Random wait time between min and max
        waitTime = Double.random(in: minWaitTime...maxWaitTime)
        
        // Schedule the screen to turn green after the wait time
        DispatchQueue.main.asyncAfter(deadline: .now() + waitTime) {
            // Only proceed if we're still in the ready state
            if gameState == .ready {
                gameState = .go
                startTime = Date()
            }
        }
    }
    
    private func handleTap() {
        switch gameState {
        case .waiting:
            // Start the round when tapped in waiting state
            startRound()
            
        case .ready:
            // Tapped too early
            gameState = .tooEarly
            
        case .go:
            // Calculate reaction time
            if let startTime = startTime {
                let endTime = Date()
                let timeInterval = endTime.timeIntervalSince(startTime) * 1000 // Convert to milliseconds
                reactionTime = timeInterval
                roundTimes.append(timeInterval)
                gameState = .result
            }
            
        case .tooEarly, .result:
            // These states have their own buttons for navigation
            break
            
        case .finished:
            // Should be handled by the sheet presentation
            break
        }
    }
}

#Preview {
    ReactionTimeGameView()
        .environmentObject(GameDataManager())
}
