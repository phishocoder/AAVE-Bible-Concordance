//
//  ConfettiView.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 4/10/25.
//

//
//  ConfettiView.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/9/25.
//

import SwiftUI

struct ConfettiView: View {
    @State private var confettiPieces: [ConfettiPiece] = []
    
    let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange]
    
    struct ConfettiPiece: Identifiable {
        let id = UUID()
        var position: CGPoint
        var color: Color
        var rotation: Double
        var scale: Double
    }
    
    var body: some View {
        ZStack {
            ForEach(confettiPieces) { piece in
                Rectangle()
                    .fill(piece.color)
                    .frame(width: 8, height: 8)
                    .position(piece.position)
                    .rotationEffect(.degrees(piece.rotation))
                    .scaleEffect(piece.scale)
            }
        }
        .onAppear {
            generateConfetti()
        }
    }
    
    private func generateConfetti() {
        for _ in 0..<100 {
            let randomX = CGFloat.random(in: 0...UIScreen.main.bounds.width)
            let randomY = CGFloat.random(in: 0...UIScreen.main.bounds.height)
            let randomColor = colors.randomElement() ?? .red
            let randomRotation = Double.random(in: 0...360)
            let randomScale = Double.random(in: 0.5...1.5)
            
            let piece = ConfettiPiece(
                position: CGPoint(x: randomX, y: randomY),
                color: randomColor,
                rotation: randomRotation,
                scale: randomScale
            )
            
            confettiPieces.append(piece)
        }
    }
}
