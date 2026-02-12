//
//  BeatSlot.swift
//  SSC
//
//  Created by Graciella Michelle Siswoyo on 10/02/26.
//

import Foundation

// represents one button
struct BeatSlot: Identifiable, Equatable { // to identify (identifiable) and compare (equatable)
    let id = UUID() // a unique identifier
    var isActive: Bool = false
    
    var velocity: Double = 1.0
}
