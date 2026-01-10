//
//  HomeView.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/9/25.
//

import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: AppTab
    @StateObject private var settings = SettingsViewModel.shared
    @StateObject private var userDataManager = UserDataManager.shared
    @EnvironmentObject private var router: NavigationRouter
    @State private var showingSettings = false
    @State private var isLoadingVerse = false
    @State private var error: Error?
    @State private var redLetterVerse: (reference: VerseReference, text: String)?
    @State private var showConfetti = false
    @State private var rotatingMessageIndex = 0
    @State private var hasReadNTChapter = false
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    
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
    
    // Jesus quotes related properties
    private let jesusQuoteReferences = HomeView.jesusQuoteReferences  // Initialize from the static property
    @State private var previousReference: VerseReference?
    @AppStorage("jesusQuoteGospelFilter") private var gospelFilter: String = "All"
    
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
        .frame(maxWidth: .infinity)
        .glassCard()
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

    init(selectedTab: Binding<AppTab> = .constant(.home)) {
        _selectedTab = selectedTab
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: gridColumns,
                spacing: gridSpacing
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
                
                // New Quiz Promo Card
                NavigationLink(destination: QuizSplashView()) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "gamecontroller.fill")
                                .foregroundColor(.green)
                            Text("New Game Alert!")
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                        
                        Text("“Who Said That?!” Bible quiz now live in the More tab! 10 verses. 15 seconds each. Think you know the Word like that?")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text("Tap to Play")
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    LinearGradient(
                                        colors: [Color.green.opacity(0.9), Color.mint.opacity(0.9)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(12)
                            
                            Spacer()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .glassCard()
                
                // Share App CTA
                shareAppCTA
                
                // Discord Community Invite
                discordInvite
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.top, 24)
            .padding(.bottom, 80)
        }
        .scrollIndicators(.hidden)
        .applyGlassToolbar()
        .onAppear {
            generateRedLetterVerse()
            checkNTProgress()
            checkForConfetti()
            
            // Start rotating messages
            startRotatingMessages()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingSettings = true }) {
                    Image(systemName: "gear")
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .navigationTitle("Home")
        .glassBackground()
    }

    private var isRegularWidth: Bool {
        horizontalSizeClass == .regular
    }

    private var gridColumns: [GridItem] {
        if isRegularWidth {
            // Force two balanced columns on iPad to avoid oversized gaps
            return [
                GridItem(.adaptive(minimum: 360, maximum: 520), spacing: 18)
            ]
        } else {
            return [
                GridItem(.adaptive(minimum: 280, maximum: 420), spacing: 16)
            ]
        }
    }

    private var gridSpacing: CGFloat {
        isRegularWidth ? 18 : 16
    }

    private var horizontalPadding: CGFloat {
        isRegularWidth ? 24 : 16
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
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
            
            Text("You in early. They next. You already got off the waitlist and into the AAVE Bible beta. If you know somebody who’d love hearing Scripture in our voice, send ’em your link so they can join the waitlist. The more folks on the list, the more we can build, test, and unlock. You got early access. Now you can help your people get in line.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("Visit officialaavebible.com to learn more.")
                .font(.body)
                .padding(.top, 4)
            HStack {
                Button(action: {
                    shareApp()
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }) {
                    Label("Invite to the AAVE Bible App Beta", systemImage: "square.and.arrow.up")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.95), Color.cyan.opacity(0.9)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(12)
                }
                
                Button(action: {
                    openWebsite()
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }) {
                    Label("Visit Website", systemImage: "safari")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            LinearGradient(
                                colors: [Color.white.opacity(0.2), Color.white.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.white.opacity(0.25), lineWidth: 1)
                        )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
    }
    
    // Discord invite
    var discordInvite: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Join the Community 💬")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
            }
            
            Text("Tap in with other testers, drop feedback, and see what's cooking in real time. The Discord is where the squad links up.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button(action: {
                openDiscord()
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }) {
                Label("Join Discord", systemImage: "arrow.up.right")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        LinearGradient(
                            colors: [Color.purple.opacity(0.95), Color.indigo.opacity(0.85)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
    }
    
    // Function to share the app
    func shareApp() {
        let shareText = "Yo! I’m part of the AAVE Bible App beta. It’s the full Bible translated in our voice—AAVE style. If you wanna check it out and give feedback before the public launch, hit this link and let me know. Let’s make history with this. officialaavebible.com"
        
        let activityVC = UIActivityViewController(
            activityItems: [shareText],
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
    
    // Function to open Discord
    func openDiscord() {
        if let url = URL(string: "https://discord.gg/9RMEZNCKqB") {
            UIApplication.shared.open(url)
        }
    }
    
    // Loading card
    var loadingCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Text bubble icon with "Jesus Said" text
                HStack(spacing: 4) {
                    Image(systemName: "text.bubble.fill")
                        .foregroundColor(.red)
                    Text("Jesus Said")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                Button(action: {
                    generateRedLetterVerse()
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.blue)
                }
            }
            
            HStack {
                Spacer()
                ProgressView()
                    .padding()
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
    }

    // Error card
    var errorCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Text bubble icon with "Jesus Said" text
                HStack(spacing: 4) {
                    Image(systemName: "text.bubble.fill")
                        .foregroundColor(.red)
                    Text("Jesus Said")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                Button(action: {
                    generateRedLetterVerse()
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.blue)
                }
            }
            
            Text("Could not load verse. Tap refresh to try again.")
                .foregroundColor(.red)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
    }
    
    // Red Letter Verse Card
    func redLetterVerseCard(_ verse: (reference: VerseReference, text: String)) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with title and refresh button
            HStack {
                // Text bubble icon with "Jesus Said" text
                HStack(spacing: 4) {
                    Image(systemName: "text.bubble.fill")
                        .foregroundColor(.red)
                    Text("Jesus Said...")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                // Gospel filter button
                Menu {
                    Button("All Gospels", action: { gospelFilter = "All" })
                    Button("Matthew", action: { gospelFilter = "Matthew" })
                    Button("Mark", action: { gospelFilter = "Mark" })
                    Button("Luke", action: { gospelFilter = "Luke" })
                    Button("John", action: { gospelFilter = "John" })
                } label: {
                    Label(gospelFilter == "All" ? "All Gospels" : gospelFilter, systemImage: "line.3.horizontal.decrease.circle")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                Button(action: {
                    generateRedLetterVerse()
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.blue)
                }
            }
            
            // Verse reference
            HStack {
                Text("\(verse.reference.book) \(verse.reference.chapter):\(verse.reference.verse)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text(verse.text)
                .font(.body)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 6)

            // Add Share and Create Image buttons
            HStack(spacing: 12) {
                Button(action: {
                    shareJesusQuote(verse)
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }) {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.9), Color.cyan.opacity(0.9)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(12)
                }
                
                // Create Verse Image button
                NavigationLink(destination: VerseImageCreatorView(verse: Verse(
                    text: verse.text,
                    translation: settings.verseOfDayTranslation,
                    reference: verse.reference
                ))) {
                    Label("Create Image", systemImage: "photo.on.rectangle")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            LinearGradient(
                                colors: [Color.purple.opacity(0.85), Color.blue.opacity(0.85)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(12)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
        .transition(.opacity)
        .id(verse.reference.id)
    }
    
    // Function to get random Jesus quote
    func getRandomJesusQuote() async throws -> (reference: VerseReference, text: String) {
        // Filter quotes based on selected gospel if needed
        let filteredReferences: [VerseReference]
        if gospelFilter == "All" {
            filteredReferences = jesusQuoteReferences
        } else {
            filteredReferences = jesusQuoteReferences.filter { $0.book == gospelFilter }
        }
        
        guard !filteredReferences.isEmpty else {
            // Fallback if no quotes match the filter
            let defaultRef = VerseReference(book: "John", chapter: 14, verse: 6)
            let text = try await TranslationService.shared.getVerseTranslation(
                for: defaultRef.book,
                chapter: defaultRef.chapter,
                verse: defaultRef.verse,
                translation: settings.verseOfDayTranslation
            )
            return (reference: defaultRef, text: text)
        }
        
        // Avoid showing the same verse twice in a row
        var newRef: VerseReference
        repeat {
            newRef = filteredReferences.randomElement()!
        } while previousReference == newRef && filteredReferences.count > 1
        
        previousReference = newRef
        
        // Fetch the actual verse text from TranslationService
        let text = try await TranslationService.shared.getVerseTranslation(
            for: newRef.book,
            chapter: newRef.chapter,
            verse: newRef.verse,
            translation: settings.verseOfDayTranslation
        )
        
        return (reference: newRef, text: text)
    }
    
    // Generate red letter verse
    func generateRedLetterVerse() {
        isLoadingVerse = true
        error = nil
        redLetterVerse = nil
        
        Task {
            do {
                // Get a random red letter verse with text from TranslationService
                let verse = try await getRandomJesusQuote()
                
                await MainActor.run {
                    redLetterVerse = verse
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
    
    // Navigate to verse
    func navigateToVerse(_ reference: VerseReference) {
        selectedTab = .bible

        // Persist the target so the Bible tab restores the exact verse even if the nav stack resets.
        UserDefaults.standard.set(reference.book, forKey: "lastBook")
        UserDefaults.standard.set(reference.chapter, forKey: "lastChapter")
        UserDefaults.standard.set(reference.verse, forKey: "lastVerse")

        // Hop to the Bible tab first, then drive the router on the next run loop.
        DispatchQueue.main.async {
            router.resetAndGoTo(
                .bible(
                    bookID: reference.book,
                    chapter: reference.chapter,
                    verse: reference.verse
                )
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            withAnimation {
                rotatingMessageIndex = (rotatingMessageIndex + 1) % rotatingMessages.count
            }
            startRotatingMessages()
        }
    }
    
    // Share Jesus quote
    func shareJesusQuote(_ verse: (reference: VerseReference, text: String)) {
        let shareText = "\"\(verse.text)\" - \(verse.reference.book) \(verse.reference.chapter):\(verse.reference.verse) (AAVE Bible)"
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityVC, animated: true)
        }
    }
    
    // Get OT chapters read count
    func getOTChaptersReadCount() -> Int {
        // For now, return 929 (all OT chapters) since OT is complete
        return 929
    }
}


   
    
   

#Preview {
    HomeView(selectedTab: .constant(.home))
        .environmentObject(NavigationRouter())
}
    
