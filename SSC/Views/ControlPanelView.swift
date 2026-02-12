//
//  ControlPanelView.swift
//  SSC
//
//  Created by Graciella Michelle Siswoyo on 10/02/26.
//

// buttons: Play Random, Play User, Replay, Check, Randomize
// all of them calls GameLogic functions.

//Button {
//    game.checkUserPattern()
//} label: {
//    Text("Check")
//}


import SwiftUI

struct ControlPanelView: View {
    @EnvironmentObject var game: GameLogic
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    ControlPanelView()
        .environmentObject(GameLogic())
}
