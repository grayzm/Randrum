//
//  PatternStore.swift
//  SSC
//
//  Created by Graciella Michelle Siswoyo on 21/02/26.
//

import Foundation
internal import SwiftUI
internal import Combine

// an ObservabelObject that holds a @Published var patterns: [SavedPatterns] array. It persists to UserDefaults as JSON with add(), update(), and delete() methods. Patterns survive app relaunch.

// manages an array of SavedPatterns.
// Persists to UserDefaults as JSON so patterns survive app relaunch.

class PatternStore: ObservableObject {
    
    @Published var patterns: [SavedPattern] = []
    
    private let storageKey = "savedDrumPatterns"
    
    init() {
        load()
        print("PatternStore init - loaded \(patterns.count) patterns")
    }
    
    // --------------- CRUD ---------------
    
    // save a new pattern (appended to the end of the list).
    func add(_ pattern: SavedPattern) {
        patterns.append(pattern)
        save()
        print("PatternStore add() - now \(patterns.count) patterns")
    }
    
    // update an existing pattern in-place (matched by id).
    func update(_ pattern: SavedPattern) {
        if let index = patterns.firstIndex(where: { $0.id == pattern.id }) {
            patterns[index] = pattern
            patterns[index].date = Date() // refresh the date
            save()
            print("PatternStore update() - updated pattern at index \(index)")
        }
    }
    
    // delete a pattern by id.
    func delete(id: UUID) {
        patterns.removeAll { $0.id == id }
        save()
        print("PatternStore delete()")
    }
    
    // delete by index set (for SwiftUI list .onDelete).
    func delete(at offsets: IndexSet) {
        patterns.remove(atOffsets: offsets)
        save()
        print("PatternStore delete(at:)")
    }
    
    // --------------- PERSISTENCE ---------------
    
    private func save() {
        do {
            let data = try JSONEncoder().encode(patterns)
            UserDefaults.standard.set(data, forKey: storageKey)
            print("PatternStore save() - wrote \(data.count) bytes")
        } catch {
            print("PatternStore save() error: \(error)")
        }
    }
    
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            print("PatternStore load() - no saved data found")
            return
        }
        do {
            patterns = try JSONDecoder().decode([SavedPattern].self, from: data)
            print("PatternStore load() - decoded \(patterns.count) patterns")
        } catch {
            print("PatternStore load() error: \(error)")
        }
    }
}
