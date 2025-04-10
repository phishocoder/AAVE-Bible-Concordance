//
//  HomeView.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/9/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var settings = SettingsViewModel.shared
    @StateObject private var userDataManager = UserDataManager.shared
    @StateObject private var navigationManager = NavigationManager.shared
    @State private var showingSettings = false
    @State private var showingVerseOfDaySettings = false
    @State private var isLoadingVerse = false
    @State private var error: Error?
    @State private var redLetterVerse: (reference: VerseReference, text: String)?
    @State private var showConfetti = false
    @State private var rotatingMessageIndex = 0
    @State private var hasReadNTChapter = false
    @Environment(\.colorScheme) var colorScheme
    
    let rotatingMessages = [
        "Every prophet, every king, every scroll. You did that.",
        "929 chapters, and the journey's still not over.",
        "Now… let's talk about this Jesus."
    ]
    
    // NT chapter count
    let totalNTChapters = 260
    
    // Gospels chapter count
    let gospelsChapters = 89 // Matthew (28), Mark (16), Luke (24), John (21)
    
    // Move welcomeSection outside of body
    // Move welcomeSection outside of body
    var welcomeSection: some View {
        VStack(spacing: 12) {
            // AAVE Logo and Title
            HStack(spacing: 0) {
                Text("A")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.red)
                
                Text("A")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(Color(UIColor.aaveLogoSecondA))
                    .overlay(
                        Text("A")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(Color(UIColor.aaveLogoSecondAOutline))
                            .opacity(colorScheme == .dark ? 1.0 : 0.0)
                    )
                
                Text("V")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.yellow)
                
                Text("E")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.green)
                
                Text(" Bible")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            Text(settings.tagline)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(
                    columns: [
                        GridItem(.adaptive(minimum: 300, maximum: 600))
                    ],
                    spacing: 20
                ) {
                   
                    welcomeSection
                    // OT Completion Section
                    otCompletionSection
                    
                    // Acts Feature Card (previously Matthew)
                    actsFeatureCard
                    
                    // Progress Tracker
                    progressTrackerBar
                    
                    // Jesus Said (Red Letter Verse)
                    if let verse = redLetterVerse {
                        redLetterVerseCard(verse)
                    } else if isLoadingVerse {
                        loadingCard
                    } else if error != nil {
                        errorCard
                    }
                    
                    // NT Journey CTA (conditional)
                    if !hasReadNTChapter {
                        ntJourneyCTA
                    }
                }
                .padding()
                .navigationBarItems(trailing: Button(action: { showingSettings = true }) {
                    Image(systemName: "gear")
                })
                .sheet(isPresented: $showingSettings) {
                    SettingsView()
                }
            }
            .onAppear {
                generateRedLetterVerse()
                checkNTProgress()
                checkForConfetti()
                
                // Start rotating messages
                startRotatingMessages()
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("RefreshVerseOfTheDay"))) { _ in
                generateRedLetterVerse()
            }
        }
    }
    
    // OT Completion Section
    var otCompletionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("The Word Is Complete — Old Testament 📜")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
            }
            
            Text("929 chapters. Every book. Fully translated.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if rotatingMessageIndex < rotatingMessages.count {
                Text(rotatingMessages[rotatingMessageIndex])
                    .font(.body)
                    .italic()
                    .padding(.top, 4)
                    .transition(.opacity)
                    .id("rotating-\(rotatingMessageIndex)")
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .overlay(
            ZStack {
                if showConfetti {
                    ConfettiView()
                        .allowsHitTesting(false)
                }
            }
        )
    }
    
    // Acts Feature Card (previously Matthew)
    var actsFeatureCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("The Church Begins — Acts 🔥")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
            }
            
            Text("The Holy Spirit arrives. The church is born.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button(action: {
                navigateToActs()
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }) {
                Text("Start Reading Acts →")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // Progress Tracker Bar
    var progressTrackerBar: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("New Testament Progress")
                .font(.headline)
                .fontWeight(.bold)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 12)
                        .cornerRadius(6)
                    
                    // Progress
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: getNTProgressWidth(totalWidth: geometry.size.width), height: 12)
                        .cornerRadius(6)
                }
            }
            .frame(height: 12)
            
            HStack {
                Text("\(getNTCompletedChapters()) of \(totalNTChapters) chapters")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int((Double(getNTCompletedChapters()) / Double(totalNTChapters)) * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // Red Letter Verse Card
    func redLetterVerseCard(_ verse: (reference: VerseReference, text: String)) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Jesus Said...")
                    .font(.headline)
                
                Image(systemName: "quote.bubble")
                    .foregroundColor(.red)
                
                Spacer()
                
                Button(action: {
                    showingVerseOfDaySettings = true
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.secondary)
                }
                .sheet(isPresented: $showingVerseOfDaySettings) {
                    VerseOfDaySettingsView()
                }
            }
            
            Text(verse.text)
                .font(.body)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 2)
            
            Text("\(verse.reference.book) \(verse.reference.chapter):\(verse.reference.verse)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Button(action: {
                navigateToVerse(verse.reference)
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }) {
                Text("Read in Context")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // Loading card
    var loadingCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Jesus Said...")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Image(systemName: "quote.bubble")
                    .foregroundColor(.secondary)
            }
            
            ProgressView()
                .frame(maxWidth: .infinity, minHeight: 100)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 2)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // Error card
    var errorCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Jesus Said...")
                    .font(.headline)
                
                Image(systemName: "quote.bubble")
                    .foregroundColor(.red)
            }
            
            Text("Unable to load verse. Tap to retry.")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .onTapGesture {
            generateRedLetterVerse()
        }
    }
    
    // NT Journey CTA
    var ntJourneyCTA: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Start the New Testament Journey ➤")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Tap to begin with Acts 1. This is where the church begins.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.blue)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5)
        .onTapGesture {
            navigateToActs()
        }
    }
    
    // Generate red letter verse
    func generateRedLetterVerse() {
        isLoadingVerse = true
        error = nil
        redLetterVerse = nil
        
        Task {
            do {
                // Get a random red letter verse
                let reference = await getRandomRedLetterVerse()
                
                let text = try await TranslationService.shared.getVerseTranslation(
                    for: reference.book,
                    chapter: reference.chapter,
                    verse: reference.verse,
                    translation: settings.verseOfDayTranslation
                )
                
                // Remove red tags if present
                let cleanText = text.replacingOccurrences(of: "<red>", with: "")
                    .replacingOccurrences(of: "</red>", with: "")
                
                await MainActor.run {
                    redLetterVerse = (reference: reference, text: cleanText)
                    isLoadingVerse = false
                }
            } catch {
                print("Debug - Error loading verse: \(error)")
                await MainActor.run {
                    self.error = error
                    isLoadingVerse = false
                }
            }
        }
    }
    
    // Get random red letter verse
    func getRandomRedLetterVerse() async -> VerseReference {
        // For now, return a default verse from Matthew
        // In a real implementation, you would search for verses with <red> tags
        return VerseReference(book: "Matthew", chapter: 5, verse: Int.random(in: 3...12))
    }
    
    func navigateToVerse(_ reference: VerseReference) {
        print("HomeView: Navigating to \(reference.book) \(reference.chapter):\(reference.verse)")
        
        // Use NavigationManager directly with the verse parameter
        navigationManager.navigateToVerse(
            book: reference.book,
            chapter: reference.chapter,
            verse: reference.verse,
            highlightVerse: true
        )
    }
    
    // Navigate to Acts
    func navigateToActs() {
        print("HomeView: Navigating to Acts 1:1")
        
        // Set the state (this syncs verse highlighting and last viewed info)
        navigationManager.navigateToVerse(
            book: "Acts",
            chapter: 1,
            verse: 1,
            highlightVerse: false
        )

        // Explicitly fire a screen push for BookListView to handle
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            NotificationCenter.default.post(
                name: Notification.Name("NavigateToChapterScreen"),
                object: nil,
                userInfo: [
                    "book": "Acts",
                    "chapter": 1
                ]
            )
        }
    }
    
    // Mark that user has started NT journey
    func navigateToMatthew() {
        print("HomeView: Navigating to Matthew 1:1")
        
        // Step 1: Set the state (this syncs verse highlighting and last viewed info)
        navigationManager.navigateToVerse(
            book: "Matthew",
            chapter: 1,
            verse: 1,
            highlightVerse: false
        )

        // Step 2: Explicitly fire a screen push for BookListView to handle
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            NotificationCenter.default.post(
                name: Notification.Name("NavigateToChapterScreen"),
                object: nil,
                userInfo: [
                    "book": "Matthew",
                    "chapter": 1
                ]
            )
        }

        // Step 3: Track progress
        hasReadNTChapter = true
        UserDefaults.standard.set(true, forKey: "hasStartedNTJourney")
    }
    
    func navigateToMatthewCommentary() {
        // First navigate to Matthew using NavigationManager directly
        navigationManager.navigateToVerse(
            book: "Matthew",
            chapter: 1,
            verse: 1,
            highlightVerse: false
        )
        
        // Then show commentary after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            NotificationCenter.default.post(
                name: Notification.Name("ShowCommentary"),
                object: nil,
                userInfo: ["reference": VerseReference(book: "Matthew", chapter: 1, verse: 1)]
            )
        }
    }
    
    // Check NT progress
    func checkNTProgress() {
        // Check if user has started NT journey
        hasReadNTChapter = UserDefaults.standard.bool(forKey: "hasStartedNTJourney")
    }
    
    // Get NT completed chapters count
    func getNTCompletedChapters() -> Int {
        // Return the completed Gospels chapters
        return gospelsChapters // All Gospel chapters are now complete
    }
    
    // Calculate NT progress width
    func getNTProgressWidth(totalWidth: CGFloat) -> CGFloat {
        let completedChapters = getNTCompletedChapters()
        let progress = Double(completedChapters) / Double(totalNTChapters)
        return totalWidth * CGFloat(progress)
    }
    
    // Check for confetti
    func checkForConfetti() {
        // Show confetti if user has completed OT
        if UserDefaults.standard.bool(forKey: "hasCompletedOT") && !UserDefaults.standard.bool(forKey: "hasShownOTConfetti") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation {
                    self.showConfetti = true
                }
                
                // Mark confetti as shown
                UserDefaults.standard.set(true, forKey: "hasShownOTConfetti")
                
                // Hide confetti after a few seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    withAnimation {
                        self.showConfetti = false
                    }
                }
            }
        }
    }
    
    // Start rotating messages
    func startRotatingMessages() {
        // Rotate messages every 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            withAnimation(.easeInOut(duration: 0.7)) {
                self.rotatingMessageIndex = (self.rotatingMessageIndex + 1) % self.rotatingMessages.count
            }
            
            // Continue rotation
            self.startRotatingMessages()
        }
    }
    
    // Simple Confetti View
    struct ConfettiView: View {
        let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange]
        
        var body: some View {
            GeometryReader { geometry in
                ForEach(0..<50) { _ in
                    ConfettiPiece(
                        position: CGPoint(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height/2)
                        ),
                        color: colors.randomElement() ?? .blue
                    )
                }
            }
        }
    }
    
    struct ConfettiPiece: View {
        let position: CGPoint
        let color: Color
        
        var body: some View {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
                .position(position)
        }
    }
    
    // Alternative Preview approach
    struct HomeView_Previews: PreviewProvider {
        static var previews: some View {
            HomeView()
        }
    }
}
