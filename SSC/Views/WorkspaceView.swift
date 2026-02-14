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
    
    private let stepWidth: CGFloat = 56
    private let spacing: CGFloat = 10
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            HStack {
                RoundedRectangle(cornerRadius: 5)
                    .frame(width: 56, height: 56)
                    .foregroundColor(Color.clear)
                    .padding(.horizontal)
                    .overlay(Image(systemName: "metronome.fill")
                        .font(Font.title)
                        .foregroundColor(.white))
                StepHeaderView(currentStep: game.gameState == .recreating ? game.engine.currentStep : -1)
            }
            
            ZStack(alignment: .topLeading) {
                
                //            ZStack(alignment: .topLeading) {
                VStack(spacing: 30) {
                    HStack {
                        RoundedRectangle(cornerRadius: 5)
                            .frame(width: 56, height: 56)
                            .foregroundColor(Color.clear)
                            .padding(.horizontal)
                            .overlay(Image(systemName: "music.pages.fill")
                                .font(Font.largeTitle)
                                .foregroundColor(.white))
                        DrumRowView(
                            part: .hiHat,
                            beats: game.userPattern.hiHat,
                            currentStep: game.engine.currentStep,
                            showGlow: game.gameState == .recreating
                        )
                    }
                    HStack {                        RoundedRectangle(cornerRadius: 5)
                            .frame(width: 56, height: 56)
                            .foregroundColor(Color.clear)
                            .padding(.horizontal)
                            .overlay(Image(systemName: "music.pages.fill")
                                .font(Font.largeTitle)
                                .foregroundColor(.white))
                        DrumRowView(
                            part: .snare,
                            beats: game.userPattern.snare,
                            currentStep: game.engine.currentStep,
                            showGlow: game.gameState == .recreating
                        )
                    }
                    HStack {
                        RoundedRectangle(cornerRadius: 5)
                            .frame(width: 55, height: 55)
                            .foregroundColor(Color.clear)
                            .padding(.horizontal)
                            .overlay(Image(systemName: "music.pages.fill")
                                .font(Font.largeTitle)
                                .foregroundColor(.white))
                        DrumRowView(
                            part: .kick,
                            beats: game.userPattern.kick,
                            currentStep: game.engine.currentStep,
                            showGlow: game.gameState == .recreating
                        )
                    }
                }
                
                if game.gameState == .recreating {
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
}


#Preview {
    WorkspaceView()
        .environmentObject(GameLogic())
}
//RoundedRectangle(cornerRadius: 5)
//    .frame(width: 55, height: 55)
//    .foregroundColor(Color("default"))
//    .font(.largeTitle)
//    .padding()
//    .shadow(radius: 10)
//    .overlay(Image(systemName: "music.pages.fill")
//        .font(Font.title)
//        .foregroundColor(.white))
