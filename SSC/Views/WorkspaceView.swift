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

internal import SwiftUI

struct WorkspaceView: View {
    @EnvironmentObject var game: GameLogic
    @Environment(\.colorScheme) var colorScheme
    
    private let spacing: CGFloat = 10
    private let padSize: CGFloat = 56
    
    var body: some View {
        VStack(spacing: 30) {
            HStack(spacing: 30) {
                Text("Workspace")
                    .font(.custom("DepartureMono-Regular", size: 24))
                Spacer()
                WorkspaceControlPanelView()
            }
            HStack {
                VStack(spacing: 30) {
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: 56, height: 56)
                        .foregroundColor(Color.clear)
                        .overlay(
                            Image(systemName: "metronome.fill")
                                .font(.largeTitle)
                                .foregroundStyle(Color("icon"))
                        )
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: 56, height: 56)
                        .foregroundColor(Color.clear)
                        .overlay(
                            Image(systemName: "music.pages.fill")
                                .font(.largeTitle)
                                .foregroundStyle(Color("icon"))
                        )
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: 56, height: 56)
                        .foregroundColor(Color.clear)
                        .overlay(
                            Image(systemName: "music.pages.fill")
                                .font(.largeTitle)
                                .foregroundStyle(Color("icon"))
                        )
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: 56, height: 56)
                        .foregroundColor(Color.clear)
                        .overlay(
                            Image(systemName: "music.pages.fill")
                                .font(.largeTitle)
                                .foregroundStyle(Color("icon"))
                        )
                }
                
                Spacer()
                
                
                VStack(spacing: 30) {
                    StepHeaderView(currentStep: (
                        game.gameState == .recreating ||
                        game.gameState == .checking ||
                        game.gameState == .result) &&
                                   game.engine.currentStep >= 0 ? game.engine.currentStep : -1)
                    .frame(height: 56)
                    ZStack(alignment: .topLeading) {
                        VStack(spacing: 30) {
                            DrumRowView(
                                part: .hiHat,
                                beats: game.userPattern.hiHat,
                                showGlow: game.gameState == .recreating || game.gameState == .checking || game.gameState == .result,
                                isEditable: true,
                                showsFeedback: true,
                                size: padSize
                            )
                            DrumRowView(
                                part: .snare,
                                beats: game.userPattern.snare,
                                showGlow: game.gameState == .recreating || game.gameState == .checking || game.gameState == .result,
                                isEditable: true,
                                showsFeedback: true,
                                size: padSize
                            )
                            DrumRowView(
                                part: .kick,
                                beats: game.userPattern.kick,
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
                                .fill(.white.opacity(colorScheme == .dark ? 0.15 : 0.3))
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
}

#Preview {
    WorkspaceView()
        .environmentObject(GameLogic())
}
