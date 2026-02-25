//
//  ShaderBackground.swift
//  SSC
//
//  Created by Graciella Michelle Siswoyo on 25/02/26.
//

internal import SwiftUI

//struct ShaderBackground: View {
//    var body: some View {
//        MeshGradient(
//            width: 2,
//            height: 2,
//            points: [
//                SIMD2<Float>(0,0),
//                SIMD2<Float>(1,0),
//                SIMD2<Float>(0,1),
//                SIMD2<Float>(1,1)
//            ],
//            colors: [
//                .red,
//                .blue,
//                .green,
//                .yellow
//            ]
//        )
//        .ignoresSafeArea()
//    }
//}

struct ShaderBackground: View {
    var body: some View {
        ZStack {
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                // static preview ver
                ShaderMesh(time: 0)
            } else {
                // animated runtime ver
                TimelineView(.animation) { timeline in
                    let time = timeline.date.timeIntervalSinceReferenceDate
                    
                    ShaderMesh(time: time)
                }
            }
        }
        .ignoresSafeArea()
    }
    
    private struct ShaderMesh: View {
        let time: TimeInterval
        
        var body: some View {
            MeshGradient(
                width: 3,
                height: 3,
                points: meshPoints,
                colors: meshColors
            )
        }
        
        private var meshPoints: [SIMD2<Float>] {
            let move = Float(sin(time * 0.3)) * 0.1
            let ripple = Float(cos(time * 0.5)) * 0.08
            
            return [
                SIMD2<Float>(0.0 + move, 0.0),
                SIMD2<Float>(0.5, 0.0 + ripple),
                SIMD2<Float>(1.0 - move,0.0),
                
                SIMD2<Float>(0.0, 0.5 + ripple),
                SIMD2<Float>(0.5 + move, 0.5),
                SIMD2<Float>(1.0, 0.5 - ripple),
                
                SIMD2<Float>(0.0 + ripple, 1.0),
                SIMD2<Float>(0.5, 1.0 - move),
                SIMD2<Float>(1.0 - ripple, 1.0)
            ]
        }
        
        private var meshColors: [Color] {
            [
                .black,
                Color(hex: "#8FD0FF"),
                .black,
                
                    .black,
                Color(hex: "#232323"),
                .black,
                
                    .black,
                .black,
                .black
            ]
        }
    }
}

#Preview {
    ShaderBackground()
}
