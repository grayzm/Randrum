//
//  RandomPatternView.swift
//  SSC
//
//  Created by Graciella Michelle Siswoyo on 10/02/26.
//

internal import SwiftUI

struct RandomPatternView: View {
    @EnvironmentObject var game: GameLogic
    @Environment(\.colorScheme) var colorScheme
    
    // random flicker state: 3 rows x 16 buttons
    @State private var flickerState: [[Bool]] = Array(
        repeating: Array(repeating: false, count: 16),
        count: 3
    )
    @State private var flickerTimer: Timer? = nil
    
    // layout constants
//    private let controlPanelWidth: CGFloat = 140
//    private let mainSpacing: CGFloat = 20
//    private let iconWidth: CGFloat = 50
//    private let gridSpacing: CGFloat = 16
//    private let horizontalPadding: CGFloat = 16 * 2
//    private let verticalSpacing: CGFloat = 20
    
    // what to actually display per row
    private func displayBeats(for row: Int, real: [BeatSlot]) -> [BeatSlot] {
        switch game.gameState {
        case .checking, .result:
            return real // reveal actual pattern
        case .listening:
            if game.hasChecked {
                return real // show real pattern after check
            }
            return flickerState[row].map { BeatSlot(isActive: $0) }
        default:
            return Array(repeating: BeatSlot(isActive: false), count: 16)
        }
    }
    
    var body: some View {
        VStack(spacing: 30) {
            HStack(spacing: 20) {
                Text("Generator")
                    .font(.title2.bold())

                ZStack {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color("screen"))
                        .stroke(Color("shadow"), lineWidth: 2)
                        .frame(height: 40)
                    InstructionView(messageType: .random)
    //                    .padding(.horizontal, 12)
                }
                
                HStack(spacing: 12) {
                    Button {
                        game.toggleRandomPlayback()
                    } label: {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color("buttonFill"))
                            .frame(width: 96, height: 40)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color("stroke").opacity(0.4), lineWidth: 2)
                            )
                            .overlay(
                                Image(systemName: game.gameState == .listening
                                      ? "stop.fill" : "play.fill")
                                .font(.title3)
                                .foregroundStyle(Color("text"))
                            )
                    }
                    Button {
                        game.nextRound()
                    } label: {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color("buttonFill"))
                            .frame(width: 96, height: 40)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color("stroke").opacity(0.4), lineWidth: 2)
                            )
                            .overlay(
                                Image(systemName: "arrow.clockwise")
                                    .font(.title3.bold())
                                    .foregroundStyle(Color("text"))
                            )
                    }
                    Button {
                        game.startChecking()
                    } label: {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color("buttonFill"))
                            .frame(width: 96, height: 40)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color("stroke").opacity(0.4), lineWidth: 2)
                            )
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.title3.bold())
                                    .foregroundStyle(Color("text"))
                            )

                    }
                }

            }
            HStack {
                // --------------- DRUM PADS ---------------
                VStack(spacing: 16) {
                    // hihat
                    HStack(spacing: 30) {
                        Image("hihat")
                            .resizable()
                            .scaledToFit()
                            .frame(minWidth: 40, maxWidth: 40)
                            .aspectRatio(1, contentMode: .fit)
                        DrumRowView(
                            part: .hiHat,
                            beats: displayBeats(for: 0, real: game.randomPattern.hiHat),
                            showGlow: game.gameState == .listening,
                            isEditable: false,
                            showsFeedback: false,
                        )
                    }
                    // snare
                    HStack(spacing: 30) {
                        Image("snare")
                            .resizable()
                            .scaledToFit()
                            .frame(minWidth: 40, maxHeight: 40)
                            .aspectRatio(1, contentMode: .fit)
                        DrumRowView(
                            part: .snare,
                            beats: displayBeats(for: 0, real: game.randomPattern.snare),
                            showGlow: game.gameState == .listening,
                            isEditable: false,
                            showsFeedback: false,
                        )
                    }
                    // snare
                    HStack(spacing: 30) {
                        Image("kick")
                            .resizable()
                            .scaledToFit()
                            .frame(minWidth: 40, maxHeight: 40)
                            .aspectRatio(1, contentMode: .fit)
                        DrumRowView(
                            part: .kick,
                            beats: displayBeats(for: 0, real: game.randomPattern.kick),
                            showGlow: game.gameState == .listening,
                            isEditable: false,
                            showsFeedback: false,
                        )
                    }
                }
                // playhead overlay
                .overlayPreferenceValue(StepFramePreferenceKey.self) { values in
                    GeometryReader { overlayGeo in
                        if game.gameState == .listening,
                           game.engine.currentStep == 0,
                           let anchor = values[game.engine.currentStep] {
                            
                            let frame = overlayGeo[anchor]
                            
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.white.opacity(colorScheme == .dark ? 0.15 : 0.35))
                                .frame(width: frame.width, height: overlayGeo.size.height)
                                .offset(x: frame.minX)
                                .animation(.linear(duration: 0.08),
                                           value: game.engine.currentStep)
                                .allowsHitTesting(false)
                        }
                    }
                }
            }
        }
        
        .onChange(of: game.gameState) { _, newState in
            if newState == .listening {
                if game.hasChecked {
                    stopFlicker()
                } else {
                    startFlicker()
                }
            } else if newState == .checking || newState == .result {
                game.hasChecked = true
                stopFlicker()
            } else if newState == .idle {
                game.hasChecked = false
                stopFlicker()
            }
        }
    }
    
    private func startFlicker() {
        guard !game.hasChecked else { return }
        randomizeFlicker()
        // lower number = more flickering
        flickerTimer = Timer.scheduledTimer(withTimeInterval: 0.18, repeats: true) { _ in
            randomizeFlicker()
        }
    }
    
    private func stopFlicker() {
        flickerTimer?.invalidate()
        flickerTimer = nil
    }
    
    private func randomizeFlicker() {
        for row in 0..<3 {
            for col in 0..<16 {
                // how many buttons update each tick (higher number = more chaotic)
                if Double.random(in: 0...1) < 0.7 {
                    // how likely a button is on vs off (lower = more sparse)
                    flickerState[row][col] = Double.random(in: 0...1) < 0.2
                }
            }
        }
    }
}


#Preview {
    RandomPatternView()
        .environmentObject(GameLogic())
}
