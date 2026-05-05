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
    @StateObject private var preferences = UserProfilePreferences.shared
    @StateObject private var achievementService = AchievementService.shared
    @StateObject private var personalization = PersonalizationService.shared
    @EnvironmentObject private var router: NavigationRouter
    @State private var showingProfile = false
    @State private var isLoadingVerse = false
    @State private var error: Error?
    @State private var redLetterVerse: (reference: VerseReference, text: String)?
    @State private var showAchievements = false
    @State private var suppressAchievementsTap = false
    @State private var showShareFollowUp = false
    @State private var shareFollowUpReference: VerseReference?
    @AppStorage(DailyVerseLiveActivityCoordinator.enabledKey) private var lockScreenDailyVerseEnabled = false
    @AppStorage(DailyVerseLiveActivityCoordinator.jesusSaidKey) private var lockScreenJesusSaidEnabled = false
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    // Jesus quotes related properties
    private let jesusQuoteReferences = HomeView.jesusQuoteReferences  // Initialize from the static property
    @State private var previousReference: VerseReference?
    @AppStorage("jesusQuoteGospelFilter") private var gospelFilter: String = "All"
    
    // Move welcomeSection outside of body
    var welcomeSection: some View {
        VStack(spacing: 10) {
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
                .fixedSize(horizontal: false, vertical: true)

            Text(personalizedWelcomeLine)
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .homeCard()
    }
    
    private var personalizedWelcomeLine: String {
        "\(preferences.tonePreference.homeLine) \(preferences.faithVibe.shortLine)"
    }

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

                personalizationCard
                
                HomeDailyCard { reference in
                    navigateToVerse(reference)
                }

                StreakCard()

                achievementsSummaryCard
                
                // Today Focus Verse
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
                            .fixedSize(horizontal: false, vertical: true)
                        
                        HStack {
                            Text("Tap to Play")
                                .font(.subheadline)
                                .homePrimaryCTA()
                            
                            Spacer()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .homeCard()
                
                // Share App CTA
                shareAppCTA
                
                // Discord Community Invite
                discordInvite
            }
            .frame(maxWidth: isRegularWidth ? 720 : .infinity)
            .padding(.horizontal, horizontalPadding)
            .padding(.bottom, 80)
        }
        .safeAreaPadding(.top, 8)
        .scrollIndicators(.hidden)
        .applyGlassToolbar()
        .onAppear {
            personalization.recordAppOpen()
            personalization.refresh(using: userDataManager.history)
            generateRedLetterVerse()
        }
        .onChange(of: redLetterVerse?.reference.id) { _, _ in
            guard let verse = redLetterVerse else { return }
            let verseId = liveActivityVerseId(for: verse.reference)
            let excerpt = liveActivityExcerpt(from: verse.text, maxLength: 140)
            let versionUsed = settings.verseOfDayTranslation
#if DEBUG
            print("HOME->LA snapshot verseId=\(verseId) isJesusSaid=\(lockScreenJesusSaidEnabled) versionUsed=\(versionUsed) excerptLen=\(excerpt.count)")
#endif
            DailyVerseLiveActivityCoordinator.setHomeDisplayedVerse(
                verseId: verseId,
                reference: verse.reference.displayString,
                excerpt: excerpt,
                isJesusSaid: lockScreenJesusSaidEnabled,
                versionUsed: versionUsed
            )
        }
        .onChange(of: settings.verseOfDayTranslation) { _, _ in
            generateRedLetterVerse()
        }
        .onChange(of: userDataManager.history) { _, newHistory in
            personalization.refresh(using: newHistory)
        }
        .onChange(of: gospelFilter) { _, _ in
            if lockScreenJesusSaidEnabled {
                generateRedLetterVerse()
            }
        }
        .onChange(of: lockScreenDailyVerseEnabled) { _, newValue in
            DailyVerseLiveActivityCoordinator.setEnabled(newValue)
        }
        .onChange(of: lockScreenJesusSaidEnabled) { _, _ in
            generateRedLetterVerse()
            DailyVerseLiveActivityCoordinator.refreshIfEnabled()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingProfile = true }) {
                    Image(systemName: "person.circle")
                }
            }
        }
        .sheet(isPresented: $showingProfile) {
            ProfileView()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ShowProfile"))) { _ in
            showingProfile = true
        }
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color.clear, for: .navigationBar)
        .glassBackground()
        .background(
            NavigationLink(
                destination: AchievementsView(),
                isActive: $showAchievements
            ) {
                EmptyView()
            }
            .hidden()
        )
        .overlay(alignment: .bottom) {
            if showShareFollowUp, let reference = shareFollowUpReference {
                shareFollowUpStrip(reference: reference)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
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

    private var gridSpacing: CGFloat { 14 }

    private var horizontalPadding: CGFloat {
        isRegularWidth ? 24 : 16
    }
    
    private var personalizationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("For You Today")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                Image(systemName: "sparkles")
                    .foregroundColor(.yellow)
            }

            Text(personalization.state.primaryTitle)
                .font(.subheadline.weight(.semibold))

            Text(personalization.state.primaryBody)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Button(action: handlePersonalizationPrimaryAction) {
                Text(personalization.state.primaryActionTitle)
                    .homePrimaryCTA()
            }
            .buttonStyle(.plain)

            Divider()

            Text(personalization.state.timeOfDayCopy)
                .font(.footnote)
                .foregroundColor(.secondary)

            HStack(spacing: 8) {
                Text(personalization.state.explorationCopy)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
                if let book = personalization.state.explorationBook {
                    Button("Try \(book)") {
                        navigateToBook(book)
                    }
                    .font(.caption.weight(.semibold))
                    .buttonStyle(.bordered)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .homeCard()
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
            
            Text("Help spread the Word. If a verse, note, or moment hits home, share the app with somebody else. Every new reader helps us strengthen the translation, commentary, and overall experience.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            Text("Visit officialaavebible.com to learn more.")
                .font(.body)
                .padding(.top, 4)
            HStack {
                Button(action: {
                    shareApp()
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }) {
                    Label("Share the App", systemImage: "square.and.arrow.up")
                        .homePrimaryCTA()
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
        .homeCard()
    }

    private var achievementsSummaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Your Achievements")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }

            let recent = achievementService.recentUnlocked(limit: 3)
            if recent.isEmpty {
                Text("No unlocks yet. Highlight a verse to get your first badge.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Button(action: {
                    suppressAchievementsTap = true
                    selectedTab = .bible
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        suppressAchievementsTap = false
                    }
                }) {
                    Text("Highlight a Verse")
                        .homePrimaryCTA()
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(recent) { achievement in
                        HStack(spacing: 10) {
                            Image(systemName: achievement.icon)
                                .foregroundColor(.yellow)
                                .frame(width: 28, height: 28)
                                .background(
                                    Circle().fill(Color.yellow.opacity(0.15))
                                )

                            Text(achievement.title)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .homeCard()
        .contentShape(Rectangle())
        .onTapGesture {
            if !suppressAchievementsTap {
                showAchievements = true
            }
        }
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
                .fixedSize(horizontal: false, vertical: true)
            
            Button(action: {
                openDiscord()
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }) {
                HStack(spacing: 10) {
                    Image("logo_discord")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .foregroundStyle(.white)

                    Text("Join Discord")
                }
                .homePrimaryCTA()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .homeCard()
    }
    
    // Function to share the app
    func shareApp() {
#if DEBUG
        print("[InviteShare] User tapped Invite")
#endif
        guard let items = InviteShareProvider.shareItems() else { return }
        AchievementSharePresenter.present(items: items)
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
            HStack(alignment: .firstTextBaseline) {
                HStack(spacing: 8) {
                    Image(systemName: "sun.max.fill")
                        .foregroundColor(.yellow)
                    Text("Today Focus")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }

                Spacer()

                Button(action: {
                    generateRedLetterVerse()
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .padding(6)
                }
                .buttonStyle(.plain)
            }

            todayFocusModeControls

            HStack {
                Spacer()
                ProgressView()
                    .padding(.vertical, 10)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .homeCard()
    }

    // Error card
    var errorCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                HStack(spacing: 8) {
                    Image(systemName: "sun.max.fill")
                        .foregroundColor(.yellow)
                    Text("Today Focus")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }

                Spacer()

                Button(action: {
                    generateRedLetterVerse()
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .padding(6)
                }
                .buttonStyle(.plain)
            }

            todayFocusModeControls

            Text("Could not load verse. Tap refresh to try again.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .homeCard()
    }
    
    // Red Letter Verse Card
    func redLetterVerseCard(_ verse: (reference: VerseReference, text: String)) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(alignment: .firstTextBaseline) {
                HStack(spacing: 8) {
                    Image(systemName: "sun.max.fill")
                        .foregroundColor(.yellow)
                    Text("Today Focus")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }

                Spacer()

                Button(action: {
                    generateRedLetterVerse()
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .padding(6)
                }
                .buttonStyle(.plain)
            }

            todayFocusModeControls

            // Reference + Scope
            HStack(alignment: .center, spacing: 10) {
                Text("\(verse.reference.book) \(verse.reference.chapter):\(verse.reference.verse)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color.white.opacity(0.08))
                    )
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(Color.white.opacity(0.14), lineWidth: 1)
                    )

                Spacer(minLength: 8)

                // Compact scope control
                if lockScreenJesusSaidEnabled {
                    Menu {
                        Button("All Gospels", action: { gospelFilter = "All" })
                        Button("Matthew", action: { gospelFilter = "Matthew" })
                        Button("Mark", action: { gospelFilter = "Mark" })
                        Button("Luke", action: { gospelFilter = "Luke" })
                        Button("John", action: { gospelFilter = "John" })
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                            Text(gospelFilter == "All" ? "All Gospels" : gospelFilter)
                                .lineLimit(1)
                        }
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule(style: .continuous)
                                .fill(Color.blue.opacity(0.10))
                        )
                    }
                }
            }

            // CTA under scope
            Button(action: {
                readJesusQuoteInContext(verse.reference)
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "book.fill")
                    Text("Read in context")
                        .fontWeight(.semibold)
                }
                .font(.subheadline)
                .foregroundColor(.blue)
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.blue.opacity(0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.blue.opacity(0.18), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)

            // Quote
            Text(verse.text)
                .font(.body)
                .lineSpacing(5)
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.white.opacity(0.16), lineWidth: 1)
                        )
                )

            // Actions
            HStack(spacing: 12) {
                Button(action: {
                    shareJesusQuote(verse)
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }) {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.blue.opacity(0.10))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.blue.opacity(0.18), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)

                NavigationLink(destination: VerseImageCreatorView(
                    verse: Verse(
                        text: verse.text,
                        translation: settings.verseOfDayTranslation,
                        reference: verse.reference
                    ),
                    onReadInContext: { ref in
                        readJesusQuoteInContext(ref)
                    }
                )) {
                    Label("Create Image", systemImage: "photo.on.rectangle")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.blue.opacity(0.10))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.blue.opacity(0.18), lineWidth: 1)
                        )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .homeCard()
        .transition(.opacity)
        .id(verse.reference.id)
    }

    private var todayFocusModeControls: some View {
        VStack(spacing: 10) {
            Toggle(isOn: $lockScreenDailyVerseEnabled) {
                Label("Pin to Lock Screen", systemImage: "iphone.gen3")
                    .font(.subheadline.weight(.medium))
            }

            Toggle(isOn: $lockScreenJesusSaidEnabled) {
                Label("Jesus Said mode", systemImage: "text.bubble")
                    .font(.subheadline.weight(.medium))
            }
        }
        .toggleStyle(.switch)
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
                let verse: (reference: VerseReference, text: String)
                if lockScreenJesusSaidEnabled {
                    verse = try await getRandomJesusQuote()
                } else {
                    let preferredVersion = VerseVersion(rawValue: settings.verseOfDayTranslation) ?? .aave
                    if let selection = await VerseOfDayProvider.today(
                        jesusSaidOnly: false,
                        preferredVersion: preferredVersion,
                        testament: settings.verseOfDayTestament,
                        book: settings.verseOfDayBook == "Any" ? nil : settings.verseOfDayBook
                    ), let reference = VerseOfDayProvider.reference(forVerseId: selection.verseId) {
                        verse = (reference: reference, text: selection.fullText)
                    } else {
                        throw NSError(domain: "HomeView.TodayFocus", code: 1)
                    }
                }
                
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
        let canonicalBook = BookNameNormalizer.canonicalBookName(reference.book) ?? reference.book
        let canonicalRef = VerseReference(book: canonicalBook, chapter: reference.chapter, verse: reference.verse)

#if DEBUG
        assertCanonicalBook(canonicalRef.book, context: "HomeView.navigateToVerse")
#endif

        // Persist last location for resume behavior
        UserDefaults.standard.set(canonicalRef.book, forKey: "lastBook")
        UserDefaults.standard.set(canonicalRef.chapter, forKey: "lastChapter")
        UserDefaults.standard.set(canonicalRef.verse, forKey: "lastVerse")

        router.requestDeepLink(
            .bible(
                bookID: canonicalRef.book,
                chapter: canonicalRef.chapter,
                verse: canonicalRef.verse
            )
        )
        selectedTab = .bible
    }

    private func handlePersonalizationPrimaryAction() {
        switch personalization.state.primaryAction {
        case .resumeVerse(let reference):
            navigateToVerse(reference)
        case .openBook(let book):
            navigateToBook(book)
        }
    }

    private func navigateToBook(_ book: String) {
        let canonicalBook = BookNameNormalizer.canonicalBookName(book) ?? book
        let verseRef = VerseReference(book: canonicalBook, chapter: 1, verse: 1)
        navigateToVerse(verseRef)
    }

    func readJesusQuoteInContext(_ reference: VerseReference) {
        let canonicalBook = BookNameNormalizer.canonicalBookName(reference.book) ?? reference.book
        let canonicalRef = VerseReference(book: canonicalBook, chapter: reference.chapter, verse: reference.verse)
        router.requestDeepLink(
            .bible(
                bookID: canonicalRef.book,
                chapter: canonicalRef.chapter,
                verse: canonicalRef.verse
            )
        )
        selectedTab = .bible
        NotificationManager.shared.scheduleReadInContextNudge()
    }
    
    // Share Jesus quote
    func shareJesusQuote(_ verse: (reference: VerseReference, text: String)) {
        let shareText = "\"\(verse.text)\" - \(verse.reference.book) \(verse.reference.chapter):\(verse.reference.verse) (AAVE Bible)"
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        activityVC.completionWithItemsHandler = { _, completed, _, _ in
            guard completed else { return }
            DispatchQueue.main.async {
                shareFollowUpReference = verse.reference
                showShareFollowUp = true
            }
        }
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityVC, animated: true)
        }
        AchievementService.shared.recordShare()
    }

    private func shareFollowUpStrip(reference: VerseReference) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Shared. Keep the Word moving.")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.primary)

            HStack(spacing: 10) {
                Button("Read in context") {
                    showShareFollowUp = false
                    readJesusQuoteInContext(reference)
                }
                .buttonStyle(.borderedProminent)

                Button("Mark today complete") {
                    ReadingProgressService.shared.markVerseRead(reference)
                    showShareFollowUp = false
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                )
        )
    }
    
    private func liveActivityVerseId(for reference: VerseReference) -> String {
        let bookPart = reference.book.replacingOccurrences(of: " ", with: "-")
        return "\(bookPart)-\(reference.chapter)-\(reference.verse)"
    }

    private func liveActivityExcerpt(from text: String, maxLength: Int) -> String {
        let cleaned = text
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard cleaned.count > maxLength else { return cleaned }
        return String(cleaned.prefix(maxLength)).trimmingCharacters(in: .whitespacesAndNewlines) + "…"
    }
}

private struct HomeDailyCard: View {
    @AppStorage("lastBook") private var lastBook = ""
    @AppStorage("lastChapter") private var lastChapter = 0

    let onPrimaryAction: (VerseReference) -> Void

    private var state: HomeDailyCardState {
        let resolvedBook = lastBook.isEmpty ? nil : lastBook
        let resolvedChapter = lastChapter > 0 ? lastChapter : nil
        return HomeDailyCardBuilder.newTestamentSpotlight(
            lastBook: resolvedBook,
            lastChapter: resolvedChapter
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("New Testament Spotlight", systemImage: "book.pages")
                    .font(.headline.weight(.bold))
                Spacer()
            }

            Text(state.body)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Button(action: { onPrimaryAction(state.reference) }) {
                Label(state.ctaTitle, systemImage: "arrow.right.circle.fill")
                    .homePrimaryCTA()
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .homeCard()
    }
}

private struct HomeDailyCardState {
    let body: String
    let ctaTitle: String
    let reference: VerseReference
}

private enum HomeDailyCardBuilder {
    private static let ntBooks = bibleBooks.filter { $0.testament == .new }

    static func newTestamentSpotlight(lastBook: String?, lastChapter: Int?) -> HomeDailyCardState {
        guard let lastBook,
              let canonicalLastBook = BookNameNormalizer.canonicalBookName(lastBook),
              let lastChapter,
              lastChapter > 0 else {
            return placeholderState()
        }

        guard let currentIndex = ntBooks.firstIndex(where: { $0.name == canonicalLastBook }) else {
            return placeholderState()
        }

        let currentBook = ntBooks[currentIndex]
        let chapterCount = currentBook.chapters

        guard chapterCount > 0 else {
            return placeholderState()
        }

        if lastChapter < chapterCount {
            let nextReference = VerseReference(book: currentBook.name, chapter: lastChapter + 1, verse: 1)
            return HomeDailyCardState(
                body: "Keep your rhythm going with \(nextReference.book) \(nextReference.chapter).",
                ctaTitle: "Read \(nextReference.book) \(nextReference.chapter)",
                reference: nextReference
            )
        }

        if currentIndex < ntBooks.count - 1 {
            let nextBook = ntBooks[currentIndex + 1]
            let nextReference = VerseReference(book: nextBook.name, chapter: 1, verse: 1)
            return HomeDailyCardState(
                body: "You finished \(currentBook.name). Next up: \(nextBook.name) 1.",
                ctaTitle: "Start \(nextBook.name)",
                reference: nextReference
            )
        }

        let restartReference = VerseReference(book: "Matthew", chapter: 1, verse: 1)
        return HomeDailyCardState(
            body: "You reached the end of Revelation. Start a fresh NT cycle today.",
            ctaTitle: "Restart in Matthew",
            reference: restartReference
        )
    }

    private static func placeholderState() -> HomeDailyCardState {
        let fallback = VerseReference(book: "Matthew", chapter: 1, verse: 1)
        return HomeDailyCardState(
            body: "No recent NT chapter found yet. Start in Matthew and build your flow.",
            ctaTitle: "Start Matthew 1",
            reference: fallback
        )
    }
}

private struct HomeDailyCardPreviewHarness: View {
    let state: HomeDailyCardState

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label("New Testament Spotlight", systemImage: "book.pages")
                        .font(.headline.weight(.bold))
                    Spacer()
                }
                Text(state.body)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(state.ctaTitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 9)
                    .background(
                        LinearGradient(
                            colors: [Color.indigo.opacity(0.92), Color.blue.opacity(0.86)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(10)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassCard()
        }
        .padding()
        .glassBackground()
    }
}

private struct HomePrimaryCTAStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.subheadline.weight(.semibold))
            .lineLimit(1)
            .minimumScaleFactor(0.82)
            .foregroundColor(.white)
            .padding(.horizontal, 14)
            .frame(minHeight: 44)
            .background(
                LinearGradient(
                    colors: [Color.indigo.opacity(0.92), Color.blue.opacity(0.86)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(12)
    }
}

private extension View {
    func homePrimaryCTA() -> some View {
        modifier(HomePrimaryCTAStyle())
    }
}


   
    
   

#Preview {
    HomeView(selectedTab: .constant(.home))
        .environmentObject(NavigationRouter())
}

#Preview("HomeDailyCard - Spotlight") {
    HomeDailyCardPreviewHarness(
        state: HomeDailyCardState(
            body: "Keep your rhythm going with John 7.",
            ctaTitle: "Read John 7",
            reference: VerseReference(book: "John", chapter: 7, verse: 1)
        )
    )
}

#Preview("HomeDailyCard - Placeholder") {
    HomeDailyCardPreviewHarness(
        state: HomeDailyCardState(
            body: "No recent NT chapter found yet. Start in Matthew and build your flow.",
            ctaTitle: "Start Matthew 1",
            reference: VerseReference(book: "Matthew", chapter: 1, verse: 1)
        )
    )
}
    
