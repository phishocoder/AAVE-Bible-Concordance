//
//  SettingsView.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/6/25.
//
import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showingAbout = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Appearance")) {
                    Picker("Theme", selection: $viewModel.appearanceMode) {
                        Text("System").tag("system")
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Picker("Font", selection: $viewModel.fontFamily) {
                        ForEach(viewModel.availableFonts, id: \.self) { font in
                            Text(font).tag(font)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Text Size: \(Int(viewModel.fontSize))")
                        Slider(value: $viewModel.fontSize, in: 12...24, step: 1)
                    }
                    
                    Picker("Home Screen Tagline", selection: $viewModel.tagline) {
                        ForEach(viewModel.availableTaglines, id: \.self) { tagline in
                            Text(tagline).tag(tagline)
                        }
                    }
                }
                
                Section(header: Text("Content")) {
                    Toggle(isOn: $viewModel.showCommentary) {
                        Label("Show Commentary", systemImage: "text.book.closed")
                    }
                    
                    Picker("Preferred Translation", selection: $viewModel.preferredTranslation) {
                        Text("AAVE").tag("AAVE")
                        Text("NET").tag("NET")
                    }
                    
                    Toggle(isOn: $viewModel.showAlternateTranslation) {
                        Label("Show Alternate Translation", systemImage: "doc.on.doc")
                    }
                }
                
                Section(header: Text("Saved Content")) {
                    NavigationLink(destination: BookmarkView()) {
                        Label("Bookmarks", systemImage: "bookmark")
                    }
                }
                
                Section(header: Text("Notifications & Reminders")) {
                    NavigationLink(destination: NotificationSettingsView()) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.blue)
                            Text("Notifications")
                        }
                    }
                    
                    NavigationLink(destination: VerseOfDaySettingsView()) {
                        HStack {
                            Image(systemName: "dice.fill")
                                .foregroundColor(.orange)
                            Text("Random Verse")
                        }
                    }
                }
                
                Section {
                    Button(action: {
                        showingAbout = true
                    }) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                            Text("About")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
        }
    }
}

