//
//  LandingView.swift
//  SSC
//
//  Created by Graciella Michelle Siswoyo on 21/02/26.
//

internal import SwiftUI

struct LandingView: View {
    @EnvironmentObject var game: GameLogic
    @EnvironmentObject var createLogic: CreateLogic
    @EnvironmentObject var patternStore: PatternStore
    
    @State var shouldNavigatePractice: Bool = false
    @State var shouldNavigateCreate: Bool = false
    @State var shouldNavigateHelp: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("RANDRUM")
                    .font(.custom("DepartureMono-Regular", size: 120))
                VStack {
                    Button {
                        shouldNavigatePractice = true
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
                .navigationDestination(isPresented: $shouldNavigatePractice) {
                    ContentView()
                        .environmentObject(game)
                }
                
                Button {
                    createLogic.newPattern()
                    shouldNavigateCreate = true
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
                .navigationDestination(isPresented: $shouldNavigateCreate) {
                    CreateView()
                        .environmentObject(createLogic)
                        .environmentObject(patternStore)
                }

                Button {
                    shouldNavigateHelp = true
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
                .navigationDestination(isPresented: $shouldNavigateHelp) {
                    HelpView()
                }
            }
        }
    }
}

#Preview {
    LandingView()
        .environmentObject(GameLogic())
        .environmentObject(CreateLogic())
        .environmentObject(PatternStore())
}
