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
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
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
            // back button
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        if #available(iOS 26.0, *) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color("text"))
                                .frame(width: 16, height: 16)
                                .padding()
                                .glassEffect()
                        } else {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundStyle(Color("text"))
                                .frame(width: 16, height: 16)
                                .padding()
                                .background(.ultraThinMaterial, in: Circle())
                        }
                    }
                    Spacer()
                }
                Spacer()
            }
        }
        .padding(16)
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}


#Preview {
    ContentView()
        .environmentObject(GameLogic())
}
