//
//  RandomPatternView.swift
//  SSC
//
//  Created by Graciella Michelle Siswoyo on 10/02/26.
//

// it reads:
// game.randomPattern
// game.revealPattern

// sound wave + answer grid
// overland logic
// .opacity(game.revealPattern ? 1 : 0)

// ZStack
// PatternGridView(pattern: game.randomPattern. isEditable: false)
// WaveOverlay(opacity: game.revealPattern ? 0 : 1)

internal import SwiftUI

struct RandomPatternView: View {
    @EnvironmentObject var game: GameLogic
    @Environment(\.colorScheme) var colorScheme
    
    private let spacing: CGFloat = 14
    private let padSize: CGFloat = 42
    
    // random flicker state: 3 rows x 16 buttons
    @State private var flickerState: [[Bool]] = Array(
        repeating: Array(repeating: false, count: 16),
        count: 3
    )
    @State private var flickerTimer: Timer? = nil
    
    // what to actually display per row
    private func displayBeats(for row: Int, real: [BeatSlot]) -> [BeatSlot] {
        switch game.gameState {
        case .checking, .result:
            return real // reveal actual pattern
        case .listening:
            if game.hasChecked {
                return real // show real pattern after check
            }
            return flickerState[row].map { BeatSlot(isActive: $0) }
        default:
            return Array(repeating: BeatSlot(isActive: false), count: 16)
        }
    }
    
    var body: some View {
        VStack(spacing: 30) {
            //            HStack(spacing: 30) {
            //                Text("Randrum")
            //                    .font(.custom("DepartureMono-Regular", size: 24))
            //                Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color("screen"))
                    .stroke(Color("shadow"), lineWidth: 2)
                    .frame(height: 50)
                InstructionView(messageType: .random)
                    .padding(.horizontal, 12)
            }
            //            }
            HStack(spacing: 20) {
                Grid(horizontalSpacing: 30, verticalSpacing: 10) {
                    GridRow {
                        Image("hihat")
                            .resizable()
                            .scaledToFit()
                            .frame(minWidth: 40, maxHeight: 50)
                        DrumRowView(
                            part: .hiHat,
                            beats: displayBeats(for: 0, real: game.randomPattern.hiHat),
                            showGlow: game.gameState == .listening,
                            isEditable: false,
                            showsFeedback: false,
                            //                            size: padSize
                        )
                    }
                    GridRow {
                        Image("snare")
                            .resizable()
                            .scaledToFit()
                            .frame(minWidth: 40, maxHeight: 50)
                        DrumRowView(
                            part: .snare,
                            beats: displayBeats(for: 1, real: game.randomPattern.snare),
                            showGlow: game.gameState == .listening,
                            isEditable: false,
                            showsFeedback: false,
                            //                            size: padSize
                        )
                    }
                    GridRow {
                        Image("kick")
                            .resizable()
                            .scaledToFit()
                            .frame(minWidth: 40, maxHeight: 50)
                        DrumRowView(
                            part: .kick,
                            beats: displayBeats(for: 2, real: game.randomPattern.kick),
                            showGlow: game.gameState == .listening,
                            isEditable: false,
                            showsFeedback: false,
                            //                            size: padSize
                        )
                    }
                }
                
                ZStack(alignment: .topLeading) {
                    VStack(alignment: .leading, spacing: 25) {
                        
                        
                        
                    }
                    if game.gameState == .listening &&
                        game.engine.currentStep == 0 {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(.white.opacity(colorScheme == .dark ? 0.15 : 0.45))
                            .frame(width: padSize, height: 185)
                            .allowsHitTesting(false)
                    }
                }
                //                .frame(maxWidth: .infinity)
                RandomControlPanelView()
                    .padding(.leading, 8)
            }
            .onChange(of: game.gameState) { _, newState in
                if newState == .listening {
                    if game.hasChecked {
                        stopFlicker()
                    } else {
                        startFlicker()
                    }
                } else if newState == .checking || newState == .result {
                    game.hasChecked = true
                    stopFlicker()
                } else if newState == .idle {
                    game.hasChecked = false
                    stopFlicker()
                }
            }
        }
    }
    
    private func startFlicker() {
        guard !game.hasChecked else { return }
        randomizeFlicker()
        // lower number = more flickering
        flickerTimer = Timer.scheduledTimer(withTimeInterval: 0.18, repeats: true) { _ in
            randomizeFlicker()
        }
    }
    
    private func stopFlicker() {
        flickerTimer?.invalidate()
        flickerTimer = nil
    }
    
    private func randomizeFlicker() {
        for row in 0..<3 {
            for col in 0..<16 {
                // how many buttons update each tick (higher number = more chaotic)
                if Double.random(in: 0...1) < 0.7 {
                    // how likely a button is on vs off (lower = more sparse)
                    flickerState[row][col] = Double.random(in: 0...1) < 0.2
                }
            }
        }
    }
}
    


#Preview {
    RandomPatternView()
        .environmentObject(GameLogic())
}
