//
//  PatternGenerator.swift
//  SSC
//
//  Created by Graciella Michelle Siswoyo on 10/02/26.
//

// PatternGenerator -> creates data

// generateRandomPattern()
// generateHiHat()
// generateSnare()
// generateKick()

import Foundation

func chance(_ probability: Double) -> Bool {
    Double.random(in: 0...1) < probability
}

struct PatternFactory {
    static func generateRandomPattern() -> DrumPattern {
        let hiHatMode = HiHatPattern.allCases.randomElement()!
        let snareMode = SnarePattern.allCases.randomElement()!
        let kickMode = KickPattern.allCases.randomElement()!
        let bpm = Double.random(in: RhythmConfig.minBPM...RhythmConfig.maxBPM)
        
        // generate raw slots
        var hiHatSlots = generateHiHat(part: hiHatMode)
        var snareSlots = generateSnare(part: snareMode)
        var kickSlots = generateKick(part: kickMode)
        
        // safety check: never empty rows
        hiHatSlots = ensureAtLeastOneIsOn(
            hiHatSlots,
            preferredIndices: [0,2,4,6,8,10,12,14]
        )
        snareSlots = ensureAtLeastOneIsOn(
            snareSlots,
            preferredIndices: [4,12] // backbeats
        )
        kickSlots = ensureAtLeastOneIsOn(
            kickSlots,
        preferredIndices: [0,8] // downbeats
        )
        
        // groove balancing
        grooveBalance(
            hiHat: &hiHatSlots,
            kick: &kickSlots,
            snare: &snareSlots
        )
        
        return DrumPattern(
            hiHat: hiHatSlots,
            snare: snareSlots,
            kick: kickSlots,
            bpm: bpm
        )
    }
}

func generateHiHat(part: HiHatPattern) -> [BeatSlot] {
    var slots: [BeatSlot] = Array(repeating: BeatSlot(), count: 16)
    
    switch part {
    case .constant16:
        for i in 0..<16 {
            slots[i].isActive = true
        }
    case .constant8:
        for i in stride(from: 0, to: 16, by: 2) {
            slots[i].isActive = true
        }
    case .constant4:
        for i in stride(from: 0, to: 16, by: 4) {
            slots[i].isActive = true
        }
    case .random16:
        for i in 0..<16 {
            let weight = (i % 4 == 0) ? 0.9 : 0.5
            slots[i].isActive = chance(weight)
        }
    case .random8:
        for i in stride(from: 0, to: 16, by: 2) {
            let weight = (i % 4 == 0) ? 0.9 : 0.6
            slots[i].isActive = chance(weight)
        }
    case .random4:
        for i in stride(from: 0, to: 16, by: 4) {
            slots[i].isActive = chance(0.9)
        }
    }
    
    print("generateHiHat() PatternGenerator")
    
    return slots
}

func generateSnare(part: SnarePattern) -> [BeatSlot] {
    var slots: [BeatSlot] = Array(repeating: BeatSlot(), count: 16)
    
    switch part {
    case .and8:
        for i in [1,3,5,7,9,11,13,15] {
            slots[i].isActive = chance(0.6)
        }
    case .and4:
        for i in [2,6,10,14] {
            slots[i].isActive = chance(0.7)
        }
    case .constant8:
        for i in [0,2,4,6,8,10,12,14] {
            slots[i].isActive = true
        }
    case .constant4:
        for i in [0,4,8,12] {
            slots[i].isActive = true
        }
    case .random8:
        for i in [0,2,4,6,8,10,12,14] {
            let weight = (i == 4 || i == 12) ? 0.8 : 0.4
            slots[i].isActive = chance(weight)
        }
    case .random4:
        for i in [0,4,8,12] {
            let weight = (i == 4 || i == 12) ? 0.9 : 0.3
            slots[i].isActive = chance(weight)
        }
    }
    
    print("generateSnare() PatternGenerator")
    
    return slots
}

func generateKick(part: KickPattern) -> [BeatSlot] {
    var slots: [BeatSlot] = Array(repeating: BeatSlot(), count: 16)
    
    switch part {
    case .and8:
        for i in [1,3,5,7,9,11,13,15] {
            slots[i].isActive = chance(0.5)
        }
    case .and4:
        for i in [2,6,10,14] {
            slots[i].isActive = chance(0.7)
        }
    case .constant8:
        for i in [0,2,4,6,8,10,12,14] {
            slots[i].isActive = true
        }
    case .constant4:
        for i in [0,4,8,12] {
            slots[i].isActive = true
        }
    case .random8:
        for i in [0,2,4,6,8,10,12,14] {
            let weight = (i == 0) ? 0.9 : (i == 8) ? 0.7 : 0.4
            slots[i].isActive = chance(weight)
        }
    case .random4:
        for i in [0,4,8,12] {
            let weight = (i == 0) ? 0.9 : 0.5
            slots[i].isActive = chance(weight)
        }
    }
    
    print("generateKick() PatternGenerator")
    
    return slots
}

func ensureAtLeastOneIsOn(
    _ slots: [BeatSlot],
    preferredIndices: [Int] = [0,4,8,12]
) -> [BeatSlot] {
    
    var slots = slots
    
    // if something is already active, do nothing
    // guard: a control flow statement used to enforce that a condition is met before code execution continues.
    guard slots.allSatisfy({ !$0.isActive }) else {
        return slots
    }
    
    // try strong beats first
    if let strong = preferredIndices.filter({ $0 < slots.count }).randomElement() {
        slots[strong].isActive = true
    } else {
        // fallback safety
        let randomIndex = Int.random(in: 0..<slots.count)
        slots[randomIndex].isActive = true
    }
    
    print("ensureAtLeastOneIsOn() PatternGenerator")
    
    return slots
}

func grooveBalance(
    // inout: By default, value types (like Int, Struct, etc.) are copied when passed to a function. inout makes it so the function interacts with the original data. Function Call: When calling a function with an in-out parameter, you must place an ampersand (&) directly before the variable name to explicitly acknowledge that the original value might be modified.
    hiHat: inout [BeatSlot],
    kick: inout [BeatSlot],
    snare: inout [BeatSlot]
) {
    for i in 0..<16 {
        if hiHat[i].isActive && snare[i].isActive && !kick[i].isActive {
            if chance(0.5) {
                hiHat[i].isActive = false
            }
        }
    }
    
    print("grooveBalance() PatternGenerator")
}
