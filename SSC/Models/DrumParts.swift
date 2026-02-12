//
//  DrumParts.swift
//  SSC
//
//  Created by Graciella Michelle Siswoyo on 10/02/26.
//

import Foundation

enum DrumParts: CaseIterable {
    case hiHat, snare, kick
}

enum HiHatPattern: CaseIterable {
    case constant16, constant8, constant4
    case random16, random8, random4
}

enum SnarePattern: CaseIterable {
    case and8, and4
    case constant8, constant4
    case random8, random4
}

enum KickPattern: CaseIterable {
    case and8, and4
    case constant8, constant4
    case random8, random4
}
