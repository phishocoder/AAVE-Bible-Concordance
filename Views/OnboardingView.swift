//
//  OnboardingView.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 9/4/25.
//

//
//  OnboardingView.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/25/25.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0
    @Environment(\.colorScheme) var colorScheme
    
    let pages = [
        OnboardingPage(
            title: "Welcome to the AAVE Bible",
            subtitle: "God's Word. Our Voice.",
            description: "The complete Bible translated in African American Vernacular English. From Genesis to Revelation.",
            icon: "book.fill",
            color: .blue
        ),
        OnboardingPage(
            title: "Share Verses",
            subtitle: "Spread the Word",
            description: "Tap any verse to share it with friends and family. The Word hits different when it's in our voice.",
            icon: "square.and.arrow.up",
            color: .green
        ),
        OnboardingPage(
            title: "Create Verse Images",
            subtitle: "Make It Visual",
            description: "Turn verses into beautiful images. Tap the photo icon on any verse, then scroll down to see all customization options.",
            icon: "photo.on.rectangle",
            color: .purple
        ),
        OnboardingPage(
            title: "Daily Notifications",
            subtitle: "Stay Connected",
            description: "Get a daily verse delivered to your phone. Enable notifications in Settings to start your day with the Word.",
            icon: "bell.fill",
            color: .orange
        ),
        OnboardingPage(
            title: "Highlight & Bookmark",
            subtitle: "Make It Personal",
            description: "Long press any verse to highlight it in your favorite color or add it to bookmarks for easy access.",
            icon: "highlighter",
            color: .yellow
        ),
        OnboardingPage(
            title: "Side-by-Side Translations",
            subtitle: "Compare & Study",
            description: "Tap any verse to see both AAVE and traditional translations side by side for deeper understanding.",
            icon: "doc.on.doc",
            color: .red
        )
    ]
    
    var body: some View {
        VStack {
            // Progress indicator
            HStack {
                ForEach(0..<pages.count, id: \.self) { index in
                    Circle()
                        .fill(index <= currentPage ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .animation(.easeInOut, value: currentPage)
                }
            }
            .padding(.top, 20)
            
            // Page content
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // Navigation buttons
            HStack {
                if currentPage > 0 {
                    Button("Back") {
                        withAnimation {
                            currentPage -= 1
                        }
                    }
                    .foregroundColor(.blue)
                }
                
                Spacer()
                
                if currentPage < pages.count - 1 {
                    Button("Next") {
                        withAnimation {
                            currentPage += 1
                        }
                    }
                    .foregroundColor(.blue)
                    .fontWeight(.semibold)
                } else {
                    Button("Get Started") {
                        completeOnboarding()
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(25)
                    .fontWeight(.semibold)
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
        .background(Color(.systemBackground))
    }
    
    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        withAnimation {
            isPresented = false
        }
    }
}

struct OnboardingPage {
    let title: String
    let subtitle: String
    let description: String
    let icon: String
    let color: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Icon
            Image(systemName: page.icon)
                .font(.system(size: 80))
                .foregroundColor(page.color)
                .padding(.bottom, 20)
            
            // Title
            Text(page.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
            
            // Subtitle
            Text(page.subtitle)
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(page.color)
                .multilineTextAlignment(.center)
            
            // Description
            Text(page.description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .lineSpacing(4)
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    OnboardingView(isPresented: .constant(true))
}
