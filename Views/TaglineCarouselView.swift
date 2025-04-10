//
//  TaglineCarouselView.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/6/25.
//
import SwiftUI

struct TaglineCarouselView: View {
    let taglines = [
        ("God's Word. Our Voice.", "🗣️"),
        ("Scripture, but make it real.", "💯"),
        ("The Bible, the way we talk.", "🤝"),
        ("Bridging the Gap Between The Word & The Culture.", "🌉"),
        ("From Genesis to Revelation, No Cap.", "📖")
    ]
    
    @State private var currentIndex = 0
    
    var body: some View {
        VStack {
            HStack {
                Text(taglines[currentIndex].0)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                Text(taglines[currentIndex].1)
                    .font(.title2)
            }
            .padding()
            .transition(.slide)
            .animation(.easeInOut(duration: 0.5), value: currentIndex)
        }
        .onAppear {
            startCarousel()
        }
    }
    
    private func startCarousel() {
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            withAnimation {
                currentIndex = (currentIndex + 1) % taglines.count
            }
        }
    }
}
