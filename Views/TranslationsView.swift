import SwiftUI

struct TranslationsView: View {
    let verse: Verse
    @StateObject private var translationService = TranslationService.shared
    @StateObject private var settings = SettingsViewModel.shared
    @State private var translations: (aave: String?, traditional: String?) = (nil, nil)
    @State private var isLoading = true
    
    var body: some View {
        VStack(spacing: 20) {
            Text("\(verse.reference.book) \(verse.reference.chapter):\(verse.reference.verse)")
                .font(.headline)
                .padding(.top)
            
            if isLoading {
                ProgressView()
                    .padding()
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        if let aaveText = translations.aave {
                            TranslationCard(
                                title: "AAVE Translation",
                                text: aaveText,
                                fontSize: settings.fontSize
                            )
                        }
                        
                        if let traditionalText = translations.traditional {
                            TranslationCard(
                                title: "NET Translation",
                                text: traditionalText,
                                fontSize: settings.fontSize
                            )
                        }
                    }
                    .padding()
                }
            }
        }
        .task {
            await loadTranslations()
        }
    }
    
    private func loadTranslations() async {
        isLoading = true
        
        do {
            let ref = verse.reference
            
            async let aaveText = translationService.getVerseTranslation(
                for: ref.book,
                chapter: ref.chapter,
                verse: ref.verse,
                translation: "AAVE"
            )
            
            async let traditionalText = translationService.getVerseTranslation(
                for: ref.book,
                chapter: ref.chapter,
                verse: ref.verse,
                translation: "NET"
            )
            
            translations = try await (aave: aaveText, traditional: traditionalText)
            isLoading = false
        } catch {
            print("Error loading translations: \(error)")
            isLoading = false
        }
    }
}
