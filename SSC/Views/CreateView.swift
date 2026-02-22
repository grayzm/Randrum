//
//  CreateView.swift
//  SSC
//
//  Created by Graciella Michelle Siswoyo on 21/02/26.
//

// rewritten with save slots section (using ForEach over patternStore.patterns), a workspace grid, control panel with save button, and a metronome tapper all driven by CreateLogic.

internal import SwiftUI

struct CreateView: View {
    @EnvironmentObject var createLogic: CreateLogic
    @EnvironmentObject var patternStore: PatternStore
    
    @State private var showingSaveAlert = false
    @State private var saveName = ""
    
    var body: some View {
        VStack(spacing: 30) {
            // save files section
            VStack(alignment: .leading, spacing: 20) {
                Text("Saved Patterns")
                    .font(.custom("DepartureMono-Regular", size: 24))
                
                if patternStore.patterns.isEmpty {
                    Text("No saved patterns yet")
                        .font(.custom("DepartureMono-Regular", size: 16))
                        .foregroundStyle(Color("stroke").opacity(0.6))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 10)
                } else {
                    ForEach(patternStore.patterns) { saved in
                        SaveFilesView(
                            savedPattern: saved,
                            isPlaying: createLogic.editingPatternId == saved.id && createLogic.isPlaying,
                            onEdit: {
                                createLogic.loadPattern(saved)
                            },
                            onPlay: {
                                if createLogic.editingPatternId == saved.id &&
                                    createLogic.isPlaying {
                                    createLogic.stopPlayback()
                                } else {
                                    createLogic.loadPattern(saved)
                                    createLogic.startRecreating()
                                }
                            },
                            onDelete: {
                                // stop playback if we're deleting the pattern being edited
                                if createLogic.editingPatternId == saved.id {
                                    createLogic.newPattern()
                                }
                                patternStore.delete(id: saved.id)
                            }
                        )
                    }
                }
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(colors: [Color("background1"), Color("background2")], startPoint: .top, endPoint: .bottom)))
            
            // workspace section that uses CreateLogic
            VStack(spacing: 30) {
                HStack(spacing: 30 ) {
                    Text("Workspace")
                        .font(.custom("DepartureMono-Regular", size: 24))
                    Spacer()
                    CreateControlPanelView(
                        onSave: {
                            if createLogic.editingPatternId != nil {
                                // already has a name - update in place
                                if let existing = patternStore.patterns.first(where: { $0.id ==
                                    createLogic.editingPatternId }) {
                                    createLogic.save(to: patternStore, name: existing.name)
                                }
                            } else {
                                // new pattern - ask for a name
                                saveName = "Pattern \(patternStore.patterns.count + 1)"
                                showingSaveAlert = true
                            }
                        }
                    )
                }
                CreateWorkspaceGridView()
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(colors: [Color("background1"), Color("background2")], startPoint: .top, endPoint: .bottom)))
        }
        .alert("Save Pattern", isPresented: $showingSaveAlert) {
            TextField("Pattern name", text: $saveName)
            Button("Save") {
                createLogic.save(to: patternStore, name: saveName)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Give your pattern a name")
        }
    }
}

// --------------- CREATE WORKSPACE GRID VIEW ---------------

struct CreateWorkspaceGridView: View {
    @EnvironmentObject var createLogic: CreateLogic
    @Environment(\.colorScheme) var colorScheme
    
    private let spacing: CGFloat = 10
    private let padSize: CGFloat = 56
    
    var body: some View {
        HStack {
            VStack(spacing: 30) {
                RoundedRectangle(cornerRadius: 5)
                    .frame(width: 56, height: 56)
                    .foregroundColor(Color.clear)
                    .overlay(
                        Image(systemName: "metronome.fill")
                            .font(.largeTitle)
                            .foregroundStyle(Color("icon"))
                    )
                ForEach(0..<3) { _ in
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: 56, height: 56)
                        .foregroundColor(Color.clear)
                        .overlay(
                            Image(systemName: "music.pages.fill")
                                .font(.largeTitle)
                                .foregroundStyle(Color("icon"))
                        )
                }
            }
            
            Spacer()
            
            
            VStack(spacing: 30) {
                CreateStepHeaderView()
                    .frame(height: 56)
                ZStack(alignment: .topLeading) {
                    VStack(spacing: 30) {
                        CreateDrumRowView(part: .hiHat, beats: createLogic.userPattern.hiHat, size: padSize)
                        CreateDrumRowView(part: .snare, beats: createLogic.userPattern.snare, size: padSize)
                        CreateDrumRowView(part: .kick, beats: createLogic.userPattern.kick, size: padSize)
                    }
                    // playhead overlay
                    if createLogic.isPlaying && createLogic.engine.currentStep >= 0 {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(.white.opacity(colorScheme == .dark ? 0.15 : 0.3))
                            .frame(width: padSize, height: 228)
                            .offset(x: CGFloat(createLogic.engine.currentStep) * (padSize + spacing))
                            .animation(
                                createLogic.engine.currentStep == 0
                                ? nil : .linear(duration: 0.08),
                                value: createLogic.engine.currentStep
                            )
                            .allowsHitTesting(false)
                    }
                }
            }
        }
    }
}

// --------------- CREATE DRUM ROW VIEW ---------------

struct CreateDrumRowView: View {
    @EnvironmentObject var createLogic: CreateLogic
    
    let part: DrumParts
    let beats: [BeatSlot]
    let size: CGFloat
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<beats.count, id: \.self) { index in
                let isActive = beats[index].isActive
                
                Button {
                    createLogic.toggleUserBeat(part: part, index: index)
                } label: {
                    ZStack {
                        // glow when playing
                        if createLogic.isPlaying && index == createLogic.engine.currentStep && isActive {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(.white.opacity(0.15))
                                .blur(radius: 8)
                                .scaleEffect(1.12)
                        }
                        RoundedRectangle(cornerRadius: 5)
                            .fill(isActive ? Color("pressed") : Color("default"))
                            .shadow(color: Color("shadow"), radius: 4, x: 4, y: 4)
                    }
                }
                .frame(width: size, height: size)
                .animation(.easeInOut(duration: 0.18), value: createLogic.engine.stepPulse)
            }
        }
    }
}

// --------------- CREATE STEP HEADER ---------------

struct CreateStepHeaderView: View {
    @EnvironmentObject var createLogic: CreateLogic
    
    let totalSteps = 16
    
    var currentStep: Int {
        createLogic.isPlaying && createLogic.engine.currentStep >= 0
        ? createLogic.engine.currentStep : -1
    }
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<totalSteps, id: \.self) { step in
                label(for: step)
                    .font(.title.bold())
                    .frame(width: 56)
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
        case 1: Image(systemName: "circle.fill").font(Font.system(size: 6))
        case 2: Text("&")
        case 3: Image(systemName: "circle.fill").font(Font.system(size: 6))
        default: EmptyView()
        }
    }
}

// --------------- CREATE CONTROL PANEL ---------------

struct CreateControlPanelView: View {
    @EnvironmentObject var createLogic: CreateLogic
    
    let onSave: () -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            // instruction display
            ZStack {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color("screen"))
                    .frame(height: 50)
                if !createLogic.workspaceMessage.isEmpty {
                    Text(createLogic.workspaceMessage)
                        .font(.custom("DepartureMono-Regular", size: 20))
                        .foregroundStyle(Color("stroke"))
                        .padding(.horizontal, 12)
                }
            }
            
            // BPM tapper
            CreateMetronomeTapperView()
            
            // play/pause
            Button {
                if createLogic.isPlaying {
                    createLogic.stopPlayback()
                } else {
                    createLogic.startRecreating()
                }
            } label: {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color("buttonFill"))
                    .frame(width: 60, height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color("stroke").opacity(0.4), lineWidth: 2)
                    )
                    .padding(.vertical, 5)
                    .overlay(
                        Image(systemName: createLogic.isPlaying ? "stop.fill" : "play.fill")
                    )
                    .foregroundStyle(Color("text"))
            }
            
            // save
            Button(action: onSave) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color("buttonFill"))
                    .frame(width: 120, height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color("stroke").opacity(0.4), lineWidth: 2)
                    )
                    .padding(.vertical, 5)
                    .overlay(
                        Text("Save")
                            .font(.custom("DepartureMono-Regular", size: 16))
                    )
                    .foregroundStyle(Color("text"))
            }
        }
    }
}

// --------------- CREATE METRONOME TAPPER ---------------

struct CreateMetronomeTapperView: View {
    @EnvironmentObject var createLogic: CreateLogic
    
    var body: some View {
        HStack(spacing: 20) {
            HStack {
                Text("\(Int(createLogic.userPattern.bpm))")
                    .font(.custom("DepartureMono-Regular", size: 24))
                    .foregroundStyle(Color("stroke"))
                Text("BPM")
                    .font(.custom("DepartureMono-Regular", size: 20))
                    .foregroundStyle(Color("stroke"))
            }
            .frame(width: 120, height: 50)
            .background(
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color("screen"))
            )
            
            Button {
                createLogic.registerTap()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "metronome.fill")
                        .font(.system(size: 20))
                    Text("Tap")
                        .font(.custom("DepartureMono-Regular", size: 20))
                }
                .foregroundStyle(Color("text"))
                .frame(width: 120, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color("buttonFill"))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color("stroke").opacity(0.4), lineWidth: 2)
                )
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    CreateView()
        .environmentObject(CreateLogic())
        .environmentObject(PatternStore())
}
