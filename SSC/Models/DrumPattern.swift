//
//  DrumPattern.swift
//  SSC
//
//  Created by Graciella Michelle Siswoyo on 10/02/26.
//

import Foundation
internal import Combine




struct DrumPattern {
    var hiHat: [BeatSlot] 
    var snare: [BeatSlot]
    var kick: [BeatSlot]
    var bpm: Double
    
    static func empty(bpm: Double) -> DrumPattern {
        DrumPattern(
            hiHat: Array(repeating: BeatSlot(), count: 16),
            snare: Array(repeating: BeatSlot(), count: 16),
            kick: Array(repeating: BeatSlot(), count: 16),
            bpm: bpm
        )
    }
}
