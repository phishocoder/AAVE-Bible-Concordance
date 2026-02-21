//
//  NotesView.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/12/25.
//

import SwiftUI

struct NotesView: View {
    private let reference: VerseReference?
    @Environment(\.dismiss) private var dismiss
    @StateObject private var userDataManager = UserDataManager.shared

    init(reference: VerseReference) {
        self.reference = reference
    }

    init() {
        self.reference = nil
    }

    var body: some View {
        NavigationStack {
            if let reference {
                NotesEditorContent(
                    reference: reference,
                    onClose: { dismiss() }
                )
            } else {
                NotesLibraryContent()
            }
        }
    }
}

private struct NotesLibraryContent: View {
    @StateObject private var userDataManager = UserDataManager.shared

    @State private var searchText = ""
    @State private var showingVersePicker = false
    @State private var selectedBook = "Genesis"
    @State private var selectedChapter = 1
    @State private var selectedVerse: Int? = 1
    @State private var editorReference: VerseReference?

    private var noteItems: [NoteItem] {
        userDataManager.notes.compactMap { key, text in
            guard let reference = VerseReference.fromKey(key), !text.isEmpty else {
                return nil
            }
            return NoteItem(reference: reference, text: text)
        }
        .sorted { lhs, rhs in
            let lhsBook = bookSortOrder[lhs.reference.book] ?? Int.max
            let rhsBook = bookSortOrder[rhs.reference.book] ?? Int.max
            if lhsBook != rhsBook { return lhsBook < rhsBook }
            if lhs.reference.chapter != rhs.reference.chapter { return lhs.reference.chapter < rhs.reference.chapter }
            return lhs.reference.verse < rhs.reference.verse
        }
    }

    private var bookSortOrder: [String: Int] {
        Dictionary(uniqueKeysWithValues: bibleBooks.enumerated().map { index, book in
            (book.name, index)
        })
    }

    private var filteredNoteItems: [NoteItem] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return noteItems
        }

        return noteItems.filter { item in
            item.reference.displayString.localizedCaseInsensitiveContains(searchText) ||
            item.text.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var resultCountText: String {
        let count = filteredNoteItems.count
        return count == 1 ? "1 result" : "\(count) results"
    }

    var body: some View {
        List {
            if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(resultCountText)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 4, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }

            ForEach(filteredNoteItems) { item in
                Button {
                    editorReference = item.reference
                } label: {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(item.reference.displayString)
                            .font(.headline)
                        Text(item.text)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineLimit(3)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .homeCard()
                }
                .buttonStyle(.plain)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .swipeActions {
                    Button(role: .destructive) {
                        userDataManager.removeNote(for: item.reference)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .glassBackground()
        .applyGlassToolbar()
        .navigationTitle("Notes")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "Search notes")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    selectedBook = "Genesis"
                    selectedChapter = 1
                    selectedVerse = 1
                    showingVersePicker = true
                } label: {
                    Label("Add Note", systemImage: "plus")
                }
            }
        }
        .overlay {
            if noteItems.isEmpty {
                ContentUnavailableView(
                    "No Notes Yet",
                    systemImage: "note.text",
                    description: Text("Pick a verse and add your own note.")
                )
            } else if filteredNoteItems.isEmpty {
                ContentUnavailableView(
                    "No Results",
                    systemImage: "magnifyingglass",
                    description: Text("Try searching by verse reference or note text.")
                )
            }
        }
        .sheet(isPresented: $showingVersePicker) {
            NavigationStack {
                BookChapterPickerView(
                    selectedBook: $selectedBook,
                    selectedChapter: $selectedChapter,
                    selectedVerse: $selectedVerse
                ) {
                    guard let selectedVerse else { return }
                    editorReference = VerseReference(
                        book: selectedBook,
                        chapter: selectedChapter,
                        verse: selectedVerse
                    )
                    showingVersePicker = false
                }
            }
        }
        .sheet(item: $editorReference) { selected in
            NotesView(reference: selected)
        }
    }
}

private struct NotesEditorContent: View {
    let reference: VerseReference
    let onClose: () -> Void

    @StateObject private var userDataManager = UserDataManager.shared
    @State private var noteText = ""
    @State private var originalText = ""

    private var characterCount: Int { noteText.count }
    private var characterLimit: Int { UserDataManager.noteCharacterLimit }
    private var isSaveDisabled: Bool {
        noteText.trimmingCharacters(in: .whitespacesAndNewlines) == originalText
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(reference.displayString)
                        .font(.headline)
                    Text("Write your reflection, prayer, or takeaway for this verse.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .homeCard()

                VStack(alignment: .leading, spacing: 10) {
                    TextEditor(text: $noteText)
                        .font(.body)
                        .frame(minHeight: 220, alignment: .topLeading)
                        .onChange(of: noteText) { _, newValue in
                            if newValue.count > characterLimit {
                                noteText = String(newValue.prefix(characterLimit))
                            }
                        }

                    HStack {
                        Text("\(characterCount)/\(characterLimit)")
                            .font(.caption)
                            .foregroundColor(characterCount >= characterLimit ? .orange : .secondary)
                        Spacer()
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.thinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(Color.white.opacity(0.18), lineWidth: 1)
                        )
                )
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
        }
        .scrollIndicators(.hidden)
        .glassBackground()
        .applyGlassToolbar()
        .navigationTitle("Verse Note")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel", action: onClose)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    userDataManager.saveNote(noteText, for: reference)
                    onClose()
                }
                .disabled(isSaveDisabled)
            }
        }
        .onAppear {
            let existing = userDataManager.getNote(for: reference)
            originalText = existing
            noteText = existing
        }
    }
}

private struct NoteItem: Identifiable {
    let reference: VerseReference
    let text: String

    var id: String { reference.id }
}

#Preview("Notes Library") {
    NotesView()
}

#Preview("Notes Editor") {
    NotesView(reference: VerseReference(book: "John", chapter: 3, verse: 16))
}
