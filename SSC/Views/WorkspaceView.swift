//
//  WorkspaceView.swift
//  SSC
//
//  Created by Graciella Michelle Siswoyo on 10/02/26.
//

// each button calls:
// game.toggleUserBeat(part: index: )

// it reads:
// game.userPattern

// tap -> WorkSpaceView -> GameLogic -> updates userPattern -> UI refreshes

//PatternGridView(
//    pattern: game.userPattern,
//    isEditable: true
//)

// Vstack
// DrumRowView(.hiHat)
// DrumRowView(.snare)
// DrumRowView(.kick)

// Props:
// pattern: DrumPattern
// isEditable: Bool



import SwiftUI

struct WorkspaceView: View {
    @EnvironmentObject var game: GameLogic
    
    private let stepWidth: CGFloat = 60
    private let spacing: CGFloat = 10
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            
            StepHeaderView(currentStep: game.engine.currentStep)
            
            ZStack(alignment: .topLeading) {
                VStack{
                    DrumRowView(
                        part: .hiHat,
                        beats: game.userPattern.hiHat,
                        currentStep: game.engine.currentStep
                    )
                    DrumRowView(
                        part: .snare,
                        beats: game.userPattern.snare,
                        currentStep: game.engine.currentStep
                    )
                    DrumRowView(
                        part: .kick,
                        beats: game.userPattern.kick,
                        currentStep: game.engine.currentStep
                    )
                }
                RoundedRectangle(cornerRadius: 5)
                    .fill(.white.opacity(0.15))
                    .frame(width: stepWidth, height: 200)
                    .offset(x: CGFloat(game.engine.currentStep) * (stepWidth + spacing))
                    .animation(.linear(duration: 0.08), value: game.engine.currentStep)
                    .allowsHitTesting(false)
            }
        }
    }
}

#Preview {
    WorkspaceView()
        .environmentObject(GameLogic())
}
