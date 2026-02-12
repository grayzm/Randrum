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
            Text("Hello, world!")
                .font(.largeTitle.bold())
            Rectangle()
                .fill(Color.buttonDefault)
                .frame(height: 240)
            HStack(spacing: 30) {
                Rectangle()
                    .fill(Color.buttonDefault)
                    .frame(width: 900)
                VStack(spacing: 30) {
                    Rectangle()
                        .fill(Color.buttonDefault)
                    Rectangle()
                        .fill(Color.buttonDefault)
                    Rectangle()
                        .fill(Color.buttonDefault)
                    Rectangle()
                        .fill(Color.buttonDefault)
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .environmentObject(GameLogic())
}
