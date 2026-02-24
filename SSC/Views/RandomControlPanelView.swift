//
//  RandomControlPanelView.swift
//  SSC
//
//  Created by Graciella Michelle Siswoyo on 12/02/26.
//

internal import SwiftUI

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
                              ? "stop.fill" : "play.fill")
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
                        .font(.title3)
//                        .font(.custom("DepartureMono-Regular", size: 16))
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
                        .font(.title3)
//                        .font(.custom("DepartureMono-Regular", size: 16))
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
