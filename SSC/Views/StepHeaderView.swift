//
//  StepHeaderView.swift
//  SSC
//
//  Created by Graciella Michelle Siswoyo on 13/02/26.
//

import SwiftUI

struct StepHeaderView: View {
    @EnvironmentObject var game: GameLogic
    let totalSteps = 16
    let currentStep: Int
    
    private let steps = Array(0..<16)
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<totalSteps, id: \.self) { step in
                label(for: step)
                    .font(.title.bold())
                    .frame(width: 60)
                    .opacity(step == currentStep ? 1 : 0.4)
            }
        }
    }
    
    @ViewBuilder
    private func label(for step: Int) -> some View {
        
        let subdivision = step % 4
        let beatNumber = (step / 4) % 4 + 1
        
        switch subdivision {
        case 0: Text("\(beatNumber)")
        case 1: Image(systemName: "circle.fill")
                .font(Font.system(size: 6))
        case 2: Text("&")
        case 3: Image(systemName: "circle.fill")
                .font(Font.system(size: 6))
        default: EmptyView()
        }
        
//        if step % 2 == 0 {
//            let number = (step / 2) % 4 + 1
//            Text("\(number)")
//        } else {
//            Image(systemName: "circle.fill")
//                .font(Font.system(size: 6))
//        }
    }
}

#Preview {
    let game = GameLogic()
    StepHeaderView(currentStep: game.engine.currentStep)
        .environmentObject(game)
}
