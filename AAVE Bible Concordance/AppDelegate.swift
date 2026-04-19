//
//  AppDelegate.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/25/25.
//

import UIKit
import UserNotifications
import FirebaseCore
import FirebaseMessaging

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {

        // Firebase setup
        FirebaseApp.configure()
        print("✅ Firebase is configured!")

        // Set delegates
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self

        // Request permission for push notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            print("🔔 Notification permission granted: \(granted)")
        }

        // Register with APNs
        application.registerForRemoteNotifications()
        print("✅ Called registerForRemoteNotifications()")

        // Fallback manual FCM token check
        Messaging.messaging().token { token, error in
            if let token = token {
                print("✅ Manual FCM Token fetch: \(token)")
            } else if let error = error {
                print("❌ Error fetching FCM token: \(error.localizedDescription)")
            }
        }

        return true
    }

    // MARK: - APNs Token Handler
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("✅ SYSTEM: didRegisterForRemoteNotificationsWithDeviceToken CALLED")

        // Log raw token for verification
        let tokenParts = deviceToken.map { String(format: "%02.2hhx", $0) }
        let rawToken = tokenParts.joined()
        print("✅ APNs Token (raw): \(rawToken)")

        // Set for Firebase
        Messaging.messaging().apnsToken = deviceToken
        print("✅ APNs device token set for Firebase")
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❌ SYSTEM: didFailToRegisterForRemoteNotificationsWithError - \(error.localizedDescription)")
    }

    // MARK: - FCM Token Handler
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("✅ FCM Token (via delegate): \(fcmToken ?? "nil")")
        // Optional: Store in Firestore if needed
    }

    // MARK: - Foreground Push Display
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        Task { @MainActor in
            NotificationManager.shared.markNotificationDelivered()
        }
        completionHandler([.banner, .sound])
    }

    // MARK: - Push Tap Behavior
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        Task { @MainActor in
            NotificationManager.shared.markNotificationDelivered()
        }
        let userInfo = response.notification.request.content.userInfo

        switch response.notification.request.content.categoryIdentifier {
        case "VERSE_OF_DAY", "MIDWEEK_MOTIVATION", "WEEKEND_REFOCUS":
            if let route = verseRoute(from: userInfo) {
                Task { @MainActor in
                    NotificationNavigationBridge.shared.enqueue(route)
                }
            } else {
                print("Notification tap ignored: missing or malformed verse payload \(userInfo)")
            }

        case "BETA_FEEDBACK":
            if response.actionIdentifier == "GIVE_FEEDBACK" {
                NotificationCenter.default.post(
                    name: Notification.Name("ShowFeedbackForm"),
                    object: nil
                )
            }

        case "FEATURE_DISCOVERY":
            if let feature = userInfo["feature"] as? String {
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

    private func verseRoute(from userInfo: [AnyHashable: Any]) -> AppRoute? {
        guard let rawBook = userInfo["book"] as? String,
              let chapter = notificationIntValue(userInfo["chapter"]),
              let verse = notificationIntValue(userInfo["verse"]) else {
            return nil
        }

        let canonicalBook = BookNameNormalizer.canonicalBookName(rawBook) ?? rawBook
        return .bible(bookID: canonicalBook, chapter: chapter, verse: verse)
    }

    private func notificationIntValue(_ rawValue: Any?) -> Int? {
        switch rawValue {
        case let value as Int:
            return value
        case let value as NSNumber:
            return value.intValue
        case let value as String:
            return Int(value.trimmingCharacters(in: .whitespacesAndNewlines))
        default:
            return nil
        }
    }
}
