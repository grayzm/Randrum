//
//  WorkspaceView.swift
//  SSC
//
//  Created by Graciella Michelle Siswoyo on 10/02/26.
//

internal import SwiftUI

struct WorkspaceView: View {
    @EnvironmentObject var game: GameLogic
    @Environment(\.colorScheme) var colorScheme
    
    private let spacing: CGFloat = 14
    private let padSize: CGFloat = 50
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 30) {
                Text("Workspace")
                    .font(.title.weight(.semibold))
                WorkspaceControlPanelView()
            }
            
            ZStack {
                Grid(horizontalSpacing: 30, verticalSpacing: 30) {
                    
                    // ----------------- STEP HEADER -----------------
                    GridRow {
                        RoundedRectangle(cornerRadius: 5)
                            .aspectRatio(1, contentMode: .fit)
                            .frame(minWidth: 50, maxHeight: 70)
                            .foregroundColor(Color.blue.opacity(0.1))
                        StepHeaderView(currentStep: (
                            game.gameState == .recreating ||
                            game.gameState == .checking ||
                            game.gameState == .result) &&
                                       game.engine.currentStep >= 0 ? game.engine.currentStep : -1)
                        //                    .frame(height: 50)
                    }
//                    .padding(.bottom, -10)
//                    .gridCellUnsizedAxes(.horizontal)
                    
                    // ----------------- DRUM PADS -----------------
                    GridRow {
                        Image("hihat")
                            .resizable()
                            .scaledToFit()
                            .frame(minWidth: 50, maxHeight: 70)
                        DrumRowView(
                            part: .hiHat,
                            beats: game.userPattern.hiHat,
                            showGlow: game.gameState == .recreating || game.gameState == .checking || game.gameState == .result,
                            isEditable: true,
                            showsFeedback: true,
                            //                                size: padSize
                        )
                    }
//                    .gridCellUnsizedAxes(.horizontal)
                    GridRow {
                        Image("snare")
                            .resizable()
                            .scaledToFit()
                            .frame(minWidth: 50, maxHeight: 70)
                        DrumRowView(
                            part: .snare,
                            beats: game.userPattern.snare,
                            showGlow: game.gameState == .recreating || game.gameState == .checking || game.gameState == .result,
                            isEditable: true,
                            showsFeedback: true,
                            //                                size: padSize
                        )
                    }
//                    .gridCellUnsizedAxes(.horizontal)
                    GridRow {
                        Image("kick")
                            .resizable()
                            .scaledToFit()
                            .frame(minWidth: 50, maxHeight: 70)
                        DrumRowView(
                            part: .kick,
                            beats: game.userPattern.kick,
                            showGlow: game.gameState == .recreating || game.gameState == .checking || game.gameState == .result,
                            isEditable: true,
                            showsFeedback: true,
                            //                                size: padSize
                        )
                    }
//                    .gridCellUnsizedAxes(.horizontal)
                }
                
                // ----------------- SLIDER -----------------
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

#Preview {
    WorkspaceView()
        .environmentObject(GameLogic())
}
