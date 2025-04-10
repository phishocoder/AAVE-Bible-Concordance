import Foundation
import SwiftUI

@MainActor
class DownloadManagerViewModel: ObservableObject {
    @Published private(set) var downloadedBooks: Set<String> = []
    @Published private(set) var downloadingBooks: Set<String> = []
    @Published var downloadProgress: [String: Double] = [:]
    @Published var showError = false
    @Published var errorMessage = ""
    
    private let verseManager = VerseManager.shared
    
    init() {
        // Sync with VerseManager's state
        downloadedBooks = verseManager.downloadedBooks
        downloadingBooks = verseManager.downloadingBooks
        downloadProgress = verseManager.downloadProgress
    }
    
    func booksForTestament(_ testament: Testament) -> [String] {
        bibleBooks
            .filter { $0.testament == testament }
            .map { $0.name }
    }
    
    func downloadBook(_ book: String) async {
        guard !downloadingBooks.contains(book) else { return }
        guard !downloadedBooks.contains(book) else { return }
        
        downloadingBooks.insert(book)
        downloadProgress[book] = 0.0
        
        do {
            try await verseManager.downloadBook(book, translation: "NET") // Added translation parameter
            downloadedBooks.insert(book)
            downloadingBooks.remove(book)
            downloadProgress[book] = 1.0
            saveDownloadedBooks()
        } catch {
            downloadingBooks.remove(book)
            downloadProgress.removeValue(forKey: book)
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    private func saveDownloadedBooks() {
        UserDefaults.standard.set(Array(downloadedBooks), forKey: "downloadedBooks")
    }
    
    // Add this method if it doesn't exist
    func dismissError() {
        showError = false
        errorMessage = ""
    }
}
