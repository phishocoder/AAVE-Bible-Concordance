//
//  AppDelegate.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/25/25.
//

import UIKit
import UserNotifications
import FirebaseCore



class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Set notification delegate
        FirebaseApp.configure()
        print("✅ Firebase is configured!")
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    // Called when a notification is delivered to a foreground app
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show the notification even when app is in foreground
        completionHandler([.banner, .sound])
    }
    
    // Called when user taps on a notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        // Handle notification tap based on category
        switch response.notification.request.content.categoryIdentifier {
        case "VERSE_OF_DAY", "MIDWEEK_MOTIVATION", "WEEKEND_REFOCUS":
            if let book = userInfo["book"] as? String,
               let chapter = userInfo["chapter"] as? Int,
               let verse = userInfo["verse"] as? Int {
                
                // Navigate to the verse
                NotificationCenter.default.post(
                    name: Notification.Name("NavigateToChapter"),
                    object: nil,
                    userInfo: [
                        "book": book,
                        "chapter": chapter,
                        "verse": verse,
                        "shouldHighlight": true
                    ]
                )
            }
            
        case "BETA_FEEDBACK":
            if response.actionIdentifier == "GIVE_FEEDBACK" {
                // Navigate to feedback form
                NotificationCenter.default.post(
                    name: Notification.Name("ShowFeedbackForm"),
                    object: nil
                )
            }
            
        case "FEATURE_DISCOVERY":
            if let feature = userInfo["feature"] as? String {
                // Navigate to the specific feature
                NotificationCenter.default.post(
                    name: Notification.Name("ShowFeature"),
                    object: nil,
                    userInfo: ["feature": feature]
                )
            }
            
        default:
            break
        }
        
        completionHandler()
    }
}
