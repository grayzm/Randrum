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

import SwiftUI

struct MetronomeTapperView: View {
    @EnvironmentObject var game: GameLogic
    
    var body: some View {
        HStack(spacing: 40) {
            VStack(spacing: 5) {
                Text("\(Int(game.userPattern.bpm))")
                    .font(.system(size: 32).bold())
                    .foregroundColor(.white)
                Text("BPM")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.7))
            }
            Button {
                game.registerTap()
            } label: {
                VStack(spacing: 10) {
                    Image(systemName: "metronome.fill")
                        .font(.system(size: 24))
                    Text("Tap")
                        .font(.default)
                }
                .foregroundColor(.white)
                .frame(width: 75, height: 75)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white.opacity(0.2))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.white.opacity(0.4), lineWidth: 2)
                )
            }
            .buttonStyle(.plain)
//            Text("Tap to set tempo")
//                .font(.caption)
//                .foregroundColor(.white.opacity(0.5))
        }
        .padding()
    }
}

#Preview {
    MetronomeTapperView()
        .environmentObject(GameLogic())
}
