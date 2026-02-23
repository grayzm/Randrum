//
//  SavedPattern.swift
//  SSC
//
//  Created by Graciella Michelle Siswoyo on 21/02/26.
//

import Foundation

// a codable, identifiable struct that stores a pattern's name, date, BPM, and three arrays of 16 booleans. Has init to convert from a live DrumPattern, and toDrumPattern() to convert back for editing/playback

// a codable version of DrumPattern that can be saved to disk.
// BeatSlot has a UUID which isn't stable for saving, so store only the isActive booleans and recreate BeatSlots on load.

struct SavedPattern: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var date: Date
    var bpm: Double
    
    var hiHat: [Bool]
    var snare: [Bool]
    var kick: [Bool]
    
    // convert from a live DrumPattern into a SavedPattern
    init(name: String, from pattern: DrumPattern) {
        self.id = UUID()
        self.name = name
        self.date = Date()
        self.bpm = pattern.bpm
        self.hiHat = pattern.hiHat.map { $0.isActive }
        self.snare = pattern.snare.map { $0.isActive }
        self.kick = pattern.kick.map { $0.isActive }
    }
    
    // convert back to a live DrumPattern for playback/editing
    func toDrumPattern() -> DrumPattern {
        DrumPattern(
            hiHat: hiHat.map { BeatSlot(isActive: $0) },
            snare: snare.map { BeatSlot(isActive: $0) },
            kick: kick.map { BeatSlot(isActive: $0) },
            bpm: bpm
        )
    }
    
    // formated date string for display
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd / MM / yyyy"
        return formatter.string(from: date)
    }
}
