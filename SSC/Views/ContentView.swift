//
//  ContentView.swift
//  SSC
//
//  Created by Graciella Michelle Siswoyo on 08/02/26.
//

// holds @EnvironmentObject var game


import SwiftUI

struct ContentView: View {
    @EnvironmentObject var game: GameLogic
    
    var body: some View {
        VStack {
            Text("Randrum")
                .font(.largeTitle.bold())
            
            HStack(spacing: 30) {
                RandomPatternView()
                
                RandomControlPanelView()
            }
            Spacer()
            
            HStack{
                Text("Workspace")
                    .font(.largeTitle.bold())
                Spacer()
                WorkspaceControlPanelView()
                MetronomeTapperView()
                
            }
                WorkspaceView()
        }
        .padding(.horizontal, 40)
    }
}

#Preview {
    ContentView()
        .environmentObject(GameLogic())
}
