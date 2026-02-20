//
//  ControlPanelView.swift
//  SSC
//
//  Created by Graciella Michelle Siswoyo on 10/02/26.
//

// buttons: Play Random, Play User, Replay, Check, Randomize
// all of them calls GameLogic functions.

//Button {
//    game.checkUserPattern()
//} label: {
//    Text("Check")
//}


import SwiftUI

struct WorkspaceControlPanelView: View {
    @EnvironmentObject var game: GameLogic
    
    var body: some View {
        HStack(spacing: 20) {
            ZStack {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color("screen"))
                    .frame(height: 50)
                InstructionView(messageType: .workspace)
                    .padding(.horizontal, 12)
            }
            MetronomeTapperView()
            Button {
                if game.gameState == .recreating {
                    game.pausePlayback()
                } else {
                    game.startRecreating()
                }
            } label: {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color("buttonFill"))
                    .frame(width: 120, height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color("stroke").opacity(0.4), lineWidth: 2)
                    )
                    .padding(.vertical, 5)
                    .overlay(Image(systemName:
                                    game.gameState == .recreating &&
                                   game.engine.isRunning ? "pause.fill" : "play.fill"))
                    .foregroundStyle(Color("text"))
                }
        }
    }
}


#Preview {
    WorkspaceControlPanelView()
        .environmentObject(GameLogic())
}
