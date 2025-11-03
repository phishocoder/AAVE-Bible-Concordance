//
//  NotesView.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/12/25.
//

import SwiftUI

struct NotesView: View {
    let reference: VerseReference
    @Environment(\.dismiss) private var dismiss
    @StateObject private var userDataManager = UserDataManager.shared
    @State private var noteText: String = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("\(reference.book) \(reference.chapter):\(reference.verse)")
                    .font(.headline)
                    .padding()
                
                TextEditor(text: $noteText)
                    .font(.body)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                    .padding()
            }
            .navigationTitle("Notes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        userDataManager.saveNote(noteText, for: reference)
                        dismiss()
                    }
                }
            }
            .onAppear {
                noteText = userDataManager.getNote(for: reference)
            }
        }
    }
}
