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
                    .fill(Color("buttonFill"))
                    .frame(width: 120, height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color("stroke").opacity(0.4), lineWidth: 2)
                    )
                    .padding(.vertical, 5)
                    .overlay(
                        Image(systemName: game.gameState == .listening
                              ? "pause.fill" : "play.fill")
                        .foregroundStyle(Color("text"))
                    )
            }
            
            
            Button {
                game.nextRound()
            } label: {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color("buttonFill"))
                    .frame(width: 120, height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color("stroke").opacity(0.4), lineWidth: 2)
                    )
                    .padding(.vertical, 5)
                    .overlay(Text("Randrumize")
                        .font(.custom("DepartureMono-Regular", size: 16))
//                        .font(.headline)
                        .foregroundStyle(Color("text"))
                    )
            }
            Button {
                game.startChecking()
            } label: {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color("buttonFill"))
                    .frame(width: 120, height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color("stroke").opacity(0.4), lineWidth: 2)
                    )
                    .padding(.vertical, 5)
                    .overlay(Text("Check")
                        .font(.custom("DepartureMono-Regular", size: 16))
//                        .font(.headline)
                        .foregroundStyle(Color("text"))
                    )
            }
        }
    }
}

#Preview {
    RandomControlPanelView()
        .environmentObject(GameLogic())
}
