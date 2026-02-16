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
                if game.gameState == .recreating {
                    game.pausePlayback()
                } else {
                    game.startRecreating()
                }
            } label: {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 120, height: 50)
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .padding(.horizontal)
                    .shadow(radius: 10)
                    .overlay(Image(systemName: game.gameState == .recreating ? "pause.fill" : "play.fill"))
                }
        }
    }
}


#Preview {
    WorkspaceControlPanelView()
        .environmentObject(GameLogic())
}
