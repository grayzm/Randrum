//
//  Notes.swift
//  SSC
//
//  Created by Graciella Michelle Siswoyo on 08/02/26.
//

// static: class-level members that belong to the type itself, rather than an instance of the type. This means that they can be called without having to create an instance of the class or struct.

// ObservableObjects: Your data model class conforms to the ObservableObject protocol, signaling to SwiftUI that it can be watched for changes.

// class: a class is a blueprint for creating objects and is used to manage shared, mutable state. Unlike struct, it supports inheritence.

// private var: applies the concept of access control, limiting the visibility and modification of a variable to the scope of its immediate declaration. When paired with SwiftUI property wrappers, private ensures proper data flow and prevents conflicts with SwiftUI's storage management.

// $: binds data. Used with property wrappers (like @State, @Binding, @ObservedObject, etc.) to access their projected value, which is typically a Binding. This creates a two-way connection to the underlying data, allowing views to both read and write the value.

// inout: By default, value types (like Int, Struct, etc.) are copied when passed to a function. inout makes it so the function interacts with the original data. Function Call: When calling a function with an in-out parameter, you must place an ampersand (&) directly before the variable name to explicitly acknowledge that the original value might be modified.

// CaseIterable: a Swift protocol that allows you to access a collection of all the cases within an enumeration (enum).

// UUID: Universally Unique Identifier - The primary purpose of a UUID is to provide an identifier that has an extremely low probability of duplication, even when generated independently on different systems.

// Identifiable: a Swift protocol that guarantees a type has a unique identifier property, allowing individual instances to be distinguished within collections.

// Equatable: a protocol that allows you to compare two instances of a custom type (like a struct or enum) to determine if they are equal using the == operator.

// -------------------------------------------

// Playback Engine Flow:
// RhythmEngine timer tick -> GameLogic.handleStepTick(setp) -> AudioManager.playSound(...) -> Views highlight current step

// User Sequence:
// User presses "Randomize" -> GameLogic.newGame() -> randomPattern = generateRandomPattern() && userPattern = DrumPattern.empty(bpm: ) -> SwiftUI sees @Published change -> RandomPatternView redraws, WorkspaceView clears grid

// Button tap (user taps hiHat index 3):
// WorkspaceView Button Tap -> game.toggleUserBeat(.hiHat, index: 3) -> userPattern.hiHat[3].isActive.toggle() -> @Published triggers UI update -> Button turns blue + sound plays
