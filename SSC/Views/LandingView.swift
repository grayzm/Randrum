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
            ZStack {
                ShaderBackground()
                VStack {
                    Text("RANDRUM")
                        .font(.custom("DepartureMono-Regular", size: 120))
                    VStack {
                        Button {
                            shouldNavigatePractice = true
                        } label: {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color("buttonFill"))
                                .frame(width: 200, height: 64)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color("stroke").opacity(0.4), lineWidth: 2)
                                )
                                .padding(.vertical, 10)
                                .overlay(Text("Practice")
                                    .font(.title2)
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
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color("buttonFill"))
                            .frame(width: 200, height: 64)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color("stroke").opacity(0.4), lineWidth: 2)
                            )
                            .padding(.vertical, 10)
                            .overlay(Text("Create")
                                .font(.title2)
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
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color("buttonFill"))
                            .frame(width: 200, height: 64)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color("stroke").opacity(0.4), lineWidth: 2)
                            )
                            .padding(.vertical, 10)
                            .overlay(Text("Help")
                                .font(.title2)
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
}

#Preview {
    LandingView()
        .environmentObject(GameLogic())
        .environmentObject(CreateLogic())
        .environmentObject(PatternStore())
}
