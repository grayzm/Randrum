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


internal import SwiftUI

struct WorkspaceControlPanelView: View {
    @EnvironmentObject var game: GameLogic
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color("screen"))
                    .stroke(Color("shadow"), lineWidth: 2)
                    .frame(maxHeight: 40)
                InstructionView(messageType: .workspace)
            }
            MetronomeTapperView()
            Button {
                if game.gameState == .recreating {
                    game.stopPlayback()
                } else {
                    game.startRecreating()
                }
            } label: {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color("buttonFill"))
                    .frame(maxWidth: 96, maxHeight: 40)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color("stroke").opacity(0.4), lineWidth: 2)
                    )
                    .overlay(Image(systemName:
                                    game.gameState == .recreating &&
                                   game.engine.isRunning ? "stop.fill" : "play.fill"))
                    .font(.title3)
                    .foregroundStyle(Color("text"))
                }
        }
    }
}


#Preview {
    WorkspaceControlPanelView()
        .environmentObject(GameLogic())
}
