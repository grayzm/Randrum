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
    
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 30) {
                Text("Workspace")
                    .font(.title.weight(.semibold))
                WorkspaceControlPanelView()
            }
            
            VStack(spacing: 8) {
                // HEADER GRID
                Grid(horizontalSpacing: 30) {
                    GridRow {
                        RoundedRectangle(cornerRadius: 5)
                            .aspectRatio(1, contentMode: .fit)
                            .frame(minWidth: 50, maxHeight: 70)
                            .foregroundColor(Color.clear)
                        StepHeaderView(currentStep: (
                            game.gameState == .recreating ||
                            game.gameState == .checking ||
                            game.gameState == .result) &&
                                       game.engine.currentStep >= 0 ? game.engine.currentStep : -1)
                    }
                }
                
                // DRUM SECTION
                Grid(horizontalSpacing: 30, verticalSpacing: 30) {
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
                        )
                    }
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
                        )
                    }
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
                        )
                    }
                }
                // PLAYHEAD
                .overlayPreferenceValue(StepFramePreferenceKey.self) { values in
                    GeometryReader { geo in
                        if (game.gameState == .recreating ||
                            game.gameState == .checking ||
                            game.gameState == .result),
                           game.engine.currentStep >= 0,
                           let anchor = values[game.engine.currentStep] {
                            
                            let frame = geo[anchor]
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.white.opacity(0.15))
                                .frame(width: frame.width, height: geo.size.height)
                                .offset(x: frame.minX)
                                .animation(.linear(duration: 0.08),
                                           value: game.engine.currentStep)
                                .allowsTightening(false)
                        }
                    }
                }
            }
        }
    }
}


struct StepFramePreferenceKey: PreferenceKey {
    static var defaultValue: [Int: Anchor<CGRect>] = [:]
    static func reduce(
        value: inout [Int: Anchor<CGRect>],
        nextValue: () -> [Int: Anchor<CGRect>]
    ) {
        value.merge(nextValue()) { $1 }
    }
}

#Preview {
    WorkspaceView()
        .environmentObject(GameLogic())
}
