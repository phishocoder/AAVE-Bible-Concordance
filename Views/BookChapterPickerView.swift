//
//  BookChapterPickerView.swift
//  AAVE Bible Concordance
//

import SwiftUI

struct BookChapterPickerView: View {
    @Binding var selectedBook: String
    @Binding var selectedChapter: Int
    @Binding var selectedVerse: Int?
    @Environment(\.dismiss) private var dismiss
    
    var onSelect: () -> Void
    
    @State private var testament: Testament = .old
    @State private var showingChapters = false
    @State private var showingVerses = false
    @State private var bookForChapters: BibleBook?
    @State private var chapterForVerses: Int?
    
    // Initialize with optional selectedVerse parameter
    init(selectedBook: Binding<String>, selectedChapter: Binding<Int>, selectedVerse: Binding<Int?> = .constant(nil), onSelect: @escaping () -> Void) {
        self._selectedBook = selectedBook
        self._selectedChapter = selectedChapter
        self._selectedVerse = selectedVerse
        self.onSelect = onSelect
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Testament selector
            Picker("Testament", selection: $testament) {
                Text("Old Testament").tag(Testament.old)
                Text("New Testament").tag(Testament.new)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            if showingVerses, let book = bookForChapters, let chapter = chapterForVerses {
                // Verse grid view
                VStack {
                    // Navigation header
                    HStack {
                        Button(action: {
                            showingVerses = false
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Chapters")
                            }
                        }
                        Spacer()
                        Text("\(book.name) \(chapter)")
                            .font(.headline)
                        Spacer()
                    }
                    .padding()
                    
                    // Verse grid
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 15) {
                            ForEach(1...getVerseCount(for: book.name, chapter: chapter), id: \.self) { verse in
                                Button(action: {
                                    selectedBook = book.name
                                    selectedChapter = chapter
                                    selectedVerse = verse
                                    dismiss()
                                    onSelect()
                                }) {
                                    Text("\(verse)")
                                        .frame(width: 50, height: 50)
                                        .background(
                                            selectedBook == book.name &&
                                            selectedChapter == chapter &&
                                            selectedVerse == verse ?
                                            Color.accentColor : Color.secondary.opacity(0.2)
                                        )
                                        .foregroundColor(
                                            selectedBook == book.name &&
                                            selectedChapter == chapter &&
                                            selectedVerse == verse ?
                                            Color.white : Color.primary
                                        )
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding()
                    }
                }
            } else if !showingChapters && !showingVerses {
                // Book list view
                List {
                    ForEach(filteredBooks, id: \.name) { book in
                        Button(action: {
                            bookForChapters = book
                            showingChapters = true
                        }) {
                            HStack {
                                Text(book.name)
                                    .fontWeight(selectedBook == book.name ? .bold : .regular)
                                Spacer()
                                if selectedBook == book.name {
                                    Text("Chapter \(selectedChapter)")
                                        .foregroundColor(.secondary)
                                        .font(.caption)
                                }
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                }
            } else if let book = bookForChapters, showingChapters {
                // Chapter grid view
                VStack {
                    // Navigation header
                    HStack {
                        Button(action: {
                            showingChapters = false
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Books")
                            }
                        }
                        Spacer()
                        Text(book.name)
                            .font(.headline)
                        Spacer()
                    }
                    .padding()
                    
                    // Chapter grid
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 15) {
                            ForEach(1...book.chapters, id: \.self) { chapter in
                                Button(action: {
                                    if hasVerses(for: book.name, chapter: chapter) {
                                        // Show verse picker
                                        chapterForVerses = chapter
                                        showingVerses = true
                                    } else {
                                        // Just select the chapter
                                        selectedBook = book.name
                                        selectedChapter = chapter
                                        selectedVerse = nil
                                        dismiss()
                                        onSelect()
                                    }
                                }) {
                                    VStack {
                                        Text("\(chapter)")
                                            .frame(width: 50, height: 50)
                                            .background(
                                                selectedBook == book.name && selectedChapter == chapter ?
                                                Color.accentColor : Color.secondary.opacity(0.2)
                                            )
                                            .foregroundColor(
                                                selectedBook == book.name && selectedChapter == chapter ?
                                                Color.white : Color.primary
                                            )
                                            .cornerRadius(8)
                                        
                                        if hasVerses(for: book.name, chapter: chapter) {
                                            Image(systemName: "text.line.first.and.arrowtriangle.forward")
                                                .font(.system(size: 10))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationTitle("Select Book & Chapter")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Set initial testament based on selected book
            if let book = BibleData.books.first(where: { $0.name == selectedBook }) {
                testament = book.testament
            }
            
            // If we have a selected book, show its chapters
            if !selectedBook.isEmpty, let book = BibleData.books.first(where: { $0.name == selectedBook }) {
                bookForChapters = book
                showingChapters = true
                
                // If we have a selected verse, show verses
                if let verse = selectedVerse, verse > 0 {
                    chapterForVerses = selectedChapter
                    showingVerses = true
                }
            }
        }
    }
    
    // Filter books by testament
    private var filteredBooks: [BibleBook] {
        return BibleData.books.filter { $0.testament == testament }
    }
    
    // Get verse count for a book and chapter
    private func getVerseCount(for book: String, chapter: Int) -> Int {
        // This is a placeholder - you'll need to implement this based on your data
        // You could use a lookup table or API call to get the actual verse count
        
        // For now, using a simple mapping for common books
        let verseCounts: [String: [Int: Int]] = [
            "Genesis": [1: 31, 2: 25, 3: 24],
            "Exodus": [1: 22, 2: 25, 3: 22],
            "Psalms": [1: 6, 23: 6, 119: 176],
            "Matthew": [1: 25, 2: 23, 5: 48, 6: 34],
            "John": [1: 51, 3: 36, 14: 31],
            "Revelation": [1: 20, 22: 21]
        ]
        
        // Return the verse count if available, otherwise a default value
        return verseCounts[book]?[chapter] ?? 30
    }
    
    // Check if a book/chapter has verses (always true for now)
    private func hasVerses(for book: String, chapter: Int) -> Bool {
        // In a real app, you might check if verse-level navigation is available
        // For now, always return true to enable verse selection
        return true
    }
}

// Preview provider
struct BookChapterPickerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BookChapterPickerView(
                selectedBook: .constant("John"),
                selectedChapter: .constant(3),
                selectedVerse: .constant(16),
                onSelect: {}
            )
        }
    }
}
