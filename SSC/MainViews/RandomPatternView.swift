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
    
    @State private var availableWidth: CGFloat = 400 // default fallback
    
    // random flicker state: 3 rows x 16 buttons
    @State private var flickerState: [[Bool]] = Array(
        repeating: Array(repeating: false, count: 16),
        count: 3
    )
    @State private var flickerTimer: Timer? = nil
    
    // layout constants
    private let controlPanelWidth: CGFloat = 140
    private let mainSpacing: CGFloat = 20
    private let iconWidth: CGFloat = 50
    private let gridSpacing: CGFloat = 16
    private let horizontalPadding: CGFloat = 16 * 2
    private let verticalSpacing: CGFloat = 20
    
    // calculate the total grid height based on available width
    private var gridHeight: CGFloat {
        let availableGridWidth = availableWidth - controlPanelWidth - iconWidth - gridSpacing - horizontalPadding
        let buttonSize = DrumGridLayout.buttonSize(for: availableGridWidth)
        // 3 drum rows + 2 gaps between rows
        return (3 * buttonSize) + (2 * verticalSpacing)
    }
    
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
            ZStack {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color("screen"))
                    .stroke(Color("shadow"), lineWidth: 2)
                    .frame(height: 50)
                InstructionView(messageType: .random)
                    .padding(.horizontal, 12)
            }
            
            GeometryReader { geo in
                let availableGridWidth = geo.size.width - controlPanelWidth - mainSpacing - iconWidth - gridSpacing - horizontalPadding
                let buttonSize = DrumGridLayout.buttonSize(for: availableGridWidth)
                let rowHeight = buttonSize
                
                HStack(spacing: mainSpacing) {
                    // drum grid (with overlay container)
                    ZStack(alignment: .topLeading) {
                        VStack(spacing: verticalSpacing) {
                            // hihat
                            HStack(spacing: gridSpacing) {
                                Image("hihat")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: iconWidth, height: rowHeight)
                                DrumRowView(
                                    part: .hiHat,
                                    beats: displayBeats(for: 0, real: game.randomPattern.hiHat),
                                    showGlow: game.gameState == .listening,
                                    isEditable: false,
                                    showsFeedback: false,
                                )
                                .frame(height: rowHeight)
                                .padding(.horizontal, 16)
                            }
                            // snare
                            HStack(spacing: gridSpacing) {
                                Image("snare")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: iconWidth, height: rowHeight)
                                DrumRowView(
                                    part: .snare,
                                    beats: displayBeats(for: 1, real: game.randomPattern.snare),
                                    showGlow: game.gameState == .listening,
                                    isEditable: false,
                                    showsFeedback: false,
                                )
                                .frame(height: rowHeight)
                                .padding(.horizontal, 16)
                                
                            }
                            // kick
                            HStack(spacing: gridSpacing) {
                                Image("kick")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: iconWidth, height: rowHeight)
                                DrumRowView(
                                    part: .kick,
                                    beats: displayBeats(for: 2, real: game.randomPattern.kick),
                                    showGlow: game.gameState == .listening,
                                    isEditable: false,
                                    showsFeedback: false,
                                )
                                .frame(height: rowHeight)
                                .padding(.horizontal, 16)
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
                    
                    RandomControlPanelView()
                        .frame(width: controlPanelWidth)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .onAppear {
                    availableWidth = geo.size.width
                }
                .onChange(of: geo.size.width) { _, newWidth in
                    availableWidth = newWidth
                }
            }
            .frame(height: gridHeight)
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
