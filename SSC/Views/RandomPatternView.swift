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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            DrumRowView(
                part: .hiHat,
                beats: game.randomPattern.hiHat,
            )
            DrumRowView(
                part: .snare,
                beats: game.randomPattern.snare,
            )
            DrumRowView(
                part: .kick,
                beats: game.randomPattern.kick,
            )
        }
    }
}

#Preview {
    RandomPatternView()
        .environmentObject(GameLogic())
}
