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
            .frame(minHeight: 200, maxHeight: 264)
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(colors: [Color("background1"), Color("background2")], startPoint: .top, endPoint: .bottom)))
            .padding(.bottom, 10)
            
            VStack {
                WorkspaceView()
            }
            .frame(minHeight: 264, maxHeight: .infinity)
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(colors: [Color("background1"), Color("background2")], startPoint: .top, endPoint: .bottom)))
        }
        .navigationBarTitle("Practice")
        .padding(.horizontal, 10)
    }
}


#Preview {
    ContentView()
        .environmentObject(GameLogic())
}
