//
//  ShaderBackground.swift
//  SSC
//
//  Created by Graciella Michelle Siswoyo on 25/02/26.
//

internal import SwiftUI

struct ShaderBackground: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    @State var appear = false
    @State var appear2 = false
    @State var appear3 = false
    @State var appear4 = false

    var body: some View {
        MeshGradient(
            width: 6,
            height: 4,
            points: [
                // row 0
                [0,0], [0.2,0], [0.4,0], [0.6,0], [0.8,0], [1,0],
                // row 1
                [0,appear ? 0.48 : 0.64], [0.2,0.64], [0.4,appear3 ? 0.56 : 0.64], [0.6,appear4 ? 0.56 : 0.64], [0.8,0.64], [1,appear2 ? 0.48 : 0.64],
                // row 2
                [0,appear ? 0.56 : 0.8], [0.2,0.8], [0.4,appear3 ? 0.72 : 0.8], [0.6,appear4 ? 0.72 : 0.8], [0.8,0.8], [1,appear2 ? 0.56 : 0.8],
                // row 3
                [0,1], [0.2,1], [0.4,1], [0.6,1], [0.8,1], [1,1],
            ],
            colors: colors
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                appear.toggle()
            }
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                appear2.toggle()
            }
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                appear3.toggle()
            }
            withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                appear4.toggle()
            }
        }
    }

    private var colors: [Color] {
        if colorScheme == .dark {
            let black = Color.black
            let blackBlue = Color(hex: "#000220")
            let blue = Color(hex: "#00043a")
            let lightBlue = Color(hex: "#000553")
            return [
                // row 0
                black, black, black, black, black, black,
                // row 1
                black, black, black, black, black, black,
                // row 2
                blackBlue, blackBlue, blackBlue, blackBlue, blackBlue, blackBlue,
                // row 3
                appear ? lightBlue : blue, blue, blue, blue, appear3 ? lightBlue : blue, blue
            ]
        } else {
            let white = Color.white
            let whiteBlue = Color(hex: "#bde0fe")
            let lightBlue = Color(hex: "#85c1fd")
            let blue = Color(hex: "#77ade3")
            return [
                // row 0
                white, white, white, white, white, white,
                // row 1
                white, white, white, white, white, white,
                // row 2
                whiteBlue, whiteBlue, whiteBlue, whiteBlue, whiteBlue, whiteBlue,
                // row 3
                appear ? blue : lightBlue, lightBlue, lightBlue, lightBlue, appear3 ? blue : lightBlue, lightBlue,
            ]
        }
    }
}

#Preview {
    ShaderBackground()
}
