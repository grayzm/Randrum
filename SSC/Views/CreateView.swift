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
    
    @State private var selectedPattern: SavedPattern?
    @State private var renamingPattern: SavedPattern?
    @State private var patternToDelete: SavedPattern?
    @State private var renameText: String = ""
    @State private var selectedFrame: CGRect = .zero
    
    @Namespace private var folderNamespace
    
    var body: some View {
        GeometryReader { rootGeo in
            ZStack {
                VStack {
                    savedSection
                    Spacer()
                    workspaceSection
                }
                .padding(10)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                if let selectedPattern {
                    floatingPanel(
                        for: selectedPattern,
                        in: rootGeo.size
                    )
                        .zIndex(999)
                }
            }
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
        
        .alert("Delete Pattern?",
               isPresented: Binding(
                get: { patternToDelete != nil },
                set: { if !$0 { patternToDelete = nil } }
               ),
               presenting: patternToDelete
        ) { pattern in
            Button("Delete", role: .destructive) {
                if createLogic.editingPatternId == pattern.id {
                    createLogic.newPattern()
                }
                patternStore.delete(id: pattern.id)
                selectedPattern = nil
                patternToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                patternToDelete = nil
            }
        } message: { pattern in
            Text("Are you sure you want to delete \"\(pattern.name)\"?")
        }
        
        .alert("Rename Pattern",
               isPresented: Binding(
                get: { renamingPattern != nil },
                set: { if !$0 { renamingPattern = nil } }
            )
        ){
            TextField("New name", text: $renameText)
                .onChange(of: renameText) {
                    renameText = String(renameText.prefix(24))
                }
            Button("Save") {
                guard !renameText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                if let pattern = renamingPattern {
                    patternStore.rename(id: pattern.id, newName: renameText)
                }
                renamingPattern = nil
                selectedPattern = nil
            }
            Button("Cancel", role: .cancel) {
                renamingPattern = nil
            }
        }
    }
}

extension CreateView {
    
    private var savedSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Saved Patterns")
                .font(.custom("DepartureMono-Regular", size: 24))
            
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 120), spacing: 20)
                    ], spacing: 30) {
                        FolderAddView {
                            createLogic.newPattern()
                        }
                    ForEach(patternStore.patterns) { saved in
                        FolderView(
                            savedPattern: saved,
                            namespace: folderNamespace,
                            onOpen: {
                                createLogic.loadPattern(saved)
                            },
                            onLongPress: { frame in
                                selectedPattern = saved
                                selectedFrame = frame
                            }
                        )
                    }
                }
                    
                .padding(.vertical, 10)
                .padding(.horizontal, 10)
            }
            .background(
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color("bnw").opacity(0.3))
                    .stroke(Color("shadow"), lineWidth: 3)
                )
        }
        .padding(24)
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(colors: [Color("background1"), Color("background2")],
                                   startPoint: .top,
                                   endPoint: .bottom)))
        
    }
}

extension CreateView {
    
    private var workspaceSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 30 ) {
                Text("Workspace")
                    .font(.custom("DepartureMono-Regular", size: 24))
                Spacer()
                CreateControlPanelView(
                    isSaveEnabled: createLogic.hasUnsavedChanges,
                    onSave: {
                        if createLogic.editingPatternId != nil {
                            // already has a name - update in place
                            if let existing = patternStore.patterns.first(where: {
                                $0.id == createLogic.editingPatternId
                            }) {
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
}

extension CreateView {
    @ViewBuilder
    private func floatingPanel(
        for pattern: SavedPattern,
        in containerSize: CGSize
    ) -> some View {
        
        let screenWidth = containerSize.width
        let screenHeight = containerSize.height
        let panelWidth: CGFloat = 260
        let panelHeight: CGFloat = 260
        let gap: CGFloat = 6
        
        // horizontal clamping
        let x = min(
            max(panelWidth / 2 + 20, selectedFrame.midX),
            screenWidth - panelWidth / 2 - 20
        )
        
        // vertical positioning
        let spaceBelow = screenHeight - selectedFrame.maxY
        let showAbove = spaceBelow < panelHeight + 20
        
        let y = showAbove
        ? selectedFrame.minY - panelHeight / 2 - gap
        : selectedFrame.maxY + panelHeight / 2 + gap
        
        ZStack {
            // transparent tap catcher
            Color.black.opacity(0.001)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedPattern = nil
                }
            
            // floating panel
            VStack {
                panelContent(for: pattern)
                    .frame(width: panelWidth, height: panelHeight)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color("bnw").opacity(0.9))
                            .shadow(radius: 30)
                    )
                    .position(x: x, y: y)
                    .transition(.opacity.combined(with: .move(edge: showAbove ? .bottom : .top)))
                    .animation(.easeOut(duration: 0.2), value: selectedPattern)
            }
        }
    }
    
    private func panelContent(for pattern: SavedPattern) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(pattern.name)
                .font(.custom("DepartureMono-Regular", size: 20))
            Divider()
            HStack {
                Text("Created:")
                Spacer()
                Text(pattern.dateString)
            }
            HStack {
                Text("BPM:")
                Spacer()
                Text("\(Int(pattern.bpm))")
            }
            Divider()
            HStack{
                Button("Rename") {
                    renamingPattern = pattern
                    renameText = pattern.name
                }
                Spacer()
                Button(role: .destructive) {
                    patternToDelete = pattern
                } label: {
                    Image(systemName: "trash.fill")
                }
            }
        }
        .padding(18)
    } 
}

// --------------- CREATE WORKSPACE GRID VIEW ---------------

struct CreateWorkspaceGridView: View {
    @EnvironmentObject var createLogic: CreateLogic
    @Environment(\.colorScheme) var colorScheme
    
    private let spacing: CGFloat = 14
    private let padSize: CGFloat = 50
    
    var body: some View {
        HStack {
            VStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 5)
                    .frame(width: 50, height: 50)
                    .foregroundColor(Color.clear)
//                        .overlay(
//                            Image(systemName: "metronome.fill")
//                                .font(.title)
//                                .foregroundStyle(Color("icon"))
//                        )
                VStack(spacing: 30) {
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: 50, height: 50)
                        .foregroundColor(Color.clear)
                        .overlay(
                            Image(systemName: "music.pages.fill")
                                .font(.largeTitle)
                                .foregroundStyle(Color("icon"))
                        )
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: 50, height: 50)
                        .foregroundColor(Color.clear)
                        .overlay(
                            Image(systemName: "music.pages.fill")
                                .font(.largeTitle)
                                .foregroundStyle(Color("icon"))
                        )
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: 50, height: 50)
                        .foregroundColor(Color.clear)
                        .overlay(
                            Image(systemName: "music.pages.fill")
                                .font(.largeTitle)
                                .foregroundStyle(Color("icon"))
                        )
                }
            }
            
            Spacer()
            
            
            VStack(spacing: 16) {
                CreateStepHeaderView()
                    .frame(height: 50)
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
        HStack(spacing: 14) {
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
        HStack(spacing: 14) {
            ForEach(0..<totalSteps, id: \.self) { step in
                label(for: step)
                    .font(.title.bold())
                    .frame(width: 50)
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
    
    let isSaveEnabled: Bool
    let onSave: () -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            // instruction display
            ZStack {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color("screen"))
                    .stroke(Color("shadow"), lineWidth: 2)
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
                            .foregroundStyle(Color("text"))
                    )
            }
            .disabled(!isSaveEnabled)
            .opacity(isSaveEnabled ? 1 : 0.4)
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
                    .stroke(Color("shadow"), lineWidth: 2)
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
