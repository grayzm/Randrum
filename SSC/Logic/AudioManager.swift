//
//  AudioManager.swift
//  SSC
//
//  Created by Graciella Michelle Siswoyo on 10/02/26.
//

import AVFoundation

class AudioManager {
    
    static let shared = AudioManager()
    
    private var players: [DrumParts: AVAudioPlayer] = [:]
    
    init() {
        load(.hiHat, file: "hiHat")
        load(.snare, file: "snare")
        load(.kick, file: "kick")
    }
    
    private func load(_ part: DrumParts, file: String) {
        guard let url = Bundle.main.url(forResource: file, withExtension: "wav") else { return }
        players[part] = try? AVAudioPlayer(contentsOf: url)
        players[part]?.prepareToPlay()
    }
    
    func play(_ part: DrumParts) {
        players[part]?.currentTime = 0
        players[part]?.play()
    }
}
