import SwiftUI

struct VerseView: View {
    let book: String
    let chapter: Int
    let verse: Int
    
    @StateObject private var settings = SettingsViewModel.shared
    @State private var verseText: String = "Loading..."
    @State private var isLoading = true
    @State private var error: Error?
    @State private var hasCommentary: Bool = false
    
    private let translationService = TranslationService.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                Text("\(book) \(chapter):\(verse)")
                    .font(.headline)
                
                Spacer()
                
                HStack(spacing: 8) {
                    if hasCommentary {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 14))
                    }
                }
            }
            
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else if let error = error {
                Text("Error: \(error.localizedDescription)")
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                HStack(alignment: .top, spacing: 16) {
                    Text("\(verse)")
                        .font(.system(.body, design: .serif))
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                        .frame(width: 32, alignment: .trailing)
                    
                    Text(verseText)
                        .font(.system(size: settings.fontSize))
                        .lineSpacing(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
        .task {
            await loadVerse()
            hasCommentary = translationService.hasCommentary(for: book, chapter: chapter, verse: verse)
        }
    }
    
    private func loadVerse() async {
        isLoading = true
        error = nil
        
        do {
            let translation = settings.preferredTranslation
            let text = try await translationService.getVerseTranslation(
                for: book,
                chapter: chapter,
                verse: verse,
                translation: translation
            )
            
            await MainActor.run {
                verseText = text
                isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error
                isLoading = false
            }
        }
    }
}

#Preview {
    VerseView(book: "Genesis", chapter: 1, verse: 1)
        .padding()
}
