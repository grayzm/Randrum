//
//  BeatButtonView.swift
//  SSC
//
//  Created by Graciella Michelle Siswoyo on 10/02/26.
//

internal import SwiftUI

enum BeatButtonStyle {
    case randomPattern
    case workspace
}

struct BeatButtonView: View {
    @EnvironmentObject var game: GameLogic
    @Environment(\.colorScheme) var colorScheme
    
    @State private var isPressed = false
    
    var style: BeatButtonStyle = .workspace
    var isActive: Bool
    var isCurrentStep: Bool
    var feedback: BeatFeedback?
    var index: Int
    var revealUpToStep: Int?
    
    let action: (() -> Void)?
    
    var body: some View {
        Button {
            action?()
        } label: {
            ZStack {
                // glow layer
                if isCurrentStep && isActive && style == .workspace {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.white.opacity(colorScheme == .dark ? 0.15 : 0.3))
                        .blur(radius: 8)
                        .scaleEffect(isCurrentStep ? 1.12 : 1)
                        .transition(.opacity)
                }
                if isCurrentStep && isActive && game.gameState == .recreating {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color("pressed").opacity(colorScheme == .dark ? 0.6 : 1.2), lineWidth: 4)
                        .scaleEffect(game.engine.stepPulse ? 1.4 : 1.1)
                        .opacity(0.9)
                        .shadow(color: Color("pressed").opacity(0.8), radius: 10)
                        .animation(.easeOut(duration: 0.2), value: game.engine.stepPulse)
                        .blur(radius: 3)
                }
                
                // main pad
                switch style {
                    case .randomPattern:
                        RoundedRectangle(cornerRadius: 4)
                        .fill(Color(colorScheme == .dark ? .black : Color("screen")))
                            .overlay {
                                if isActive {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color("pressed"))
                                }
                            }
                    case .workspace:
                    ZStack {
                        RoundedRectangle(cornerRadius: 4)
                            .shadow(color: Color("shadow"), radius: 1, x: 3, y: 3)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                buttonColor
                                    .shadow(.inner(color: .white.opacity(colorScheme == .dark ? 0.15 : 0.6), radius: 2, x: 3, y: 4))
                                    .shadow(.inner(color: .black.opacity(colorScheme == .init(.dark) ? 0.4 : 0.1), radius: 5, x: -3, y: -4))
                            )
                            .overlay(
                                shouldShowFeedback && feedback == .missed ?
                                RoundedRectangle(cornerRadius: 4)
                                    .strokeBorder(Color.white, lineWidth: 3) : nil
                            )
                    }
                }
            }
        }
        .animation(.linear(duration: 0.1), value: isActive)
        .animation(.easeInOut(duration: 0.18), value: game.engine.stepPulse)
        .animation(.easeInOut(duration: 0.3), value: feedback)
        .disabled(action == nil)
    }
    
    private var shouldShowFeedback: Bool {
        guard feedback != nil else { return false }
        
        if let revealUpToStep = revealUpToStep {
            // during checking: only show if slider has passed this index
            return index <= revealUpToStep
        }
        // after checking (result state): show all feedback
        return true
    }
    
    private var buttonColor: Color {
        if shouldShowFeedback, let feedback = feedback {
            switch feedback {
            case .correct:
                return Color(.white)
            case .wrong:
                return Color.red.opacity(0.8)
            case .missed:
                return Color("default")
            case .none:
                return Color("default")
            }
        }
        return isActive ? Color("pressed") : Color ("default")
    }
}

#Preview {
    BeatButtonView(
        isActive: false,
        isCurrentStep: true,
        feedback: .correct,
        index: 0,
        revealUpToStep: 0,
        action: {})
        .environmentObject(GameLogic())
}
