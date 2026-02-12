//
//  RandomControlPanelView.swift
//  SSC
//
//  Created by Graciella Michelle Siswoyo on 12/02/26.
//

import SwiftUI

struct RandomControlPanelView: View {
    @EnvironmentObject var game: GameLogic
    
    var body: some View {
        HStack {
            Button {
                if game.isPlayingUser {
                    game.pausePlayback()
                } else {
                    game.playUserPattern()
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
                game.playRandomPattern()
            } label: {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 150, height: 50)
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .padding()
                    .shadow(radius: 10)
                    .overlay(Text("Randrumize"))
            }
        }
    }
}

#Preview {
    RandomControlPanelView()
        .environmentObject(GameLogic())
}
