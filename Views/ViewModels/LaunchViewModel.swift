//
//  LaunchViewModel.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/9/25.
//

import SwiftUI

class LaunchViewModel: ObservableObject {
    @Published var isLoading = true
    @Published var loadingProgress = 0.0
    @Published var error: Error?
    
    func initialize() async {
        // Initialize app data
        await MainActor.run {
            isLoading = true
            loadingProgress = 0.0
            error = nil
        }
        
        do {
            // Load translations
            try await TranslationService.shared.loadTranslations()
            
            // Refresh available books
            await VerseManager.shared.refreshAvailableBooks()
            
            // Simulate loading progress
            for progress in stride(from: 0.0, through: 1.0, by: 0.1) {
                await MainActor.run {
                    loadingProgress = progress
                }
                try await Task.sleep(nanoseconds: 200_000_000) // 0.2 second delay
            }
            
            await MainActor.run {
                isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error
                self.isLoading = false
            }
        }
    }
}
