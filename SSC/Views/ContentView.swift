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
        VStack(spacing: 30) {
            Text("Randrum")
                .font(.largeTitle.bold())
            HStack(spacing: 30) {
                RandomPatternView()
                    .frame(width: 1000, height: 250)

                VStack(spacing: 30) {
                    ForEach(0..<3) { _ in
                        Circle()
                            .fill(Color.buttonDefault)
                            .frame(height: 70)
                    }
                }
            }
            WorkspaceControlPanelView()
                .frame(height: 100)
                WorkspaceView()
                    .frame(height: 280)
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .environmentObject(GameLogic())
}
