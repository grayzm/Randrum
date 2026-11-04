//
//  AudioManager.swift
//  SSC
//
//  Created by Graciella Michelle Siswoyo on 10/02/26.
//

import AVFoundation

class AudioManager {
    
    static let shared = AudioManager()
    
    private var hiHatPlayers: [AVAudioPlayer] = []
    private var snarePlayers: [AVAudioPlayer] = []
    private var kickPlayers: [AVAudioPlayer] = []
    
    private var hiHatIndex = 0
    private var snareIndex = 0
    private var kickIndex = 0
    
    private let poolSize = 5
    
    private init() {
        setupAudioPlayers()
    }
    
    private func setupAudioPlayers() {
        // pool of players for each drum part
        for i in 0..<poolSize {
            if let hiHat = createPlayer(for: "hiHat") {
                hiHatPlayers.append(hiHat)
                print("Created hiHat player \(i)")
            } else {
                print("Failed to create hiHat player \(i)")
            }
            if let snare = createPlayer(for: "snare") {
                snarePlayers.append(snare)
                print("Created snare player \(i)")
            } else {
                print("Failed to create snare player \(i)")
            }
            if let kick = createPlayer(for: "kick") {
                kickPlayers.append(kick)
                print("kick hiHat player \(i)")
            } else {
                print("Failed to create kick player \(i)")
            }
        }
        print("Setup complete - HiHat: \(hiHatPlayers.count), Snare: \(snarePlayers.count), Kick: \(kickPlayers.count)")
    }
    
    private func createPlayer(for soundName: String) -> AVAudioPlayer? {
        print("Attempting to load sound: \(soundName)")
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "wav") else {
            print("Sound file not found: \(soundName)")
            print("Bundle path: \(Bundle.main.bundlePath)")
            return nil
        }
        
        print("Found URL: \(url)")
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            print("Player created successfully for \(soundName)")
            return player
        } catch {
            print("Error loading sound: \(error)")
            return nil
        }
    }
    
    func play(_ part: DrumParts) {
        print("Playing: \(part)")
        
        let players: [AVAudioPlayer]
        let index: Int
        
        switch part {
        case .hiHat:
            print("hiHat selected")
            players = hiHatPlayers
            index = hiHatIndex
            hiHatIndex = (hiHatIndex + 1) % poolSize
        case .snare:
            print("snare selected")
            players = snarePlayers
            index = snareIndex
            snareIndex = (snareIndex + 1) % poolSize
        case .kick:
            print("kick selected")
            players = kickPlayers
            index = kickIndex
            kickIndex = (kickIndex + 1) % poolSize
        }
        print("Players count: \(players.count)")
        guard !players.isEmpty else {
            print("No players available")
            return
        }
        
        let player = players[index]
        player.currentTime = 0
        player.play()
        print("Playing sound")
    }
}
