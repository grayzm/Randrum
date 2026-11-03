//
//  MetronomeTapperView.swift
//  SSC
//
//  Created by Graciella Michelle Siswoyo on 10/02/26.
//

// button for tapping
// BPM display

// sends:
// game.registerTap()

// reads:
// game.userPattern.bpm

internal import SwiftUI

struct MetronomeTapperView: View {
    @EnvironmentObject var game: GameLogic
    
    var body: some View {
        HStack(spacing: 12) {
            HStack() {
                Text("\(Int(game.userPattern.bpm))")
                    .font(.custom("DepartureMono-Regular", size: 20))
                    .foregroundStyle(Color("stroke"))
                Text("BPM")
                    .font(.custom("DepartureMono-Regular", size: 16))
//                    .font(.subheadline)
                    .foregroundStyle(Color("stroke"))
            }
            .frame(maxWidth: 120, maxHeight: 40)
            .background(
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color("screen"))
                    .stroke(Color("shadow"), lineWidth: 2)
            )
            
            Button {
                game.registerTap()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "metronome.fill")
                        .font(.title3)
                    Text("Tap")
                        .font(.subheadline)
                }
                .foregroundStyle(Color("text"))
                .frame(maxWidth: 96, maxHeight: 40)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color("buttonFill"))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color("stroke").opacity(0.4), lineWidth: 2)
                )
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    MetronomeTapperView()
        .environmentObject(GameLogic())
}
