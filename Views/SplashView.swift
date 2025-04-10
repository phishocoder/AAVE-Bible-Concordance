//
//  SplashView.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/18/25.
//

import SwiftUI

struct SplashView: View {
    @EnvironmentObject private var appState: AppState
    @State private var currentIndex = 0
    @State private var opacity = 0.0
    @Environment(\.colorScheme) var colorScheme
    
    let taglines = [
        ("God's Word. Our Voice.", "🗣️"),
        ("Scripture, but make it real.", "💯"),
        ("The Bible, the way we talk.", "🤝"),
        ("Bridging the Gap Between The Word & The Culture.", "🌉"),
        ("From Genesis to Revelation, No Cap.", "📖")
    ]
    
    let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color(UIColor.dynamicBackground)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // AAVE Logo and Title
                VStack(spacing: 5) {
                    HStack(spacing: 0) {
                        Text("A")
                            .font(.system(size: 70, weight: .bold, design: .default))
                            .foregroundColor(.red)
                        
                        Text("A")
                            .font(.system(size: 70, weight: .bold, design: .default))
                            .foregroundColor(Color(UIColor.aaveLogoSecondA))
                            .overlay(
                                Text("A")
                                    .font(.system(size: 70, weight: .bold, design: .default))
                                    .foregroundColor(Color(UIColor.aaveLogoSecondAOutline))
                                    .opacity(colorScheme == .dark ? 1.0 : 0.0)
                            )
                        
                        Text("V")
                            .font(.system(size: 70, weight: .bold, design: .default))
                            .foregroundColor(.yellow)
                        
                        Text("E")
                            .font(.system(size: 70, weight: .bold, design: .default))
                            .foregroundColor(.green)
                    }
                    
                    Text("Bible Concordance")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
                .padding(.bottom, 30)
                
                // Rotating Taglines
                VStack(spacing: 10) {
                    Text(taglines[currentIndex].0)
                        .font(.title2)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .transition(.opacity)
                        .id(currentIndex)
                    
                    Text(taglines[currentIndex].1)
                        .font(.system(size: 48))
                }
                
                Spacer()
                
                // Progress and Button
                VStack(spacing: 16) {
                    ProgressView(value: appState.loadingProgress)
                        .progressViewStyle(.linear)
                        .tint(colorScheme == .dark ? .white : .black)
                        .padding(.horizontal)
                    
                    if appState.isInitialLoadComplete {
                        Button(action: {
                            withAnimation {
                                appState.continueToApp()
                            }
                        }) {
                            Text("Start Reading")
                                .font(.headline)
                                .foregroundColor(colorScheme == .dark ? .black : .white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(colorScheme == .dark ? Color.white : Color.black)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        .transition(.opacity)
                    }
                }
            }
            .padding(.bottom, 40)
            .padding(.horizontal)
        }
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeIn(duration: 1.0)) {
                opacity = 1.0
            }
        }
        .onReceive(timer) { _ in
            withAnimation {
                currentIndex = (currentIndex + 1) % taglines.count
            }
        }
    }
}

#Preview {
    SplashView()
        .environmentObject(AppState())
}
