//
//  BeatButtonView.swift
//  SSC
//
//  Created by Graciella Michelle Siswoyo on 10/02/26.
//

// state comes from:
// isActive, currentPlaybackSetp

// blue when active
// highlighted when engine step matches index

import SwiftUI

struct BeatButtonView: View {
    @EnvironmentObject var game: GameLogic
    
    var isActive: Bool
    var isCurrentStep: Bool
    var feedback: BeatFeedback?
    
    let action: (() -> Void)?
    
    var body: some View {
        Button {
            action?()
        } label: {
            ZStack {
                // glow layer
                if isCurrentStep {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.white.opacity(0.15))
                        .blur(radius: 8)
                        .scaleEffect(isCurrentStep ? 1.12 : 1)
                        .transition(.opacity)
                }
                if isCurrentStep && isActive {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.white.opacity(0.6), lineWidth: 2)
                        .scaleEffect(1.35)
                        .opacity(0.8)
                        .blur(radius: 2)
                        .transition(.scale)
                }
                // main pad
                RoundedRectangle(cornerRadius: 5)
                    .fill(buttonColor)
                    .overlay(
                        feedback == .missed ?
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.white, lineWidth: 2) : nil
                    )
            }
        }
        .animation(.easeInOut(duration: 0.18), value: game.engine.stepPulse)
        .animation(.easeInOut(duration: 0.3), value: feedback)
        .disabled(action == nil)
    }
    private var buttonColor: Color {
        print("computing buttonColor - feedback: \(String(describing: feedback))")
        if let feedback = feedback {
            print("Feedback for button: \(feedback)")
            switch feedback {
            case .correct:
                print("-> showing white")
                return Color.white
            case .wrong:
                print("-> showing red")
                return Color.red.opacity(0.8)
            case .missed:
                print("-> showing outline")
                return Color("default")
            case .none:
                print("-> showing none")
                return Color("default")
            }
        }
        print("No feedback, using default logic")
        return isActive ? Color("pressed") : Color ("default")
    }
}

#Preview {
    BeatButtonView(isActive: true, isCurrentStep: true, action: {})
        .environmentObject(GameLogic())
}
