//
//  ContentView.swift
//  SSC
//
//  Created by Graciella Michelle Siswoyo on 08/02/26.
//

// holds @EnvironmentObject var game


internal import SwiftUI

struct ContentView: View {
    @EnvironmentObject var game: GameLogic
    
    var body: some View {
        VStack {
            VStack {
                RandomPatternView()
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(colors: [Color("background1"), Color("background2")], startPoint: .top, endPoint: .bottom)))
            
            Spacer()
            
            VStack {
                WorkspaceView()
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(colors: [Color("background1"), Color("background2")], startPoint: .top, endPoint: .bottom)))
        }
//        .padding(.horizontal, 10)
    }
}


#Preview {
    ContentView()
        .environmentObject(GameLogic())
}
