//
//  WorkspaceProvider.swift
//  SSC
//
//  Created by Graciella Michelle Siswoyo on 21/02/26.
//

// a protocol both GameLogic and CreateLogic conform to, defining the shared interface (pattern, engine, toggle, tp, play, stop). This sets up the foundation to fully genericize the workspace views.

// protocol that captures everything the workspace views need.
// both GameLogic and CreateLogic conform to this.
// views can use @EnvironmentObject var workspace: any WorkspaceProvider - but since EnvironmentObject needs a concrete class, use a type-erased wrapper instead.

import Foundation

protocol WorkspaceProvider: ObservableObject {
    
    // pattern data
    var userPattern: DrumPattern { get set }
    
    // engine state
    var engine: RhythmEngine { get set }
    
    // game/mode state (workspace views check .recreating to show playhead)
    var isPlayingBack: Bool { get set }
    
    // feedback (only used in practice mode; create mode returns nil)
    var lastCheckResult: GameLogic.CheckResult? { get }
    var gameState: GameState { get }
    
    // actions
    func toggleUserBeat(part: DrumParts, index: Int)
    func registerTap()
    func startRecreating()
    func stopPlayback()
    
    // message
    var workspaceMessage: String { get }
}
