//
//  NotificationManager.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/25/25.
//

import Foundation
@preconcurrency import UserNotifications
import SwiftUI

@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    @AppStorage("dailyVerseNotificationEnabled") var dailyVerseNotificationEnabled = false
    @AppStorage("dailyVerseNotificationTime") var dailyVerseNotificationTime = Calendar.current.date(from: DateComponents(hour: 8, minute: 0)) ?? Date()
    // Add these properties
    @AppStorage("midweekMotivationEnabled") var midweekMotivationEnabled = false
    @AppStorage("weekendRefocusEnabled") var weekendRefocusEnabled = false
    @AppStorage("weekendRefocusDay") var weekendRefocusDay = "Sunday" // "Saturday" or "Sunday"
    @AppStorage("betaFeedbackEnabled") var betaFeedbackEnabled = true
    @AppStorage("featureDiscoveryEnabled") var featureDiscoveryEnabled = true
    @AppStorage("hasOpenedBibleReader") var hasOpenedBibleReader = false
    @AppStorage("appLaunchCount") var appLaunchCount = 0
    @AppStorage("lastFeedbackRequestDate") var lastFeedbackRequestDate = Date.distantPast.timeIntervalSince1970
    @AppStorage("lastReadInContextPromptDate") var lastReadInContextPromptDate = Date.distantPast.timeIntervalSince1970
    
    private init() {
        checkAuthorizationStatus()
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
                if granted {
                    self.registerCategories()
                }
            }
            
            if let error = error {
                print("Push notification authorization error: \(error.localizedDescription)")
            }
        }
    }
    
    private func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    private func registerCategories() {
        // Define verse of the day category with actions
        let readNowAction = UNNotificationAction(
            identifier: "READ_NOW",
            title: "Read Now",
            options: .foreground
        )
        
        let giveFeedbackAction = UNNotificationAction(
            identifier: "GIVE_FEEDBACK",
            title: "Give Feedback",
            options: .foreground
        )
        
        let verseOfDayCategory = UNNotificationCategory(
            identifier: "VERSE_OF_DAY",
            actions: [readNowAction],
            intentIdentifiers: [],
            options: []
        )
        
        let midweekCategory = UNNotificationCategory(
            identifier: "MIDWEEK_MOTIVATION",
            actions: [readNowAction],
            intentIdentifiers: [],
            options: []
        )
        
        let weekendCategory = UNNotificationCategory(
            identifier: "WEEKEND_REFOCUS",
            actions: [readNowAction],
            intentIdentifiers: [],
            options: []
        )
        
        let feedbackCategory = UNNotificationCategory(
            identifier: "BETA_FEEDBACK",
            actions: [giveFeedbackAction],
            intentIdentifiers: [],
            options: []
        )
        
        let featureCategory = UNNotificationCategory(
            identifier: "FEATURE_DISCOVERY",
            actions: [readNowAction],
            intentIdentifiers: [],
            options: []
        )
        
        let streakCategory = UNNotificationCategory(
            identifier: "STREAK_NUDGE",
            actions: [readNowAction],
            intentIdentifiers: [],
            options: []
        )
        
        let readInContextCategory = UNNotificationCategory(
            identifier: "READ_IN_CONTEXT",
            actions: [readNowAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([
            verseOfDayCategory,
            midweekCategory,
            weekendCategory,
            feedbackCategory,
            featureCategory,
            streakCategory,
            readInContextCategory
        ])
    }
    
    func scheduleVerseOfDayNotification() {
        guard dailyVerseNotificationEnabled, isAuthorized else {
            cancelVerseOfDayNotifications()
            return
        }
        
        // Cancel any existing verse of day notifications
        cancelVerseOfDayNotifications()
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "AAVE Bible Verse of the Day"
        content.body = NotificationMessages.message(for: .dailyVerse)
        content.sound = .default
        content.categoryIdentifier = "VERSE_OF_DAY"
        
        // Extract hour and minute from the saved time
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: dailyVerseNotificationTime)
        
        // Create trigger for daily notification at specified time
        var triggerDateComponents = DateComponents()
        triggerDateComponents.hour = components.hour
        triggerDateComponents.minute = components.minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: true)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: "verse-of-day",
            content: content,
            trigger: trigger
        )
        
        // Schedule notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling verse of day notification: \(error)")
            }
        }
    }
    
    func cancelVerseOfDayNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["verse-of-day"])
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // This will be called right before displaying the notification
    func updateVerseOfDayContent(completion: @escaping () -> Void) {
        // Generate verse of the day
        let settings = SettingsViewModel.shared
        let reference = PopularScriptures.getVerseOfTheDay(
            testament: settings.verseOfDayTestament,
            book: settings.verseOfDayBook == "Any" ? nil : settings.verseOfDayBook
        )
        
        // Get verse text
        Task {
            do {
                let verseText = try await TranslationService.shared.getVerseTranslation(
                    for: reference.book,
                    chapter: reference.chapter,
                    verse: reference.verse,
                    translation: settings.verseOfDayTranslation
                )
                
                // Update notification content
                let center = UNUserNotificationCenter.current()
                let requests = await center.pendingNotificationRequests()
                let vodRequests = requests.filter { $0.identifier == "verse-of-day" }

                for request in vodRequests {
                    let updatedContent = request.content.mutableCopy() as! UNMutableNotificationContent
                    updatedContent.title = "AAVE Bible Verse of the Day"
                    updatedContent.body = "\(reference.book) \(reference.chapter):\(reference.verse) - \(verseText)"
                    updatedContent.userInfo = [
                        "book": reference.book,
                        "chapter": reference.chapter,
                        "verse": reference.verse
                    ]

                    let updatedRequest = UNNotificationRequest(
                        identifier: request.identifier,
                        content: updatedContent,
                        trigger: request.trigger
                    )

                    try? await center.add(updatedRequest)
                }

                completion()
            } catch {
                print("Error fetching verse for notification: \(error)")
                completion()
            }
        }
    }
    
    // New methods for scheduling different notification types
    func scheduleMidweekMotivation() {
        guard midweekMotivationEnabled, isAuthorized else {
            cancelNotifications(withIdentifiers: ["midweek-motivation"])
            return
        }
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Midweek Motivation"
        content.body = NotificationMessages.message(for: .midweekMotivation)
        content.sound = .default
        content.categoryIdentifier = "MIDWEEK_MOTIVATION"
        
        // Schedule for Wednesday at 12:00 PM
        var components = DateComponents()
        components.weekday = 4 // Wednesday
        components.hour = 12
        components.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: "midweek-motivation",
            content: content,
            trigger: trigger
        )
        
        // Schedule notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling midweek motivation: \(error)")
            }
        }
    }
    
    func scheduleWeekendRefocus() {
        guard weekendRefocusEnabled, isAuthorized else {
            cancelNotifications(withIdentifiers: ["weekend-refocus"])
            return
        }
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Weekend Refocus"
        content.body = NotificationMessages.message(for: .weekendRefocus)
        content.sound = .default
        content.categoryIdentifier = "WEEKEND_REFOCUS"
        
        // Schedule for Saturday or Sunday at 10:00 AM
        var components = DateComponents()
        components.weekday = weekendRefocusDay == "Sunday" ? 1 : 7 // 1 for Sunday, 7 for Saturday
        components.hour = 10
        components.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: "weekend-refocus",
            content: content,
            trigger: trigger
        )
        
        // Schedule notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling weekend refocus: \(error)")
            }
        }
    }
    
    func checkAndScheduleBetaFeedback() {
        guard betaFeedbackEnabled, isAuthorized else { return }
        
        // Only request feedback after 3+ app launches and not more than once every 5 days
        let sevenDaysInSeconds: TimeInterval = 7 * 24 * 60 * 60
        let currentTime = Date().timeIntervalSince1970
        
        if appLaunchCount >= 3 && (currentTime - lastFeedbackRequestDate) > sevenDaysInSeconds {
            // Create notification content
            let content = UNMutableNotificationContent()
            content.title = "We Value Your Feedback"
            content.body = NotificationMessages.message(for: .betaFeedback)
            content.sound = .default
            content.categoryIdentifier = "BETA_FEEDBACK"
            
            // Schedule for 1 day from now
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 24 * 60 * 60, repeats: false)
            
            // Create request
            let request = UNNotificationRequest(
                identifier: "beta-feedback-\(UUID().uuidString)",
                content: content,
                trigger: trigger
            )
            
            // Schedule notification
            UNUserNotificationCenter.current().add(request) { [weak self] error in
                if let error = error {
                    print("Error scheduling beta feedback: \(error)")
                } else {
                    // Update last feedback request date on the main thread
                    DispatchQueue.main.async {
                        self?.lastFeedbackRequestDate = currentTime
                    }
                }
            }
        }
    }
    
    func scheduleFeatureDiscovery(feature: String, description: String) {
        guard featureDiscoveryEnabled, isAuthorized else { return }
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Feature Highlight: \(feature)"
        
        // If this is a commentary notification, use the rotating book system
        if feature == "Commentary" {
            content.body = NotificationMessages.getCommentaryNotification()
        } else {
            let featureLabel = description.isEmpty ? feature : description
            content.body = NotificationMessages.message(for: .featureDiscovery(feature: featureLabel))
        }
        
        content.sound = .default
        content.categoryIdentifier = "FEATURE_DISCOVERY"
        content.userInfo = ["feature": feature]
        
        // Schedule for 30 minutes from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 30 * 60, repeats: false)
        
        // Create request with unique identifier
        let request = UNNotificationRequest(
            identifier: "feature-discovery-\(feature.lowercased().replacingOccurrences(of: " ", with: "-"))",
            content: content,
            trigger: trigger
        )
        
        // Schedule notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling feature discovery: \(error)")
            }
        }
    }
    
    // Helper method to cancel notifications by identifiers
    func cancelNotifications(withIdentifiers identifiers: [String]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    // Method to schedule all enabled notifications
    func scheduleAllNotifications() {
        scheduleVerseOfDayNotification()
        scheduleMidweekMotivation()
        scheduleWeekendRefocus()
        scheduleStreakNudge()
        checkAndScheduleBetaFeedback()
    }
    
    // Increment app launch count
    func incrementAppLaunchCount() {
        appLaunchCount += 1
        
        // Check if we should request feedback
        checkAndScheduleBetaFeedback()
    }

    func scheduleStreakNudge() {
        guard isAuthorized else {
            cancelNotifications(withIdentifiers: ["streak-nudge"])
            return
        }
        let streakCount = ReadingProgressService.shared.currentStreak
        guard streakCount > 0 else {
            cancelNotifications(withIdentifiers: ["streak-nudge"])
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Keep the streak going"
        content.body = NotificationMessages.message(for: .streakNudge)
        content.sound = .default
        content.categoryIdentifier = "STREAK_NUDGE"

        var components = DateComponents()
        components.hour = 18
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: "streak-nudge",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling streak nudge: \(error)")
            }
        }
    }

    func scheduleReadInContextNudge() {
        guard isAuthorized else { return }
        guard hasOpenedBibleReader else { return }

        let now = Date().timeIntervalSince1970
        let oneDay: TimeInterval = 24 * 60 * 60
        if now - lastReadInContextPromptDate < oneDay {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Read in context"
        content.body = NotificationMessages.message(for: .readInContext)
        content.sound = .default
        content.categoryIdentifier = "READ_IN_CONTEXT"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2 * 60 * 60, repeats: false)
        let request = UNNotificationRequest(
            identifier: "read-in-context",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { [weak self] error in
            if let error = error {
                print("Error scheduling read-in-context: \(error)")
            } else {
                DispatchQueue.main.async {
                    self?.lastReadInContextPromptDate = now
                }
            }
        }
    }

    func markBibleReaderOpened() {
        hasOpenedBibleReader = true
    }
}
