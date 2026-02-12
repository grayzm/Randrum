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
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    MetronomeTapperView()
        .environmentObject(GameLogic())
}
