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

enum BeatFeedback {
    case none
    case correct
    case wrong
    case missed
}

class GameLogic: ObservableObject {
    
    //@Published: updates UI for any changes within the property
    @Published var randomPattern: DrumPattern
    @Published var userPattern: DrumPattern
    
    @Published var engine = RhythmEngine()
    
    @Published var currentExpectedHits: [DrumParts] = []
    @Published var lastCheckResult: CheckResult? = nil
    
    @Published var gameState: GameState = .idle
    @Published var currentStep: Int = 0
    @Published var hasChecked: Bool = false
    
    @Published var randomMessage: String = ""
    @Published var workspaceMessage: String = ""
    
    @Published var dialogueMessages: [String] = []
    @Published var currentDialogueIndex: Int = 0
    
    private var cancellables = Set<AnyCancellable>()
    // add storage for taps
    private var tapTimes: [Date] = [] // for registerTap()
    
    private var checkingStartStep: Int?
    private var hasCompletedCheckingLoop: Bool = false
    private var lastPlayedStep: Int = -1
        
    
    init() {
        let pattern = PatternFactory.generateRandomPattern()
        // self: refers to the current INSTANCE of a class, structure, or enumeration
        self.randomPattern = pattern
        self.userPattern = DrumPattern.empty(bpm: 0)
//        self.currentPattern = pattern
        
        engine.$currentStep
//            .dropFirst()
//            .removeDuplicates()
        // sink: creates a subscriber???? and immediately requests unlimited value.
            .sink { [weak self] _ in
                self?.objectWillChange.send()
                self?.triggerSounds()
            } 
            .store(in: &cancellables) // retain the subscription
        
        // set initial dialogue
        randomMessage = "Press play to play random pattern"
        workspaceMessage = "Recreate the pattern here"
//        dialogueMessages = [
//            "Press play to play random pattern.",
//            "Press randomize to generate a new random pattern",
//            "Press check to reveal the random pattern"
//        ]
        
        print("init GameLogic")
    }
    
//    private var hasSeenStep15: Bool = false

    private func triggerSounds() {
        let step = engine.currentStep
        guard step >= 0 else { return }
        guard step != lastPlayedStep else { return }
        lastPlayedStep = step
        
        let pattern: DrumPattern
        if gameState == .listening {
            pattern = randomPattern
        } else {
            pattern = userPattern
        }
        
        for part in DrumParts.allCases {
            if pattern.steps(for: part)[step].isActive {
                AudioManager.shared.play(part)
            }
        }
        print("triggerSounds(at step \(step)) GameLogic")
        
        // one loop playback for checking
        if gameState == .checking && step == 15 {
            gameState = .result
            engine.stop()
//            engine.currentStep = 15
//            hasCompletedCheckingLoop = true
            print("🟠 Reached step 15")
        }
//        if gameState == .checking && step == 0 && hasCompletedCheckingLoop {
//            hasCompletedCheckingLoop = false
//            gameState = .result
//            engine.stop()
//            engine.currentStep = 0
//
//            print("🔴 Completed checking loop, stopping")
//        }
    }
    
    func newGame() {
        let pattern = PatternFactory.generateRandomPattern()
        randomPattern = pattern
        userPattern = DrumPattern.empty(bpm: 0)
        hasChecked = false
        
        randomMessage = "New random pattern generated"
        
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
        // set dialogue based on what was playing
        if gameState == .listening {
            randomMessage = "Random pattern paused"
        } else if gameState == .recreating {
            workspaceMessage = "Your pattern paused"
        }
        engine.stop()
        gameState = .idle
        lastPlayedStep = -1
        
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
    
    private var clearMessageWorkItem: DispatchWorkItem?
    
    func calculateBPM() -> Double? {
        // check taps should be at least 2, else don't run the code
        guard tapTimes.count >= 2 else { return nil }
        var intervals: [TimeInterval] = []
        
        // measure the interval between each taps tapTimes[i] -> the index of tap
        for i in 1..<tapTimes.count {
            let interval = tapTimes[i].timeIntervalSince(tapTimes[i - 1])
            // add the calculated interval to the intervals array
            intervals.append(interval)
            
            workspaceMessage = "Calculating your BPM..."
            
            // cancel any existing timer
            clearMessageWorkItem?.cancel()
            
            // create new time
            let workItem = DispatchWorkItem { [weak self] in
                self?.workspaceMessage = ""
            }
            clearMessageWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: workItem)
            
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
        
//        workspaceMessage = "BPM set"
        return bpm
    }
    
    func updateUserBPM(from tappedBPM: Double) {
        let clamped = min(max(tappedBPM, RhythmConfig.minBPM), RhythmConfig.maxBPM)
        userPattern.bpm = clamped
        
//        workspaceMessage = "BPM set"
        
        if gameState == .recreating {
            engine.start(bpm: clamped)
        }
        
        print("updateUserBPM() GameLogic")
    }
    
    // ------------ USER WORKSPACE ------------
    
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
    
//    func pausePlayback() {
//        engine.stop()
//        gameState = .idle
//        lastPlayedStep = -1
////        isPlayingUser = false
//        
//        print("pausePlayback() GameLogic")
//    }
    
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
        
        var hiHatFeedback: [BeatFeedback]
        var snareFeedback: [BeatFeedback]
        var kickFeedback: [BeatFeedback]
    }
    
    // at this moment in time, which drums should exists????? what??
    private func expectedParts(at step: Int) -> [DrumParts] {
        guard step >= 0 else { return [] }
        
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
        
        let bpmCorrect = abs(userPattern.bpm - randomPattern.bpm) <= bpmTolerance
        
        let hiHatFeedback = generateFeedback(
            userBeats: userPattern.hiHat,
            correctBeats: randomPattern.hiHat
        )
        let snareFeedback = generateFeedback(
            userBeats: userPattern.snare,
            correctBeats: randomPattern.snare
        )
        let kickFeedback = generateFeedback(
            userBeats: userPattern.kick,
            correctBeats: randomPattern.kick
        )
        
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
            isCorrect: isCorrect,
            hiHatFeedback: hiHatFeedback,
            snareFeedback: snareFeedback,
            kickFeedback: kickFeedback
        )
//        gameState = .result
        return lastCheckResult!
    }
    
    func generateFeedback(userBeats: [BeatSlot], correctBeats: [BeatSlot]) -> [BeatFeedback] {
        var feedback: [BeatFeedback] = []
        
        for i in 0..<16 {
            let userActive = userBeats[i].isActive
            let correctActive = correctBeats[i].isActive
            
            if userActive && correctActive {
                feedback.append(.correct)
            } else if userActive && !correctActive {
                feedback.append(.wrong)
            } else if !userActive && correctActive {
                feedback.append(.missed)
            } else {
                feedback.append(.none)
            }
        }
        return feedback
    }
    
// ---------------  GAME STATE FUNCTIONS ---------------
        
    // Workspace button disabled
    func startListening() {
        gameState = .listening
        lastPlayedStep = -1
        syncPatternToEngine(randomPattern)
        engine.start(bpm: randomPattern.bpm)
        randomMessage = "Playing random pattern..."
        
        print("startListening() GameLogic")
    }
    
    // Workspace editable
    func startRecreating() {
        gameState = .recreating
        lastPlayedStep = -1
        syncPatternToEngine(userPattern)
        
        if userPattern.bpm > 0 {
            engine.start(bpm: userPattern.bpm)
//            workspaceMessage = "Playing your pattern..."
        }
        workspaceMessage = "Playing your pattern..."
        
        print("stratRecreating() GameLogic")
    }
    
    func startChecking() {
        print("🟢 startChecking() called")
        gameState = .checking
        lastPlayedStep = -1
        _ = checkUserPattern()
//        gameState = .checking
        
        checkingStartStep = nil
        hasCompletedCheckingLoop = false
        hasChecked = true
        syncPatternToEngine(userPattern)
        engine.start(bpm: userPattern.bpm)
        randomMessage = "Random pattern revealed!"
        
        print("startChecking() GameLogic")
    }
    
    func nextRound() {
        newGame()
        gameState = .idle
        lastPlayedStep = -1
        
        print("nextRound() GameLogic")
    }
    
// --------------- INSTRUCTIONS ---------------
    
    func setDialogue(_ messages: [String]) {
        dialogueMessages = messages
        currentDialogueIndex = 0
    }
    
    func advanceDialogue() {
        if currentDialogueIndex < dialogueMessages.count - 1 {
            currentDialogueIndex += 1
        } else {
            clearDialogue()
        }
    }
    
    func clearDialogue() {
        dialogueMessages = []
        currentDialogueIndex = 0
    }
}
