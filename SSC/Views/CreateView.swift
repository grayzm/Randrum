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
    @State private var showingSavedConfirmation = false
    @State private var showingNewPatternAlert = false
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
//                    Spacer()
                    workspaceSection
                }
                .navigationTitle("Create")
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
        
        .alert("New Pattern", isPresented: $showingNewPatternAlert) {
            Button("Ok", role: .cancel) {}
        } message: {
            Text("New blank workspace ready. Start creating your new pattern!")
        }
        
        .alert("Pattern Saved!", isPresented: $showingSavedConfirmation) {
            Button("Ok", role: .cancel) {}
        } message: {
            Text("Your pattern has been saved successfully.")
        }
    }
}

extension CreateView {
    
    private var savedSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Saved Patterns")
                .font(.title2.weight(.semibold))
            
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 120), spacing: 20)
                    ], spacing: 30) {
                        FolderAddView {
                            createLogic.newPattern()
                            showingNewPatternAlert = true
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
                .padding(16)
            }
            .frame(maxHeight: 260)
            .background(
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color("bnw").opacity(0.3))
                    .stroke(Color("shadow"), lineWidth: 3)
                )
        }
        .padding(30)
        .padding(.bottom, 5)
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
                    .font(.title.weight(.semibold))
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
        .padding(.top, 5)
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
//                .font(.custom("DepartureMono-Regular", size: 20))
            Divider()
            HStack {
                Text("Created:")
                    .font(.title3)
                Spacer()
                Text(pattern.dateString)
                    .font(.title3)
            }
            HStack {
                Text("BPM:")
                    .font(.title3)
                Spacer()
                Text("\(Int(pattern.bpm))")
                    .font(.title3)
            }
            Divider()
            HStack{
                Button {
                    renamingPattern = pattern
                    renameText = pattern.name
                } label: {
                    Text("Rename")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
                Spacer()
                Button(role: .destructive) {
                    patternToDelete = pattern
                } label: {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 20))
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
    
    var body: some View {
        
        VStack(spacing: 8) {
            // HEADER GRID
            Grid(horizontalSpacing: 30) {
                GridRow {
                    RoundedRectangle(cornerRadius: 5)
                        .aspectRatio(1, contentMode: .fit)
                        .frame(minWidth: 50, maxHeight: 70)
                        .foregroundColor(Color.clear)
                    CreateStepHeaderView()
                }
            }
            // DRUM SECTION
//            Grid(horizontalSpacing: 30, verticalSpacing: 30) {
//                GridRow {
//                    Image("hihat")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(minWidth: 50, maxHeight: 70)
//                    CreateDrumRowView(
//                        part: .hiHat,
//                        beats: createLogic.userPattern.hiHat,
//                    )
//                }
//                GridRow {
//                    Image("snare")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(minWidth: 50, maxHeight: 70)
//                    CreateDrumRowView(
//                        part: .snare,
//                        beats: createLogic.userPattern.snare,
//                    )
//                }
//                GridRow {
//                    Image("kick")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(minWidth: 50, maxHeight: 70)
//                    CreateDrumRowView(
//                        part: .kick,
//                        beats: createLogic.userPattern.kick,
//                    )
//                }
//            }
            VStack(spacing: 30) {
                HStack(spacing: 30) {
                    Image("hihat")
                        .resizable()
                        .scaledToFit()
                        .frame(minWidth: 50, maxHeight: 70)
                    CreateDrumRowView(
                        part: .hiHat,
                        beats: createLogic.userPattern.hiHat,
                    )
                }
                HStack(spacing: 30) {
                    Image("snare")
                        .resizable()
                        .scaledToFit()
                        .frame(minWidth: 50, maxHeight: 70)
                    CreateDrumRowView(
                        part: .snare,
                        beats: createLogic.userPattern.snare,
                    )
                }
                HStack(spacing: 30) {
                    Image("kick")
                        .resizable()
                        .scaledToFit()
                        .frame(minWidth: 50, maxHeight: 70)
                    CreateDrumRowView(
                        part: .kick,
                        beats: createLogic.userPattern.kick,
                    )
                }
            }
            // PLAYHEAD
            .overlayPreferenceValue(StepFramePreferenceKey.self) { values in
                GeometryReader { geo in
                    if createLogic.engine.currentStep >= 0,
                       let anchor = values[createLogic.engine.currentStep] {
                        
                        let frame = geo[anchor]
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.white.opacity(0.15))
                            .frame(width: frame.width, height: geo.size.height)
                            .offset(x: frame.minX)
                            .animation(.linear(duration: 0.08),
                                       value: createLogic.engine.currentStep)
                            .allowsTightening(false)
                    }
                }
            }
        }
    }
}

// --------------- CREATE DRUM ROW VIEW ---------------

struct CreateDrumRowView: View {
    @EnvironmentObject var createLogic: CreateLogic
    @Environment(\.colorScheme) var colorScheme
    
    let part: DrumParts
    let beats: [BeatSlot]
//    let size: CGFloat
    
    var body: some View {
        HStack/*(spacing: 14)*/ {
            ForEach(0..<beats.count, id: \.self) { index in
                let isActive = beats[index].isActive
                
                Button {
                    createLogic.toggleUserBeat(part: part, index: index)
                } label: {
                    ZStack {
                        // glow when playing
                        if createLogic.isPlaying && index == createLogic.engine.currentStep && isActive {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color("pressed").opacity(colorScheme == .dark ? 0.6 : 1.2), lineWidth: 4)
                                .scaleEffect(createLogic.engine.stepPulse ? 1.4 : 1.1)
                                .opacity(0.9)
                                .shadow(color: Color("pressed").opacity(0.8), radius: 10)
                                .animation(.easeOut(duration: 0.2), value: createLogic.engine.stepPulse)
                                .blur(radius: 3)
                        }
                        RoundedRectangle(cornerRadius: 5)
                            .fill(isActive ? Color("pressed") : Color("default"))
                            .shadow(color: Color("shadow"), radius: 4, x: 4, y: 4)
                    }
                }
                .aspectRatio(1, contentMode: .fit)
                .anchorPreference(
                    key: StepFramePreferenceKey.self,
                    value: .bounds
                ) { anchor in
                    [index: anchor]
                }
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
                Rectangle()
                    .fill(Color.clear)
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(
                        label(for: step)
                            .font(.title.bold())
                            .opacity(step == currentStep ? 1 : 0.4),
                    )
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
                    .frame(maxHeight: 60)
                if !createLogic.workspaceMessage.isEmpty {
                    Text(createLogic.workspaceMessage)
                        .font(.custom("DepartureMono-Regular", size: 24))
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
                    .frame(maxWidth: 60, maxHeight: 60)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color("stroke").opacity(0.4), lineWidth: 2)
                    )
                    .padding(.vertical, 5)
                    .overlay(
                        Image(systemName: createLogic.isPlaying ? "stop.fill" : "play.fill")
                            .font(.system(size: 22))
                    )
                    .foregroundStyle(Color("text"))
            }
            
            // save
            Button(action: onSave) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color("buttonFill"))
                    .frame(maxWidth: 120, maxHeight: 60)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color("stroke").opacity(0.4), lineWidth: 2)
                    )
                    .padding(.vertical, 5)
                    .overlay(
                        Text("Save")
                            .font(.title2)
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
            .frame(maxWidth: 120, maxHeight: 60)
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
                        .font(.system(size: 24))
                    Text("Tap")
                        .font(.title2)
                }
                .foregroundStyle(Color("text"))
                .frame(maxWidth: 120, maxHeight: 60)
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
