//
//  FolderView.swift
//  SSC
//
//  Created by Graciella Michelle Siswoyo on 22/02/26.
//

internal import SwiftUI

struct FolderView: View {
    let savedPattern: SavedPattern
    
    let onOpen: () -> Void
    let onLongPress: () -> Void
    //    let onDelete: () -> Void
    //    let onRename: (String) -> Void
    
    //    @State private var showInfo = false
    //    @State private var showDeleteAlert = false
    //    @State private var isRenaming = false
    //    @State private var newName = ""
    
    @GestureState private var isPressed = false
    
    var body: some View {
        //        ZStack {
        //            // background dim when panel is visible
        //            if showInfo {
        //                Color.black.opacity(0.15)
        //                    .ignoresSafeArea()
        //                    .onTapGesture {
        //                        withAnimation{
        //                            showInfo = false
        //                            isRenaming = false
        //                        }
        //                    }
        //            }
        
        // folder content
        VStack(spacing: 16) {
            Image(systemName: "folder.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 55)
                .foregroundStyle(Color("stroke"))
            
            Text(savedPattern.name)
                .font(.custom("DepartureMono-Regular", size: 18))
                .lineLimit(2)
        }
        .padding()
        .contentShape(Rectangle())
        .scaleEffect(isPressed ? 0.95 : 1)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onTapGesture {
            onOpen()
        }
        .gesture(
            LongPressGesture(minimumDuration: 0.4)
                .updating($isPressed) { currentState, state, _ in
                    state = currentState
                }
                .onEnded { _ in
                    onLongPress()
                }
        )
    }
}
            
//            // finder-style info panel
//            if showInfo {
//                finderInfoPanel
//                    .transition(.scale.combined(with: .opacity))
//                    .zIndex(1)
//            }
//        }
//        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: showInfo)
//        .alert("Delete Pattern?", isPresented: $showDeleteAlert) {
//            Button("Delete", role: .destructive) {
//                onDelete()
//                showInfo = false
//            }
//            Button("Cancel", role: .cancel) {}
//        } message: {
//            Text("This pattern will be permanently deleted.")
//        }
//    }
//}

//extension FolderView {
//    
//    private var longPressGesture: some Gesture {
//        LongPressGesture(minimumDuration: 0.4)
//            .updating($isPressed) { currentState, gestureState, _ in
//                gestureState = currentState
//            }
//            .onEnded { _ in
//                withAnimation {
//                    showInfo = true
//                }
//            }
//    }
//    
//    private var finderInfoPanel: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            if isRenaming {
//                TextField("New name", text: $newName)
//                    .textFieldStyle(.roundedBorder)
//                
//                Button("Save") {
//                    onRename(newName)
//                    isRenaming = false
//                }
//            } else {
//                Text(savedPattern.name)
//                    .font(.custom("DepartureMono-Regular", size: 20))
//                
//                Divider()
//                
//                HStack {
//                    Text("Created:")
//                    Spacer()
//                    Text(savedPattern.dateString)
//                }
//                HStack {
//                    Text("BPM:")
//                    Spacer()
//                    Text("\(Int(savedPattern.bpm))")
//                }
//                
//                Divider()
//                
//                Button {
//                    newName = savedPattern.name
//                    isRenaming = true
//                } label: {
//                    Label("Rename", systemImage: "pencil")
//                }
//                
//                Button(role: .destructive) {
//                    showDeleteAlert = true
//                } label: {
//                    Label("Delete Pattern", systemImage: "trash.fill")
//                }
//            }
//        }
//        .padding(20)
//        .frame(width: 260)
//        .background(
//            RoundedRectangle(cornerRadius: 12)
//                .fill(Color(.systemBackground))
//                .shadow(radius: 20)
//        )
//    }
//}

#Preview {
    FolderView(
        savedPattern: SavedPattern(
            name: "Test Pattern",
            from: DrumPattern.empty(bpm: 120)
        ),
        onOpen: {},
        onLongPress: {}
//        onDelete: {},
//        onRename: { _ in }
    )
}
