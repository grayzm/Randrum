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
            VStack(alignment: .leading) {
                HStack(spacing: 30) {
                    Text("Randrum")
                        .font(.custom("DepartureMono-Regular", size: 24))
//                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                    ZStack {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color("screen"))
                            .frame(height: 50)
                        InstructionView(messageType: .random)
                            .padding(.horizontal, 12)
                    }
                    Button {
                        
                    } label: {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 32))
                            .foregroundStyle(Color("text").opacity(0.4))
                    }
                }
                    .padding(.bottom)
                HStack(spacing: 30) {
                    RandomPatternView()
                    RandomControlPanelView()
                }
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(colors: [Color("background1"), Color("background2")], startPoint: .top, endPoint: .bottom)
                    )
            )
            
            Spacer()
            
            VStack {
                HStack(spacing: 30) {
                    Text("Workspace")
                        .font(.custom("DepartureMono-Regular", size: 24))
                    Spacer()
//                    MetronomeTapperView()
                    WorkspaceControlPanelView()
                }
                WorkspaceView()
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(colors: [Color("background1"), Color("background2")], startPoint: .top, endPoint: .bottom)
                    )
            )
        }
        .padding(.horizontal, 10)
    }
}

#Preview {
    ContentView()
        .environmentObject(GameLogic())
}
