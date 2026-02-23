//
//  CreateLogic.swift
//  SSC
//
//  Created by Graciella Michelle Siswoyo on 21/02/26.
//

// the create-mode equivalent of GameLogic. Owns its own DrumPattern and RhythmEngine. Has toggleUserBeat(), registerTap(), startRecreating(), stopPlayback(). Also has loadPattern(_:) to load a saved pattern for editing, newPattern() to reset, and save(to:name:) to write to the PatternStore.

// owns a single DrumPattern that the user creats from scratch.
// handles toggling beats, bpm tapping, playback, and saving.
// conforms to WorkspaceProvider so WorkspaceView and its children can be reused without modification.

import Foundation
internal import Combine

class CreateLogic: ObservableObject {
    
    @Published var userPattern: DrumPattern
    @Published var engine = RhythmEngine()
    @Published var workspaceMessage: String = "Create your own pattern!"
    @Published var hasUnsavedChanges: Bool = false
    
    // create mode only has two states: idle or playing
    var isPlaying: Bool { engine.isRunning }

    private var cancellables = Set<AnyCancellable>()
    private var tapTimes: [Date] = []
    private var lastPlayedStep: Int = -1
    private var clearMessageWorkItem: DispatchWorkItem?
    private var originalPattern: DrumPattern?
    
    // if we're editing an existing save, keep its id so we can update in place.
    var editingPatternId: UUID? = nil
    
    init() {
        self.userPattern = DrumPattern.empty(bpm: 0)
        
        engine.$currentStep
            .sink { [weak self] _ in
                self?.objectWillChange.send()
                self?.triggerSounds()
            }
            .store(in: &cancellables)
        
        print("CreateLogic init")
    }
    
    // --------------- LOADING SAVED PATTERN FOR EDITING ---------------
    
    func loadPattern(_ saved: SavedPattern) {
        editingPatternId = saved.id
        hasUnsavedChanges = false
        userPattern = saved.toDrumPattern()
        workspaceMessage = "Editing: \(saved.name)"
        
        // stop playback if running
        if isPlaying {
            stopPlayback()
        }
        
        print("CreateLogic LoadPattern(\(saved.name))")
    }
    
    // reset to a blank pattern
    func newPattern() {
        editingPatternId = nil
        hasUnsavedChanges = false
        userPattern = DrumPattern.empty(bpm: 0)
        workspaceMessage = "Create your own pattern!"
        
        if isPlaying {
            stopPlayback()
        }
        
        print("CreateLogic newPattern()")
    }
    
    // --------------- SAVING ---------------
    
    // save the current pattern to the store.
    // if we're editing an existing one, update it; otherwise add a new one.
    
    func save(to store: PatternStore, name: String) {
        if let existingId = editingPatternId,
           var existing = store.patterns.first(where: { $0.id == existingId }) {
            // upadate in place
            existing.hiHat = userPattern.hiHat.map { $0.isActive }
            existing.snare = userPattern.snare.map { $0.isActive }
            existing.kick = userPattern.kick.map { $0.isActive }
            existing.bpm = userPattern.bpm
            existing.name = name
            store.update(existing)
            workspaceMessage = "Pattern updated."
        } else {
            // create new
            let saved = SavedPattern(name: name, from: userPattern)
            store.add(saved)
            editingPatternId = saved.id
            workspaceMessage = "Pattern saved."
        }
        
        hasUnsavedChanges = false
        
        clearMessageWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.workspaceMessage = ""
        }
        clearMessageWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: workItem)
        
        print("CreateLogic save()")
    }
    
    // --------------- WORKSPACE PROVIDER ACTIONS ---------------
    
    func toggleUserBeat(part: DrumParts, index: Int) {
        switch part {
        case .hiHat:
            userPattern.hiHat[index].isActive.toggle()
            if userPattern.hiHat[index].isActive {
                AudioManager.shared.play(part)
            }
        case .snare:
            userPattern.snare[index].isActive.toggle()
            if userPattern.snare[index].isActive {
                AudioManager.shared.play(part)
            }
        case .kick:
            userPattern.kick[index].isActive.toggle()
            if userPattern.kick[index].isActive {
                AudioManager.shared.play(part)
            }
        }
        hasUnsavedChanges = true
        syncPatternToEngine()
        print("CreateLogic toggelUserBeat(\(part), \(index))")
    }
    
    func registerTap() {
        let now = Date()
        tapTimes.append(now)
        
        if tapTimes.count > 6 {
            tapTimes.removeFirst()
        }
        
        guard tapTimes.count >= 2 else { return }
        
        var intervals: [TimeInterval] = []
        for i in 1..<tapTimes.count {
            intervals.append(tapTimes[i].timeIntervalSince(tapTimes[i-1]))
        }
        
        guard !intervals.isEmpty else { return }
        let averageInterval = intervals.reduce(0, +) / Double(intervals.count)
        let bpm = 60.0 / averageInterval
        let clamped = min(max(bpm, RhythmConfig.minBPM), RhythmConfig.maxBPM)
        userPattern.bpm = clamped
        
        workspaceMessage = "Calculating your BPM..."
        
        hasUnsavedChanges = true
        
        clearMessageWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.workspaceMessage = ""
        }
        clearMessageWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: workItem)
        
        if isPlaying {
            engine.start(bpm: clamped)
        }
        
        print("CreateLogic registerTap() -> BPM: \(clamped)")
    }
    
    func startRecreating() {
        lastPlayedStep = -1
        syncPatternToEngine()
        
        if userPattern.bpm > 0 {
            engine.start(bpm: userPattern.bpm)
        }
        workspaceMessage = "Playing your pattern..."
        
        print("CreateLogic startRecreating()")
    }
    
    func stopPlayback() {
        engine.stop()
        lastPlayedStep = -1
        workspaceMessage = "Your pattern paused"
        
        print("CreateLogic stopPlayback()")
    }
    
    // --------------- PRIVATE HELPERS ---------------
    
    private func syncPatternToEngine() {
        engine.tracks[0].steps = userPattern.hiHat.map { BeatSlot(isActive: $0.isActive) }
        engine.tracks[1].steps = userPattern.snare.map { BeatSlot(isActive: $0.isActive) }
        engine.tracks[2].steps = userPattern.kick.map { BeatSlot(isActive: $0.isActive) }
    }
    
    private func triggerSounds() {
        let step = engine.currentStep
        guard step >= 0, step != lastPlayedStep else { return }
        lastPlayedStep = step
        
        for part in DrumParts.allCases {
            if userPattern.steps(for: part)[step].isActive {
                AudioManager.shared.play(part)
            }
        }
    }
}
