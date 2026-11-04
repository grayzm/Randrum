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
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    
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
                    Spacer()
                    savedSection
                        .padding(.bottom, 10)
                    workspaceSection
                    Spacer()
                }
                
                VStack {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            if #available(iOS 26.0, *) {
                                Image(systemName: "chevron.left")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color("text"))
                                    .frame(width: 16, height: 16)
                                    .padding()
                                    .glassEffect()
                            } else {
                                Image(systemName: "chevron.left")
                                    .font(.title2)
                                    .foregroundStyle(Color("text"))
                                    .frame(width: 16, height: 16)
                                    .padding()
                                    .background(.ultraThinMaterial, in: Circle())
                            }
                        }
                        Spacer()
                    }
                    Spacer()
                }

                if let selectedPattern {
                    floatingPanel(
                        for: selectedPattern,
                        in: rootGeo.size
                    )
                        .zIndex(999)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .navigationBar)
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
                    GridItem(.adaptive(minimum: 110))
                    ], spacing: 16) {
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
                .padding(10)
            }
            .frame(maxHeight: 400)
            .background(
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        Color("screen")
                            .shadow(.inner(color: .black.opacity(colorScheme == .dark ? 0.7 : 0.3), radius: 4))
                    )
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
                                   endPoint: .bottom))
        )
    }
}

// --------------- WORKSPACE SECTION ---------------

extension CreateView {
    
    private var workspaceSection: some View {
        VStack {
            HStack(spacing: 20 ) {
                Text("Create")
                    .font(.title2.weight(.semibold))
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
        .frame(minHeight: 264, maxHeight: 440)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(colors: [Color("background1"), Color("background2")], startPoint: .top, endPoint: .bottom))
        )
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
        
        VStack {
            // HEADER GRID
            HStack(spacing: 30) {
                Rectangle()
                    .fill(.clear)
                    .scaledToFit()
                    .frame(maxWidth: 40, maxHeight: 40)
                CreateStepHeaderView()
            }
            VStack(spacing: 16) {
                HStack(spacing: 30) {
                    Image("hihat")
                        .resizable()
                        .scaledToFit()
                        .frame(minWidth: 40, maxHeight: 40)
                    CreateDrumRowView(
                        part: .hiHat,
                        beats: createLogic.userPattern.hiHat,
                    )
                }
                HStack(spacing: 30) {
                    Image("snare")
                        .resizable()
                        .scaledToFit()
                        .frame(minWidth: 40, maxHeight: 40)
                    CreateDrumRowView(
                        part: .snare,
                        beats: createLogic.userPattern.snare,
                    )
                }
                HStack(spacing: 30) {
                    Image("kick")
                        .resizable()
                        .scaledToFit()
                        .frame(minWidth: 40, maxHeight: 40)
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
    
    var body: some View {
        HStack(spacing: 14) {
            ForEach(0..<beats.count, id: \.self) { index in
                let isActive = beats[index].isActive
                let padFill: String = isActive ? "pressed" : "default"
                
                Button {
                    createLogic.toggleUserBeat(part: part, index: index)
                } label: {
                    ZStack {
                        // glow when playing
                        if createLogic.isPlaying && index == createLogic.engine.currentStep && isActive {
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color("pressed").opacity(colorScheme == .dark ? 0.6 : 1.2), lineWidth: 4)
                                .scaleEffect(createLogic.engine.stepPulse ? 1.4 : 1.1)
                                .opacity(0.9)
                                .shadow(color: Color("pressed").opacity(0.8), radius: 10)
                                .animation(.easeOut(duration: 0.1), value: createLogic.engine.stepPulse)
                                .blur(radius: 3)
                        }
                        ZStack {
                            RoundedRectangle(cornerRadius: 4)
                                .shadow(color: Color("shadow"), radius: 1, x: 3, y: 3)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    Color(padFill)
                                        .shadow(.inner(color: .white.opacity(colorScheme == .dark ? 0.15 : 0.6), radius: 2, x: 3, y: 4))
                                        .shadow(.inner(color: .black.opacity(colorScheme == .init(.dark) ? 0.4 : 0.1), radius: 5, x: -3, y: -4))

                                )
                        }
                    }
                }
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
                    .frame(maxHeight: 48)
                    .overlay(
                        label(for: step)
                            .font(.title3)
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
    @Environment(\.colorScheme) var colorScheme
    
    let isSaveEnabled: Bool
    let onSave: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // instruction display
            ZStack {
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        Color("screen")
                            .shadow(.inner(color: .black.opacity(colorScheme == .dark ? 0.7 : 0.3), radius: 4))
                    )
                    .stroke(Color("shadow"), lineWidth: 1.5)
                    .frame(maxHeight: 40)
                if !createLogic.workspaceMessage.isEmpty {
                    Text(createLogic.workspaceMessage)
                        .font(.custom("DepartureMono-Regular", size: 16))
                        .foregroundStyle(Color("text"))
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
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color("buttonFill"))
                    .frame(maxWidth: 60, maxHeight: 40)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color("stroke").opacity(0.4), lineWidth: 2)
                    )
                    .overlay(
                        Image(systemName: createLogic.isPlaying ? "stop.fill" : "play.fill")
                            .font(.title3)
                    )
                    .foregroundStyle(Color("text"))
            }
            
            // save
            Button {
                onSave()
            } label: {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color("buttonFill"))
                    .frame(maxWidth: 120, maxHeight: 40)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color("stroke").opacity(0.4), lineWidth: 2)
                    )
                    .overlay(
                        Text("Save")
                            .font(.title3)
                    )
                    .foregroundStyle(Color("text"))
            }
            .disabled(!isSaveEnabled)
            .opacity(isSaveEnabled ? 1 : 0.4)
        }
    }
}

// --------------- CREATE METRONOME TAPPER ---------------

struct CreateMetronomeTapperView: View {
    @EnvironmentObject var createLogic: CreateLogic
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            HStack {
                Text("\(Int(createLogic.userPattern.bpm))")
                    .font(.custom("DepartureMono-Regular", size: 20))
                    .foregroundStyle(Color("text"))
                Text("BPM")
                    .font(.custom("DepartureMono-Regular", size: 16))
                    .foregroundStyle(Color("text"))
            }
            .frame(maxWidth: 120, maxHeight: 40)
            .background(
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        Color("screen")
                            .shadow(.inner(color: .black.opacity(colorScheme == .dark ? 0.7 : 0.3), radius: 4))
                    )
                    .stroke(Color("shadow"), lineWidth: 1.5)
            )
            
            Button {
                createLogic.registerTap()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "metronome.fill")
                        .font(.title3)
                    Text("Tap")
                        .font(.subheadline)
                }
                .foregroundStyle(Color("text"))
                .frame(maxWidth: 96, maxHeight: 40)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color("buttonFill"))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
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
