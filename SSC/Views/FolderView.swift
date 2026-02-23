//
//  FolderView.swift
//  SSC
//
//  Created by Graciella Michelle Siswoyo on 22/02/26.
//

internal import SwiftUI

struct FolderView: View {
    
    let savedPattern: SavedPattern
    let namespace: Namespace.ID
    let onOpen: () -> Void
    let onLongPress: (CGRect) -> Void
    
    @GestureState private var isPressed = false
    
    var body: some View {
        GeometryReader { geo in
            // folder content
            VStack(spacing: 12) {
                Image(systemName: "folder.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 55)
                    .foregroundStyle(Color("icon"))
                    .matchedGeometryEffect(
                        id: "folder-\(savedPattern.id)",
                        in: namespace
                    )
                
                Text(savedPattern.name)
                    .font(.custom("DepartureMono-Regular", size: 18))
                    .lineLimit(2)
            }
            .padding()
            .contentShape(Rectangle())
//            .scaleEffect(isPressed ? 0.95 : 1)
//            .animation(.easeInOut(duration: 0.1), value: isPressed)
            .onTapGesture {
                onOpen()
            }
            .onLongPressGesture {
                let frame = geo.frame(in: .global)
                onLongPress(frame)
            }
        }
        .frame(height: 110) // prevents GeometryReader expansion
    }
}

#Preview {
    PreviewWrapper()
}
private struct PreviewWrapper: View {
    
    @Namespace private var previewNamespace
    
    var body: some View {
        FolderView(
            savedPattern: SavedPattern(
                name: "Test Pattern",
                from: DrumPattern.empty(bpm: 120)
            ),
            namespace: previewNamespace,
            onOpen: {},
            onLongPress: { _ in }
        )
        .padding()
        .background(Color.gray.opacity(0.2))
    }
}
