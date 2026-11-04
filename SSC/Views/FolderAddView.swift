//
//  FolderAddView.swift
//  SSC
//
//  Created by Graciella Michelle Siswoyo on 23/02/26.
//

internal import SwiftUI

struct FolderAddView: View {
    
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [6]))
                    .frame(width: 70, height: 55)
//                    .foregroundStyle(Color.gray.opacity(0.5))
                    .foregroundStyle(Color("text").opacity(0.5))
                Image(systemName: "plus")
                    .font(.title)
            }
            Text("Create")
                .font(.custom("DepartureMono-Regular", size: 16))
        }
        .padding()
        .contentShape(Rectangle())
        .onTapGesture {
            action()
        }
        .frame(height: 110, alignment: .topLeading)

    }
}

#Preview {
    FolderAddView(action: {})
}
