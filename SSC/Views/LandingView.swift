//
//  LandingView.swift
//  SSC
//
//  Created by Graciella Michelle Siswoyo on 21/02/26.
//

import SwiftUI

struct LandingView: View {
    @EnvironmentObject var game: GameLogic
    @State var shouldNavigate: Bool = false
    var body: some View {
        NavigationStack {
            VStack {
                Text("RANDRUM")
                    .font(.custom("LTStopWatch-Regular", size: 120))
                VStack {
                    Button {
                        shouldNavigate = true
                    } label: {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color("buttonFill"))
                            .frame(width: 160, height: 56)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color("stroke").opacity(0.4), lineWidth: 2)
                            )
                            .padding(.vertical, 5)
                            .overlay(Text("Practice")
                                .font(.custom("DepartureMono-Regular", size: 20))
                                .foregroundStyle(Color("text"))
                            )
                    }
                }
                .navigationDestination(isPresented: $shouldNavigate) {
                    ContentView()
                        .environmentObject(game)
                }
                
                Button {
                    
                } label: {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color("buttonFill"))
                        .frame(width: 160, height: 56)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color("stroke").opacity(0.4), lineWidth: 2)
                        )
                        .padding(.vertical, 5)
                        .overlay(Text("Create")
                            .font(.custom("DepartureMono-Regular", size: 20))
                            .foregroundStyle(Color("text"))
                        )
                }

                Button {
                    
                } label: {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color("buttonFill"))
                        .frame(width: 160, height: 56)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color("stroke").opacity(0.4), lineWidth: 2)
                        )
                        .padding(.vertical, 5)
                        .overlay(Text("Help")
                            .font(.custom("DepartureMono-Regular", size: 20))
                                 //                        .font(.headline)
                            .foregroundStyle(Color("text"))
                        )
                }
            }
        }
    }
}

#Preview {
    LandingView()
        .environmentObject(GameLogic())
}
