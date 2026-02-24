//
//  StepHeaderView.swift
//  SSC
//
//  Created by Graciella Michelle Siswoyo on 13/02/26.
//

internal import SwiftUI

struct StepHeaderView: View {
    @EnvironmentObject var game: GameLogic
    let totalSteps = 16
    let currentStep: Int
    
    private let steps = Array(0..<16)
    
    var body: some View {
                HStack {
//        Grid {
//            GridRow {
                ForEach(0..<totalSteps, id: \.self) { step in
                    Rectangle()
                        .fill(Color(.white.opacity(0.2)))
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(
                            label(for: step)
                                .font(.title.bold())
                                .opacity(step == currentStep ? 1 : 0.4),
//                            alignment: .bottom
                        )
                    //                    .frame(width: 50)
                }
            }
//            .gridCellUnsizedAxes(.horizontal)
        }
//    }
    
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
    }
}

#Preview {
    let game = GameLogic()
    StepHeaderView(currentStep: game.engine.currentStep)
        .environmentObject(game)
}
