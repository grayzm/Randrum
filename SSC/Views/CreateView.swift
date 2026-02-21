//
//  CreateView.swift
//  SSC
//
//  Created by Graciella Michelle Siswoyo on 21/02/26.
//

import SwiftUI

struct CreateView: View {
    @EnvironmentObject var game: GameLogic
    var body: some View {
        WorkspaceView()
    }
}

#Preview {
    CreateView()
        .environmentObject(GameLogic())
}
