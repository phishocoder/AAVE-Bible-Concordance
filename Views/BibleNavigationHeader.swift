//
//  BibleNavigationHeader.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/16/25.
//

import SwiftUI

struct BibleNavigationHeader: View {
    @Binding var currentBook: String
    @Binding var currentChapter: Int
    @EnvironmentObject var settings: SettingsViewModel
    
    @State private var showingBookPicker = false
    @State private var showingChapterPicker = false
    @State private var showingTranslationPicker = false
    
 
    private let availableTranslations = APIConfig.supportedVersions
    
    var body: some View {
        HStack {
            Button(action: {
                showingBookPicker = true
            }) {
                HStack {
                    Text("\(currentBook) \(currentChapter)")
                        .font(.headline)
                    Image(systemName: "chevron.down")
                        .font(.caption)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)
            }
            .sheet(isPresented: $showingBookPicker) {
                BookChapterPickerView(
                    selectedBook: $currentBook,
                    selectedChapter: $currentChapter,
                    onSelect: {
                        showingBookPicker = false
                    }
                )
            }
            
            Spacer()
            
            Button(action: {
                showingTranslationPicker = true
            }) {
                Text(settings.preferredTranslation)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal)
    }
}
