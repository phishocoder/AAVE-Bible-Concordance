//
//  VerseofDaySettingsView.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/16/25.
//

import SwiftUI

struct VerseOfDaySettingsView: View {
    @ObservedObject var settings = SettingsViewModel.shared
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var translationService = TranslationService.shared
    
    private let testamentOptions = ["Both", "Old Testament", "New Testament"]
    private let bookOptions: [String] = ["Any"] + bibleBooks.map { $0.name }
    private let translationOptions = Array(APIConfig.supportedVersions.keys)
    
    @State private var showToast = false
    @State private var toastMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Testament")) {
                    Picker("Testament", selection: $settings.verseOfDayTestament) {
                        ForEach(testamentOptions, id: \.self) { testament in
                            Text(testament).tag(testament)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: settings.verseOfDayTestament) { _, _ in
                        // Reset book selection when testament changes
                        if settings.verseOfDayBook != "Any" {
                            let testament = settings.verseOfDayTestament
                            let book = settings.verseOfDayBook
                            let isOldTestament = bibleBooks.first(where: { $0.name == book })?.testament == .old
                            let isNewTestament = bibleBooks.first(where: { $0.name == book })?.testament == .new
                            
                            if (testament == "Old Testament" && !isOldTestament) ||
                               (testament == "New Testament" && !isNewTestament) {
                                settings.verseOfDayBook = "Any"
                            }
                        }
                    }
                }
                
                Section(header: Text("Book")) {
                    Picker("Book", selection: $settings.verseOfDayBook) {
                        ForEach(filteredBookOptions, id: \.self) { book in
                            if isBookAvailable(book) {
                                Text(book).tag(book)
                            } else {
                                Text(book)
                                    .foregroundColor(.gray)
                                    .tag(book)
                            }
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: settings.verseOfDayBook) { oldValue, newValue in
                        if newValue != "Any" && newValue != oldValue && isBookAvailable(newValue) {
                            generateNewVerse()
                            showToastMessage("New verse from \(newValue) selected!")
                        }
                    }
                }
                
                Section(header: Text("Translation")) {
                    Picker("Translation", selection: $settings.verseOfDayTranslation) {
                        ForEach(translationOptions, id: \.self) { translation in
                            Text(translation).tag(translation)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: settings.verseOfDayTranslation) { _, _ in
                        generateNewVerse()
                    }
                }
                
                Section {
                    Button("Generate New Verse") {
                        generateNewVerse()
                        showToastMessage("New verse generated!")
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("Random Verse Generator")
            .navigationBarItems(trailing: Button("Done") {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                dismiss()
            })
            .overlay(alignment: .bottom) {
                ToastView(message: toastMessage, isShowing: $showToast)
                    .padding(.bottom, 20)
            }
        }
    }
    
    private var filteredBookOptions: [String] {
        let allBooks = ["Any"] + bibleBooks.map { $0.name }
        
        if settings.verseOfDayTestament == "Both" {
            return allBooks
        } else if settings.verseOfDayTestament == "Old Testament" {
            return ["Any"] + bibleBooks.filter { $0.testament == .old }.map { $0.name }
        } else {
            return ["Any"] + bibleBooks.filter { $0.testament == .new }.map { $0.name }
        }
    }
    
    private func isBookAvailable(_ book: String) -> Bool {
        if book == "Any" { return true }
        
        if settings.verseOfDayTranslation.uppercased() == "AAVE" {
            return translationService.isAAVEAvailable(for: book)
        }
        
        return true // Assume all books are available in other translations
    }
    
    private func generateNewVerse() {
        NotificationCenter.default.post(name: Notification.Name("RefreshVerseOfTheDay"), object: nil)
    }
    
    private func showToastMessage(_ message: String) {
        toastMessage = message
        showToast = true
        
        // Hide toast after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showToast = false
        }
    }
}

#Preview {
    VerseOfDaySettingsView()
}
