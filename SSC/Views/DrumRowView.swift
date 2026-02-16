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
    let isEditable: Bool
    
    var size: CGFloat?
    
    private var trackIndex: Int {
        switch part {
        case .hiHat: return 0
        case .snare: return 1
        case .kick: return 2
        }
    }
    
    private var feedbackArray: [BeatFeedback]? {
        print("feedbackArray called - gameState: \(game.gameState)")
        // only compute feedback when we're actually showing results and not animating
        guard game.gameState == .result,
              let result = game.lastCheckResult else {
            print("returning nil - state: \(game.gameState), has Result: \(game.lastCheckResult != nil)")
            return nil
        }
        print("returning feedback for \(part)")
        
        switch part {
        case .hiHat: return result.hiHatFeedback
        case .snare: return result.snareFeedback
        case .kick: return result.kickFeedback
        }
    }
    
    var body: some View {
//        Text("count: \(beats.count)")
        HStack(spacing: 10) {
            ForEach(0..<beats.count, id: \.self) { index in
                let isActive = beats[index].isActive
                let currentFeedback: BeatFeedback? = feedbackArray?[index]
                
                BeatButtonView(
                    isActive: isActive,
                    isCurrentStep: showGlow && index == currentStep,
                    feedback: currentFeedback,
                    action: isEditable ? {
                        game.toggleUserBeat(part: part, index: index)
                    } : nil
                )
                .frame(width: size, height: size)
            }
        }
    }
}

#Preview {
    let game = GameLogic()
    DrumRowView(
        part: .hiHat,
        beats: game.randomPattern.hiHat,
        currentStep: game.engine.currentStep,
        showGlow: true,
        isEditable: true,
        size: 56
    )
        .environmentObject(game)
}
