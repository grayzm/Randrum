//
//  SSCApp.swift
//  SSC
//
//  Created by Graciella Michelle Siswoyo on 08/02/26.
//

internal import SwiftUI

@main
struct SSCApp: App {
    @StateObject private var game = GameLogic()
    @StateObject private var createLogic = CreateLogic()
    @StateObject private var patternStore = PatternStore()
    
    var body: some Scene {
        WindowGroup {
            LandingView()
                .environmentObject(game)
                .environmentObject(createLogic)
                .environmentObject(patternStore)
        }
    }
}
