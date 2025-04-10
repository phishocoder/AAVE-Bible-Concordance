//
//  BookChapterPickerView.swift
//  AAVE Bible Concordance
//

import SwiftUI

struct BookChapterPickerView: View {
    @Binding var selectedBook: String
    @Binding var selectedChapter: Int
    @Environment(\.dismiss) private var dismiss
    
    var onSelect: () -> Void
    
    @State private var testament: Testament = .old
    @State private var showingChapters = false
    @State private var bookForChapters: BibleBook?
    
    var body: some View {
        VStack(spacing: 0) {
            // Testament selector
            Picker("Testament", selection: $testament) {
                Text("Old Testament").tag(Testament.old)
                Text("New Testament").tag(Testament.new)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            if !showingChapters {
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
            } else if let book = bookForChapters {
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
                                    selectedBook = book.name
                                    selectedChapter = chapter
                                    dismiss()
                                    onSelect()
                                }) {
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
            if let book = BibleData.bibleBooks.first(where: { $0.name == selectedBook }) {
                testament = book.testament
            }
            
            // If we have a selected book, show its chapters
            if !selectedBook.isEmpty, let book = BibleData.bibleBooks.first(where: { $0.name == selectedBook }) {
                bookForChapters = book
                showingChapters = true
            }
        }
    }
    
    // Filter books by testament
    private var filteredBooks: [BibleBook] {
        return BibleData.bibleBooks.filter { $0.testament == testament }
    }
}
