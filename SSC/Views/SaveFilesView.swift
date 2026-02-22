//
//  SaveFilesView.swift
//  SSC
//
//  Created by Graciella Michelle Siswoyo on 21/02/26.
//

internal import SwiftUI

struct SaveFilesView: View {
    let savedPattern: SavedPattern
    let isPlaying: Bool
    
    let onEdit: () -> Void
    let onPlay: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 40) {
            // file details
            VStack(alignment: .leading, spacing: 10) {
                Text(savedPattern.name)
                    .font(.custom("DepartureMono-Regular", size: 24))
                HStack(spacing: 30) {
                    Text(savedPattern.dateString)
                        .font(.custom("DepartureMono-Regular", size: 20))
                    Text("\(Int(savedPattern.bpm)) BPM")
                        .font(.custom("DepartureMono-Regular", size: 20))
                }
                
            }
            Spacer()
            Button(action: onEdit) {
                Image(systemName: "pencil.line")
                    .font(.system(size: 24))
                    .foregroundStyle(Color(.systemGray2))
            }
            Button(action: onPlay) {
                Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(Color("text"))
            }
            Button(action: onDelete) {
                Image(systemName: "trash.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(Color(.systemGray2))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 2)
                .fill(.clear)
        )
    }
}

#Preview {
    SaveFilesView(
        savedPattern: SavedPattern(
            name: "Test Pattern",
            from: DrumPattern.empty(bpm: 120)
        ),
        isPlaying: false,
        onEdit: {},
        onPlay: {},
        onDelete: {}
    )
}
