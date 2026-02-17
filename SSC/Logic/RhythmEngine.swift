//
//  RhythmEngine.swift
//  SSC
//
//  Created by Graciella Michelle Siswoyo on 10/02/26.
//

// Engine -> drives time

import Foundation
internal import Combine

// has to be outside RhythmEngine
struct RhythmConfig {
    static let minBPM: Double = 60
    static let maxBPM: Double = 130
}

class RhythmEngine: ObservableObject {
    
    struct DrumTrack {
        let name: String
        var steps: [BeatSlot]
    }
    
    @Published var currentStep: Int = -1
    @Published var tracks: [DrumTrack] = [
        DrumTrack(name: "HiHat", steps: Array(repeating: BeatSlot(isActive: false), count: 16)),
        DrumTrack(name: "Snare", steps: Array(repeating: BeatSlot(isActive: false), count: 16)),
        DrumTrack(name: "Kick", steps: Array(repeating: BeatSlot(isActive: false), count: 16))
    ]
    @Published var stepPulse: Bool = false
    
    var isRunning: Bool {
        return timer != nil
    }
    
    private var timer: Timer?
    
    // Double: decimal value
    func start(bpm: Double) {
        print("🔵 start() called - currentStep before: \(currentStep)")
        stop()
        
        let interval = 60.0 / bpm / 4.0 // 16th notes
        
        // currentStep is already -1 from stop(), don't set it again
        
        timer = Timer(
            timeInterval: interval,
            target: self,
            selector: #selector(tick),
            userInfo: nil,
            repeats: true
        )
        RunLoop.current.add(timer!, forMode: .common)
        
        print("start (\(bpm) BPM) RhythmEngine")
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        currentStep = -1
        
        print("stop() RhythmEngine")
    }
    
    func load(pattern: DrumPattern) {
        tracks[0].steps = pattern.hiHat.map { BeatSlot(isActive: $0.isActive) }
        tracks[1].steps = pattern.snare.map { BeatSlot(isActive: $0.isActive) }
        tracks[2].steps = pattern.kick.map { BeatSlot(isActive: $0.isActive) }
        
        print("load (\(pattern)) RhythmEngine")
    }
    
    @objc private func tick() {
        let totalSteps = 16
        currentStep = (currentStep + 1) % totalSteps
        stepPulse.toggle()
        
        print("🔴 tick, step: \(currentStep) RhythmEngine")
    }
    
    func toggle(trackIndex: Int, stepIndex: Int) {
        guard tracks.indices.contains(trackIndex),
              tracks[trackIndex].steps.indices.contains(stepIndex)
        else { return }
        
        tracks[trackIndex].steps[stepIndex].isActive.toggle()
        
        print("toggle, track: \(trackIndex), step: \(stepIndex) RhythmEngine")
    }
    
    func generateRandomBPM() -> Double {
        Double.random(in: RhythmConfig.minBPM...RhythmConfig.maxBPM)
        
    }
}




