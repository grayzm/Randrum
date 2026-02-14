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

import SwiftUI

struct RandomPatternView: View {
    @EnvironmentObject var game: GameLogic
    
    private let stepWidth: CGFloat = 56
    private let spacing: CGFloat = 10
    private let scale: CGFloat = 0.8
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 25) {
                HStack {
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: 45, height: 45)
                        .foregroundColor(Color.clear)
                        .padding(.horizontal)
                        .overlay(Image(systemName: "music.pages.fill")
                            .font(Font.largeTitle)
                            .foregroundColor(.white))
                    DrumRowView(
                        part: .hiHat,
                        beats: game.randomPattern.hiHat,
                        currentStep: game.engine.currentStep,
                        showGlow: game.gameState == .listening,
                        scale: scale
                    )
                }
                HStack {
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: 45, height: 45)
                        .foregroundColor(Color.clear)
                        .padding(.horizontal)
                        .overlay(Image(systemName: "music.pages.fill")
                            .font(Font.largeTitle)
                            .foregroundColor(.white))
                    DrumRowView(
                        part: .snare,
                        beats: game.randomPattern.snare,
                        currentStep: game.engine.currentStep,
                        showGlow: game.gameState == .listening,
                        scale: scale
                    )
                }
                HStack {
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: 45, height: 45)
                        .foregroundColor(Color.clear)
                        .padding(.horizontal)
                        .overlay(Image(systemName: "music.pages.fill")
                            .font(Font.largeTitle)
                            .foregroundColor(.white))
                    DrumRowView(
                        part: .kick,
                        beats: game.randomPattern.kick,
                        currentStep: game.engine.currentStep,
                        showGlow: game.gameState == .listening,
                        scale: scale
                    )
                }
            }
            if game.gameState == .listening {
                RoundedRectangle(cornerRadius: 5)
                    .fill(.white.opacity(0.15))
                    .frame(width: stepWidth * scale, height: 160)
                    .offset(x: CGFloat(game.engine.currentStep) * (stepWidth + spacing))
                    .animation(.linear(duration: 0.08), value: game.engine.currentStep)
                    .allowsHitTesting(false)
            }
        }
        .frame(maxWidth: .infinity)
    }
}


#Preview {
    RandomPatternView()
        .environmentObject(GameLogic())
}
