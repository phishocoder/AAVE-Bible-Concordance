//
//  MoreView.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/15/25.
//

import SwiftUI

struct MoreView: View {
    @State private var showingSettings = false
    @ObservedObject private var userDataManager = UserDataManager.shared

    var body: some View {
        NavigationView {
            List {
                // MARK: - Bible Study Tools
                Section(header: Text("Bible Study")) {
                    NavigationLink(destination: BookmarkView()) {
                        Label("Bookmarks", systemImage: "bookmark")
                    }

                    NavigationLink(destination: NotesView(reference: VerseReference(book: "", chapter: 1, verse: 1))) {
                        Label("Notes", systemImage: "note.text")
                    }

                    NavigationLink(destination: LeaderboardView()) {
                        Label("Leaderboard", systemImage: "list.number")
                    }
                }

                // MARK: - Daily Inspiration
                Section(header: Text("Daily Content")) {
                    NavigationLink(destination: VerseOfDaySettingsView()) {
                        Label("Random Verse Generator", systemImage: "die.face.5")
                    }
                }

                // MARK: - About the App
                Section(header: Text("About")) {
                    NavigationLink(destination: AboutView()) {
                        Label("About This App", systemImage: "info.circle")
                    }

                    NavigationLink(destination: CreditsView()) {
                        Label("Credits", systemImage: "person.2")
                    }

                    Link(destination: URL(string: "https://docs.google.com/document/d/19wITcvOSlMepW2D1hXNi4Uf8LS4PrqU7/edit")!) {
                        HStack {
                            Label("Privacy Policy", systemImage: "lock.shield")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                        }
                    }
                }

                // MARK: - App Settings
                Section(header: Text("App")) {
                    Button(action: { showingSettings = true }) {
                        Label("Settings", systemImage: "gear")
                    }
                }
            }
            .navigationTitle("More")
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }
}

// MARK: - Notes Archive View (Nested)
extension MoreView {
    struct MoreNotesView: View {
        @ObservedObject private var userDataManager = UserDataManager.shared

        var body: some View {
            List {
                if userDataManager.notes.isEmpty {
                    ContentUnavailableView(
                        "No Notes",
                        systemImage: "note.text",
                        description: Text("Your notes will appear here")
                    )
                } else {
                    ForEach(Array(userDataManager.notes.keys), id: \.self) { key in
                        if let note = userDataManager.notes[key], !note.isEmpty {
                            NavigationLink {
                                if let reference = VerseReference.fromKey(key) {
                                    VerseDetailView(reference: reference)
                                }
                            } label: {
                                VStack(alignment: .leading) {
                                    if let reference = VerseReference.fromKey(key) {
                                        Text(reference.displayString)
                                            .font(.headline)
                                    }
                                    Text(note)
                                        .font(.body)
                                        .lineLimit(2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Notes")
        }
    }
}
