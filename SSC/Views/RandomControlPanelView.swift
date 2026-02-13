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
        VStack {
            Button {
                game.toggleRandomPlayback()
            } label: {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 120, height: 50)
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .padding()
                    .shadow(radius: 10)
                    .overlay(
                        Image(systemName: game.gameState == .listening
                             ? "pause.fill" : "play.fill")
                    )
                }
            Button {
                game.nextRound()
            } label: {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 120, height: 50)
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
