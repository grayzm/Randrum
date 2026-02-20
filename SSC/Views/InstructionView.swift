//
//  InstructionView.swift
//  SSC
//
//  Created by Graciella Michelle Siswoyo on 20/02/26.
//

import SwiftUI

struct InstructionView: View {
    @EnvironmentObject var game: GameLogic
    var body: some View {
//        if !game.dialogueMessages.isEmpty && game.currentDialogueIndex < game.dialogueMessages.count {
    }
}

#Preview {
    InstructionView()
        .environmentObject(GameLogic())
}
