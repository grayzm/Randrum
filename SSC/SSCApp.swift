//
//  SSCApp.swift
//  SSC
//
//  Created by Graciella Michelle Siswoyo on 08/02/26.
//

import SwiftUI

@main
struct SSCApp: App {
    @StateObject private var game = GameLogic()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(game)
        }
    }
}
