//
//  WorkspaceView.swift
//  SSC
//
//  Created by Graciella Michelle Siswoyo on 10/02/26.
//

// each button calls:
// game.toggleUserBeat(part: index: )

// it reads:
// game.userPattern

// tap -> WorkSpaceView -> GameLogic -> updates userPattern -> UI refreshes

//PatternGridView(
//    pattern: game.userPattern,
//    isEditable: true
//)

// Vstack
// DrumRowView(.hiHat)
// DrumRowView(.snare)
// DrumRowView(.kick)

// Props:
// pattern: DrumPattern
// isEditable: Bool



import SwiftUI

struct WorkspaceView: View {
    @EnvironmentObject var game: GameLogic
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            DrumRowView(
                part: .hiHat,
                beats: game.userPattern.hiHat,
                isEditable: true
            )
            DrumRowView(
                part: .snare,
                beats: game.userPattern.snare,
                isEditable: true
            )
            DrumRowView(
                part: .kick,
                beats: game.userPattern.kick,
                isEditable: true
            )
        }
    }
}

#Preview {
    WorkspaceView()
        .environmentObject(GameLogic())
}
