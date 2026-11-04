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
            Spacer()
            RandomPatternView()
                .frame(minHeight: 200, maxHeight: 320)
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(colors: [Color("background1"), Color("background2")], startPoint: .top, endPoint: .bottom)))
                .padding(.bottom, 10)
            
            WorkspaceView()
                .frame(minHeight: 264, maxHeight: 360)
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(colors: [Color("background1"), Color("background2")], startPoint: .top, endPoint: .bottom))
                )
            
            Spacer()
        }
//        .navigationBarTitle("Practice")
        .padding(16)
        .ignoresSafeArea()
//        .background(.blue)
    }
}


#Preview {
    ContentView()
        .environmentObject(GameLogic())
}
