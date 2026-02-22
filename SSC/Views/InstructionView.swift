//
//  InstructionView.swift
//  SSC
//
//  Created by Graciella Michelle Siswoyo on 20/02/26.
//

internal import SwiftUI

enum MessageType {
    case random
    case workspace
}

struct InstructionView: View {
    @EnvironmentObject var game: GameLogic
    let messageType: MessageType
    
    var message: String {
        switch messageType {
        case .random:
            return game.randomMessage
        case .workspace:
            return game.workspaceMessage
        }
    }
    
    var body: some View {
        if !message.isEmpty {
            Text(message)
                .font(.custom("DepartureMono-Regular", size: 20))
                .foregroundStyle(Color("stroke"))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .transition(.opacity)
//                .animation(.easeInOut(duration: 0.3), value: game.dialogueMessages)
        } else {
            // empty state - maintain space
            Text("")
                .font(.custom("DepartureMono-Regular", size: 13))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    InstructionView(messageType: .workspace)
        .environmentObject(GameLogic())
}
