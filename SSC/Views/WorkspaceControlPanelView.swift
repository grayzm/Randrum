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
        HStack {
            Button {
                game.registerTap()
            } label: {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 100, height: 50)
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .padding()
                    .shadow(radius: 10)
                    .overlay(Image(systemName: "metronome.fill"))
            }
            Button {
                if game.gameState == .recreating {
                    game.pausePlayback()
                } else {
                    game.startRecreating()
                }
            } label: {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 50, height: 50)
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .padding()
                    .shadow(radius: 10)
                    .overlay(Image(systemName: "play.fill"))
                }
            Button {
                game.startChecking()
            } label: {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 100, height: 50)
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .padding()
                    .shadow(radius: 10)
                    .overlay(
                        Image(systemName:
                                game.gameState == .recreating ? "pause.fill" : "checkmark.fill")
                    )
            }
        }
    }
}


#Preview {
    WorkspaceControlPanelView()
        .environmentObject(GameLogic())
}
