//
//  HelpView.swift
//  SSC
//
//  Created by Graciella Michelle Siswoyo on 20/02/26.
//

internal import SwiftUI

struct HelpView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                header
                
                helpSection(
                    title: "Creating a Pattern",
                    description:"""
                        Tap on the grid to activate beats.
                        Each row represents a drum kit: Hi-Hat, Snare, and Kick.
                        Active beats will play when the pattern runs.
                        Use Tap Tempo to set the BPM manually.
                        """
                )
                
                helpSection(
                    title: "Playback",
                    description: """
                        Press Play to hear your pattern loop.
                        Press Stop to stop playback.
                        You can edit beats while the pattern is playing.
                        """
                )
                
                helpSection(
                    title: "Saving",
                    description: """
                        The Save button becomes active once you make changes.
                        If you're editing an existing pattern, Save updates it.
                        If it's new, you'll be asked to name it.
                        """
                )
                
                helpSection(
                    title: "Saved Patterns",
                    description: """
                        Tap a folder to load it into the workspace.
                        Long-press a folder to rename or delete it.
                        Use the Create folder to start a new blank pattern.
                        """
                )
                
                helpSection(
                    title: "Unsaved Changes",
                    description: """
                        If you modify a pattern, the Save button will enable.
                        Make sure to save before switching patterns to keep your changes.
                        """
                )
            }
            .padding(30)
        }
        .background(
            LinearGradient(
                colors: [Color("background1"), Color("background2")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
}

extension HelpView {
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How to Use Randrum")
                .font(.custom("DepartureMono-Regular", size: 28))
            Text("Build rhythms. Experiment. Save your grooves.")
                .font(.custom("DepartureMono-Regular", size: 16))
                .foregroundStyle(Color("stroke").opacity(0.7))
        }
    }
    
    private func helpSection(title: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.custom("DepartureMono-Regular", size: 20))
            Text(description)
                .font(.custom("DepartureMono-Regular", size: 16))
                .foregroundStyle(Color("text").opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("bnw").opacity(0.08))
        )
    }
}

#Preview {
    HelpView()
}
