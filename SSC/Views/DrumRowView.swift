//
//  DrumRowView.swift
//  SSC
//
//  Created by Graciella Michelle Siswoyo on 10/02/26.
//

// HStack
// ForEach(0..<16)
// BeatButtonView(...)

// inputs:
// part: DrumPart
// beats: [BeatSlot]
// isEditable: Bool

// Action:
//if isEditable {
//    game.toggleUserBeat(part: index:)
//}


import SwiftUI

struct DrumRowView: View {
    @EnvironmentObject var game: GameLogic
    
    let part: DrumParts
    let beats: [BeatSlot]
    let currentStep: Int
    let showGlow: Bool
    
    var scale: CGFloat?
    
    private var isEditable: Bool {
        game.gameState == .recreating
    }
    
    private var trackIndex: Int {
        switch part {
        case .hiHat: return 0
        case .snare: return 1
        case .kick: return 2
        }
    }
    
    var body: some View {
//        Text("count: \(beats.count)")
        HStack(spacing: 10) {
            ForEach(0..<beats.count, id: \.self) { index in
                let isActive = beats[index].isActive
                
                BeatButtonView(
                    isActive: isActive,
                    isCurrentStep: showGlow && index == currentStep,
                    action: {
                        if isEditable {
                            game.toggleUserBeat(part: part, index: index)
                        }
                    }
                )
            }
            .frame(width: 56 * (self.scale != nil ? self.scale! : 1), height: 56 * (self.scale != nil ? self.scale! : 1))
        }
    }
}

#Preview {
    let game = GameLogic()
    DrumRowView(
        part: .hiHat,
        beats: game.randomPattern.hiHat,
        currentStep: game.engine.currentStep,
        showGlow: true
    )
        .environmentObject(game)
}
