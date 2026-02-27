//
//  DrumRowView.swift
//  SSC
//
//  Created by Graciella Michelle Siswoyo on 10/02/26.
//

internal import SwiftUI

// shared layout constants for consistent spacing
struct DrumGridLayout {
    static let buttonSpacing: CGFloat = 16
    static let stepCount: Int = 16
    
    // calculate button size given available width
    static func buttonSize(for width: CGFloat) -> CGFloat {
        let totalSpacing = CGFloat(stepCount - 1) * buttonSpacing
        return (width - totalSpacing) / CGFloat(stepCount)
    }
}

struct DrumRowView: View {
    @EnvironmentObject var game: GameLogic
    
    let part: DrumParts
    let beats: [BeatSlot]
    let showGlow: Bool
    let isEditable: Bool
    let showsFeedback: Bool
    
    private var trackIndex: Int {
        switch part {
        case .hiHat: return 0
        case .snare: return 1
        case .kick: return 2
        }
    }
    
    private var feedbackArray: [BeatFeedback]? {
        // return feedback during checking and result states
        guard showsFeedback,
              (game.gameState == .checking || game.gameState == .result),
              let result = game.lastCheckResult else {
            
            return nil
        }
        
        switch part {
        case .hiHat: return result.hiHatFeedback
        case .snare: return result.snareFeedback
        case .kick: return result.kickFeedback
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            let buttonSize = DrumGridLayout.buttonSize(for: geo.size.width)
            HStack(spacing: DrumGridLayout.buttonSpacing) {
                ForEach(0..<beats.count, id: \.self) { index in
                    let isActive = beats[index].isActive
                    let currentFeedback: BeatFeedback? = {
                        guard let array = feedbackArray, index < array.count else {
                            return nil
                        }
                        return array[index]
                    }()
                    // during .checking: pass currentStep to pregressively reveal
                    // during .result: pass nil to show all feedback
                    let revealUpTo = game.gameState == .checking ? game.engine.currentStep : nil
                    
                    BeatButtonView(
                        isActive: isActive,
                        isCurrentStep: showGlow && index == game.engine.currentStep,
                        feedback: currentFeedback,
                        index: index,
                        revealUpToStep: revealUpTo,
                        action: isEditable ? {
                            game.toggleUserBeat(part: part, index: index)
                        } : nil
                    )
                    //                .aspectRatio(1, contentMode: .fit)
                    .frame(width: buttonSize, height: buttonSize)
                    .anchorPreference(
                        key: StepFramePreferenceKey.self,
                        value: .bounds
                    ) { anchor in
                        [index: anchor]
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }
}

#Preview {
    let game = GameLogic()
    DrumRowView(
        part: .hiHat,
        beats: game.randomPattern.hiHat,
        showGlow: true,
        isEditable: true,
        showsFeedback: true,
    )
    .environmentObject(game)
}
