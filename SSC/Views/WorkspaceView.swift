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

import SwiftUI

struct WorkspaceView: View {
    @EnvironmentObject var game: GameLogic
    
    private let spacing: CGFloat = 10
    private let padSize: CGFloat = 56
    
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
                StepHeaderView(currentStep: (
                    game.gameState == .recreating ||
                    game.gameState == .checking ||
                    game.gameState == .result) &&
                               game.engine.currentStep >= 0 ? game.engine.currentStep : -1)
            }
            HStack {
                VStack(spacing: 30) {
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: 56, height: 56)
                        .foregroundColor(Color.clear)
                        .padding(.horizontal)
                        .overlay(Image(systemName: "music.pages.fill")
                            .font(Font.largeTitle)
                            .foregroundColor(.white))
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: 56, height: 56)
                        .foregroundColor(Color.clear)
                        .padding(.horizontal)
                        .overlay(Image(systemName: "music.pages.fill")
                            .font(Font.largeTitle)
                            .foregroundColor(.white))
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: 56, height: 56)
                        .foregroundColor(Color.clear)
                        .padding(.horizontal)
                        .overlay(Image(systemName: "music.pages.fill")
                            .font(Font.largeTitle)
                            .foregroundColor(.white))
                }
                ZStack(alignment: .topLeading) {
                    VStack(spacing: 30) {
                        DrumRowView(
                            part: .hiHat,
                            beats: game.userPattern.hiHat,
//                            currentStep: game.engine.currentStep,
                            showGlow: game.gameState == .recreating || game.gameState == .checking || game.gameState == .result,
                            isEditable: true,
                            showsFeedback: true,
                            size: padSize
                        )
                        DrumRowView(
                            part: .snare,
                            beats: game.userPattern.snare,
//                            currentStep: game.engine.currentStep,
                            showGlow: game.gameState == .recreating || game.gameState == .checking || game.gameState == .result,
                            isEditable: true,
                            showsFeedback: true,
                            size: padSize
                        )
                        DrumRowView(
                            part: .kick,
                            beats: game.userPattern.kick,
//                            currentStep: game.engine.currentStep,
                            showGlow: game.gameState == .recreating || game.gameState == .checking || game.gameState == .result,
                            isEditable: true,
                            showsFeedback: true,
                            size: padSize
                        )
                    }
                    if (game.gameState == .recreating ||
                        game.gameState == .checking ||
                        game.gameState == .result) &&
                        game.engine.currentStep >= 0 {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(.white.opacity(0.15))
                            .frame(width: padSize, height: 228)
                            .offset(x: CGFloat(game.engine.currentStep) * (padSize + spacing))
                            .animation(
                                game.engine.currentStep == 0
                                ? nil : .linear(duration: 0.08),
                                value: game.engine.currentStep
                            )
                            .allowsHitTesting(false)
                    }
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
