//
//  GameLogic.swift
//  SSC
//
//  Created by Graciella Michelle Siswoyo on 10/02/26.
//

// GameLogic -> owns data

// ----- the only place where state changes -----
// @Published var randomPattern
// @Published var userPattern
// @Published var revealPattern
// @Published var isPlaying

// newGame()
// toggleUserBeat()
// checkUserPattern()
// playRandomPattern()
// playUserPattern()

import Foundation
internal import Combine

enum GameState {
    case idle
    case listening     // user listens to random pattern
    case recreating    // user recreates pattern
    case checking      // check button pressed, logic compares patterns
    case result
}

// ObservableObjects: Your data model class conforms to the ObservableObject protocol, signaling to SwiftUI that it can be watched for changes.
// class: a class is a blueprint for creating objects and is used to manage shared, mutable state. Unlike struct, it supports inheritence.
class GameLogic: ObservableObject {
    
    
    //@Published: updates UI for any changes within the property
    @Published var randomPattern: DrumPattern
    @Published var userPattern: DrumPattern
    
    private func triggerSounds() {
        let pattern = gameState == .recreating ? userPattern : randomPattern
        let step = engine.currentStep
        guard step >= 0 else { return }
        
        for part in DrumParts.allCases {
            if pattern.steps(for: part)[step].isActive {
                AudioManager.shared.play(part)
            }
        }
        
        print("triggerSounds(at step \(step)) GameLogic")
    }
    
    @Published var engine = RhythmEngine()
    
//    @Published var isPlayingUser: Bool = false
//    @Published var revealPattern: Bool = false
    
    @Published var currentExpectedHits: [DrumParts] = []
    @Published var lastCheckResult: CheckResult? = nil
    
    @Published var gameState: GameState = .idle
    @Published var currentStep: Int = 0
    
    // private var: applies the concept of access control, limiting the visibility and modification of a variable to the scope of its immediate declaration. When paired with SwiftUI property wrappers, private ensures proper data flow and prevents conflicts with SwiftUI's storage management.
    private var cancellables = Set<AnyCancellable>()
    // add storage for taps
    private var tapTimes: [Date] = [] // for registerTap()
    
    
//    var currentPattern: DrumPattern
    
    init() {
        let pattern = PatternFactory.generateRandomPattern()
        // self: refers to the current INSTANCE of a class, structure, or enumeration
        self.randomPattern = pattern
        self.userPattern = DrumPattern.empty(bpm: pattern.bpm)
//        self.currentPattern = pattern
        
        // $: binds data. Used with property wrappers (like @State, @Binding, @ObservedObject, etc.) to access their projected value, which is typically a Binding. This creates a two-way connection to the underlying data, allowing views to both read and write the value.
        engine.$currentStep
        // sink: creates a subscriber???? and immediately requests unlimited value.
            .sink { [weak self] _ in
                self?.objectWillChange.send()
                self?.triggerSounds()
            } // &: allows a function to modify the original value of a variable, rather than just working on a local copy of the value.
            .store(in: &cancellables) // retain the subscription
        
        print("init GameLogic")
    }
    
    
    func newGame() {
        let pattern = PatternFactory.generateRandomPattern()
        randomPattern = pattern
        userPattern = DrumPattern.empty(bpm: pattern.bpm)
//        currentPattern = pattern
        
//        engine.load(pattern: currentPattern)
        
        print("newGame() GameLogic")
    }
    
    func toggleRandomPlayback() {
        if gameState == .listening {
            stopPlayback()
        } else {
            startListening()
        }
        
        print("toggleRandomPlayback() GameLogic")
    }
    
    func stopPlayback() {
        engine.stop()
        gameState = .idle
        
        print("stopPlayback() GameLogic")
    }
    
    // for randomPattern play button
//    func playRandomPattern() {
//        gameState = .listening
//        
//        syncPatternToEngine(randomPattern)
//        engine.start(bpm: randomPattern.bpm)
////        isPlayingUser = false
//        
//        print("playRandomPattern() GameLogic")
//    }
    
    // ------------ METRONOME ------------
    
    // user taps -> store timestamps -> calculate average interval -> convert to BPM -> clamp to 80...160
    func registerTap() {
        let now = Date()
        tapTimes.append(now)
        
        // keep only last 6 taps for stability
        if tapTimes.count > 6 {
            tapTimes.removeFirst()
        }
        // try calculating BPM immediately
        if let bpm = calculateBPM() {
            updateUserBPM(from: bpm)
        }
        
        print("registerTap() GameLogic")
    }
    
    func calculateBPM() -> Double? {
        // check taps should be at least 2, else don't run the code
        guard tapTimes.count >= 2 else { return nil }
        var intervals: [TimeInterval] = []
        
        // measure the interval between each taps tapTimes[i] -> the index of tap
        for i in 1..<tapTimes.count {
            let interval = tapTimes[i].timeIntervalSince(tapTimes[i - 1])
            // add the calculated interval to the intervals array
            intervals.append(interval)
            
            print("calculateBPM() GameLogic")
        }
        
        // check intervals should contain value, else don't run the code
        guard !intervals.isEmpty else { return nil }
        // calculate the average interval
        // reduce starts with a value (in this case 0) and keeps combining each item in the array using the operation you give (in this case +)
        let averageInterval = intervals.reduce(0, +) / Double(intervals.count)
        // intervals.reduce(0, +) example:
        // intervals = [0.5, 0.6, 0.4] -> 0 + 0.5 + 0.6 + 0.4 = 1.5
        
        // BPM = 60 seconds per beat
        let bpm = 60.0 / averageInterval
        
        print("calculateBPM() GameLogic")
        
        return bpm
    }
    
    func updateUserBPM(from tappedBPM: Double) {
        let clamped = min(max(tappedBPM, RhythmConfig.minBPM), RhythmConfig.maxBPM)
        userPattern.bpm = clamped
        
//        if isPlayingUser {
        if gameState == .recreating {
            engine.start(bpm: clamped)
        }
        
        print("updateUserBPM() GameLogic")
    }
    
    // ------------ USER WORKSPACE ------------
    func toggleUserBeat(part: DrumParts, index: Int) {
        if gameState != .recreating {
            gameState = .recreating
        }
        
        switch part {
        case .hiHat:
            userPattern.hiHat[index].isActive.toggle()
        case .snare:
            userPattern.snare[index].isActive.toggle()
        case .kick:
            userPattern.kick[index].isActive.toggle()
        }
        syncPatternToEngine(userPattern)
        
        print("toggleUserBeat(\(part), \(index)) GameLogic")
        
        let currentStep = engine.currentStep
        let expected = expectedParts(at: currentStep)
        
        if expected.contains(part) {
            print("Correct timing")
        } else {
            print("Off timing")
        }
    }
    
    func deleteRow(_ part: DrumParts) {
        switch part {
        case .hiHat:
            userPattern.hiHat = Array(repeating: BeatSlot(), count: 16)
        case .snare:
            userPattern.snare = Array(repeating: BeatSlot(), count: 16)
        case .kick:
            userPattern.kick = Array(repeating: BeatSlot(), count: 16)
        }
        
        print("deleteRow(\(part)) GameLogic")
    }
    
    private func syncPatternToEngine(_ pattern: DrumPattern) {
        engine.tracks[0].steps = pattern.hiHat.map { BeatSlot(isActive: $0.isActive) }
        engine.tracks[1].steps = pattern.snare.map { BeatSlot(isActive: $0.isActive) }
        engine.tracks[2].steps = pattern.kick.map { BeatSlot(isActive: $0.isActive) }
        
        print("syncPatternToEngine() GameLogic")
    }
    
    // for userPattern play button
//    func playUserPattern() {
//        syncPatternToEngine(userPattern)
//        engine.start(bpm: userPattern.bpm)
////        isPlayingUser = true
//        
//        print("playUserPattern() GameLogic")
//    }
    
    func pausePlayback() {
        engine.stop()
//        isPlayingUser = false
        
        print("pausePlayback() GameLogic")
    }
    
    // new handleStepTick() after adding GameState
    func handleStepTick() {
        switch gameState {
        case .listening:
            syncPatternToEngine(randomPattern)
        case .recreating:
            syncPatternToEngine(userPattern)
        default:
            break
        }
        
        print("handleStepTick() GameLogic")
    }
    
//    func handleStepTick(step: Int) {
//        
//        // pattern maybe isPlayingUser. If it is: pattern = userPattern, if not: pattern = randomPattern
//        let pattern = gameState == .listening ? randomPattern : userPattern
//        
//        if pattern.hiHat[step].isActive {
//            // play hiHat
//            AudioManager.shared.play(.hiHat)
//            print("HiHat")
//        }
//        if pattern.snare[step].isActive {
//            // play snare
//            AudioManager.shared.play(.snare)
//            print("Snare")
//        }
//        if pattern.kick[step].isActive {
//            // play kick
//            AudioManager.shared.play(.kick)
//            print("Kick")
//        }
//        
//        print("handleStepTick(\(step)) GameLogic")
//    }
    
    // ------------ CHECKING ------------
    struct CheckResult {
        var bpmCorrect: Bool
        var hiHatCorrect: Bool
        var snareCorrect: Bool
        var kickCorrect: Bool
        var isCorrect: Bool
    }
    
    // at this moment in time, which drums should exists????? what??
    private func expectedParts(at step: Int) -> [DrumParts] {
        let pattern = gameState == .listening ? randomPattern : userPattern
        var parts: [DrumParts] = []
        
        if pattern.hiHat[step].isActive { parts.append(.hiHat) }
        if pattern.snare[step].isActive { parts.append(.snare) }
        if pattern.kick[step].isActive { parts.append(.kick) }
        
        return parts
    }
    
    func checkUserPattern() -> CheckResult {
        gameState = .checking
        
        // BPM check (with tolerance)
        let bpmTolerance: Double = 2
        // abs:  is a global function that returns the absolute value of a given number. It converts negative numbers into positive numbers, while positive numbers and zero remain unchanged.
        let bpmCorrect = abs(userPattern.bpm - randomPattern.bpm) <= bpmTolerance
        
        let hiHatCorrect = userPattern.hiHat == randomPattern.hiHat
        let snareCorrect = userPattern.snare == randomPattern.snare
        let kickCorrect = userPattern.kick == randomPattern.kick
        
        let isCorrect = bpmCorrect && hiHatCorrect && snareCorrect && kickCorrect
        
        print("checkUserPattern() GameLogic")
        
        lastCheckResult = CheckResult(
            bpmCorrect: bpmCorrect,
            hiHatCorrect: hiHatCorrect,
            snareCorrect: snareCorrect,
            kickCorrect: kickCorrect,
            isCorrect: isCorrect
        )
        gameState = .result
        return lastCheckResult!
    }
// ---------------  GAME STATE FUNCTIONS ---------------
    // Workspace button disabled
    func startListening() {
        gameState = .listening
        syncPatternToEngine(randomPattern)
        engine.start(bpm: randomPattern.bpm)
        
        print("startListening() GameLogic")
    }
    
    // Workspace editable
    func startRecreating() {
        gameState = .recreating
        syncPatternToEngine(userPattern)
        
        print("stratRecreating() GameLogic")
    }
    
    func startChecking() {
        gameState = .checking
        _ = checkUserPattern()
        
        print("startChecking() GameLogic")
    }
    
    func nextRound() {
        newGame()
        gameState = .idle
        
        print("nextRound() GameLogic")
    }
}
