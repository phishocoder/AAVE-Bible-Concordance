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
            .frame(maxWidth: .infinity, alignment: .center)
            
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
    
    let rotatingMessages = [
        "Every prophet, every king, every scroll. You did that.",
        "1189 chapters, and the journey's still not over.",
        "Now… let's talk about this Jesus."
    ]
    
    // NT chapter count
    let totalNTChapters = 260
    
    // Gospels chapter count
    let gospelsChapters = 89 // Matthew (28), Mark (16), Luke (24), John (21)
    
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
                    
                    // Bible Completion Section
                    bibleCompletionSection
                    
                    
                    // Jesus Said (Red Letter Verse)
                    if let verse = redLetterVerse {
                        redLetterVerseCard(verse)
                    } else if isLoadingVerse {
                        loadingCard
                    } else if error != nil {
                        errorCard
                    }
                    
                    // Share App CTA
                    shareAppCTA
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
    
    // Bible Completion Section
    var bibleCompletionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("The Word Is Complete — Full Bible 📜")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
            }
            
            Text("1189 chapters. Every book. Fully translated.")
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
    
    // Share App CTA
    var shareAppCTA: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Share the Word 🌟")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
            }
            
            Text("Help others discover the AAVE Bible translation.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("Visit officialaavebible.com to learn more about our mission.")
                .font(.body)
                .padding(.top, 4)
            
            HStack {
                Button(action: {
                    shareApp()
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }) {
                    Label("Share App", systemImage: "square.and.arrow.up")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    openWebsite()
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }) {
                    Label("Visit Website", systemImage: "safari")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
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
                    .foregroundColor(.secondary)
                
                Image(systemName: "quote.bubble")
                    .foregroundColor(.secondary)
            }
            
            Text("Could not load verse. Please try again later.")
                .frame(maxWidth: .infinity, minHeight: 100, alignment: .center)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 2)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // Remove the progressTrackerBar view
    // And change the "Jesus Said..." text to be red in the redLetterVerseCard function

    func redLetterVerseCard(_ verse: (reference: VerseReference, text: String)) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Jesus Said...")
                    .font(.headline)
                    .foregroundColor(.red)
                
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
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 2)
            
            HStack {
                Text("\(verse.reference.book) \(verse.reference.chapter):\(verse.reference.verse)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: {
                    navigateToVerse(verse.reference)
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }) {
                    Text("Read in Context")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(12)
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
        // Simplified for now - just return a hardcoded verse
        // In a real app, you would fetch this from a service
        return VerseReference(book: "John", chapter: 3, verse: 16)
    }
    
    // Navigate to verse
    func navigateToVerse(_ reference: VerseReference) {
        navigationManager.navigateToVerse(
            book: reference.book,
            chapter: reference.chapter,
            verse: reference.verse,
            highlightVerse: true
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            NotificationCenter.default.post(
                name: Notification.Name("NavigateToChapterScreen"),
                object: nil,
                userInfo: [
                    "book": reference.book,
                    "chapter": reference.chapter
                ]
            )
        }
    }
    
    // Check NT progress
    func checkNTProgress() {
        // Check if user has started NT journey
        hasReadNTChapter = UserDefaults.standard.bool(forKey: "hasStartedNTJourney")
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
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { timer in
            withAnimation {
                rotatingMessageIndex = (rotatingMessageIndex + 1) % rotatingMessages.count
            }
        }
    }
    
    // Get OT completed chapters count
    func getOTCompletedChapters() -> Int {
        // List of OT books
        let otBooks = ["Genesis", "Exodus", "Leviticus", "Numbers", "Deuteronomy",
                      "Joshua", "Judges", "Ruth", "1 Samuel", "2 Samuel",
                      "1 Kings", "2 Kings", "1 Chronicles", "2 Chronicles",
                      "Ezra", "Nehemiah", "Esther", "Job", "Psalms",
                      "Proverbs", "Ecclesiastes", "Song of Solomon", "Isaiah",
                      "Jeremiah", "Lamentations", "Ezekiel", "Daniel",
                      "Hosea", "Joel", "Amos", "Obadiah", "Jonah",
                      "Micah", "Nahum", "Habakkuk", "Zephaniah",
                      "Haggai", "Zechariah", "Malachi"]
        
        // Count OT chapters read from UserDataManager
        let otChaptersRead = userDataManager.chaptersRead.filter { chapterKey in
            let components = chapterKey.split(separator: "_")
            guard components.count == 2, let book = components.first else { return false }
            return otBooks.contains(String(book))
        }
        
        // For now, return 929 (all OT chapters) since OT is complete
        return 929
    }
    
    // Get NT completed chapters count
    func getNTCompletedChapters() -> Int {
        // List of NT books
        let ntBooks = ["Matthew", "Mark", "Luke", "John", "Acts",
                      "Romans", "1 Corinthians", "2 Corinthians", "Galatians", "Ephesians",
                      "Philippians", "Colossians", "1 Thessalonians", "2 Thessalonians",
                      "1 Timothy", "2 Timothy", "Titus", "Philemon", "Hebrews",
                      "James", "1 Peter", "2 Peter", "1 John", "2 John",
                      "3 John", "Jude", "Revelation"]
        
        // Count NT chapters read from UserDataManager
        let ntChaptersRead = userDataManager.chaptersRead.filter { chapterKey in
            let components = chapterKey.split(separator: "_")
            guard components.count == 2, let book = components.first else { return false }
            return ntBooks.contains(String(book))
        }
        
        return ntChaptersRead.count
    }
    
    // Function to share the app
    func shareApp() {
        let text = "Check out the AAVE Bible app! Experience scripture in African American Vernacular English. Visit officialaavebible.com to learn more."
        
        let activityVC = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityVC, animated: true)
        }
    }

    // Function to open the website
    func openWebsite() {
        if let url = URL(string: "https://officialaavebible.com") {
            UIApplication.shared.open(url)
        }
    }
}
