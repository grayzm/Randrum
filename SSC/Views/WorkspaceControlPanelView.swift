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
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        Color("screen")
                            .shadow(.inner(color: .black.opacity(colorScheme == .dark ? 0.7 : 0.3), radius: 4))
                    )
                    .stroke(Color("shadow"), lineWidth: 1.5)
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
