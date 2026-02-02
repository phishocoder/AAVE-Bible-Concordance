import Foundation
import UIKit
#if canImport(ActivityKit)
import ActivityKit
#endif

enum DailyVerseLiveActivityCoordinator {
    static let enabledKey = "lockScreenDailyVerseEnabled"
    static let jesusSaidKey = "lockScreenJesusSaidEnabled"
    static let versionKey = "lockScreenVerseVersion"

    static let homeVerseIdKey = "homeDailyVerseId"
    static let homeReferenceKey = "homeDailyVerseReference"
    static let homeExcerptKey = "homeDailyVerseExcerpt"
    static let homeIsJesusSaidKey = "homeDailyVerseIsJesusSaid"
    static let homeVersionUsedKey = "homeDailyVerseVersionUsed"
    static let homeUpdatedAtKey = "homeDailyVerseUpdatedAt"

    static func setEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: enabledKey)
        guard #available(iOS 16.1, *) else { return }

        Task {
            if enabled {
                await DailyVerseLiveActivityManager.shared.refreshIfNeeded(forceUpdate: true)
            } else {
                await DailyVerseLiveActivityManager.shared.endAllActivities()
            }
        }
    }

    static func handleAppActive() {
        guard UserDefaults.standard.bool(forKey: enabledKey) else { return }
        guard #available(iOS 16.1, *) else { return }

        Task {
            let osVersion = UIDevice.current.systemVersion
            let authorization = ActivityAuthorizationInfo()
            print("Live Activities debug: iOS=\(osVersion), enabled=\(authorization.areActivitiesEnabled)")
            await DailyVerseLiveActivityManager.shared.refreshIfNeeded(forceUpdate: false)
        }
    }

    static func refreshIfEnabled() {
        guard UserDefaults.standard.bool(forKey: enabledKey) else { return }
        guard #available(iOS 16.1, *) else { return }

        Task {
            await DailyVerseLiveActivityManager.shared.refreshIfNeeded(forceUpdate: true)
        }
    }

    /// Call this from Home screen whenever the displayed verse changes (especially Jesus Said mode).
    static func setHomeDisplayedVerse(
        verseId: String,
        reference: String,
        excerpt: String,
        isJesusSaid: Bool,
        versionUsed: String
    ) {
        UserDefaults.standard.set(verseId, forKey: homeVerseIdKey)
        UserDefaults.standard.set(reference, forKey: homeReferenceKey)
        UserDefaults.standard.set(excerpt, forKey: homeExcerptKey)
        UserDefaults.standard.set(isJesusSaid, forKey: homeIsJesusSaidKey)
        UserDefaults.standard.set(versionUsed, forKey: homeVersionUsedKey)
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: homeUpdatedAtKey)

        // If Live Activities are enabled, push an immediate refresh so the lock screen matches Home.
        refreshIfEnabled()
    }
}

@available(iOS 16.1, *)
final class DailyVerseLiveActivityManager {
    static let shared = DailyVerseLiveActivityManager()

    private let defaults = UserDefaults.standard
    private let lastUpdateKey = "dailyVerseLastUpdateTime"
    private let lastVerseIdKey = "dailyVerseLastVerseId"
    private let lastModeKey = "dailyVerseLastMode"
    private let lastVersionKey = "dailyVerseLastVersion"

    private init() {}

    private struct HomeVerseSnapshot {
        let verseId: String
        let reference: String
        let excerpt: String
        let isJesusSaid: Bool
        let versionUsedRaw: String
        let updatedAt: Date
    }

    private func readHomeVerseSnapshot() -> HomeVerseSnapshot? {
        let verseId = defaults.string(forKey: DailyVerseLiveActivityCoordinator.homeVerseIdKey) ?? ""
        let reference = defaults.string(forKey: DailyVerseLiveActivityCoordinator.homeReferenceKey) ?? ""
        let excerpt = defaults.string(forKey: DailyVerseLiveActivityCoordinator.homeExcerptKey) ?? ""
        let isJesusSaid = defaults.bool(forKey: DailyVerseLiveActivityCoordinator.homeIsJesusSaidKey)
        let versionUsedRaw = defaults.string(forKey: DailyVerseLiveActivityCoordinator.homeVersionUsedKey) ?? ""
        let updated = defaults.double(forKey: DailyVerseLiveActivityCoordinator.homeUpdatedAtKey)

        guard !verseId.isEmpty, !reference.isEmpty, !excerpt.isEmpty, updated > 0 else { return nil }
        return HomeVerseSnapshot(
            verseId: verseId,
            reference: reference,
            excerpt: excerpt,
            isJesusSaid: isJesusSaid,
            versionUsedRaw: versionUsedRaw,
            updatedAt: Date(timeIntervalSince1970: updated)
        )
    }

    func refreshIfNeeded(forceUpdate: Bool) async {
        guard defaults.bool(forKey: DailyVerseLiveActivityCoordinator.enabledKey) else { return }
        let authorization = ActivityAuthorizationInfo()
        print("LA-DEBUG refreshIfNeeded enabled=\(authorization.areActivitiesEnabled)")
        guard authorization.areActivitiesEnabled else {
            print("LA-DEBUG refreshIfNeeded early-exit activities disabled")
            return
        }

        let today = Calendar.current.startOfDay(for: Date())
        let lastUpdate = Date(timeIntervalSince1970: defaults.double(forKey: lastUpdateKey))
        let needsUpdate = !Calendar.current.isDate(lastUpdate, inSameDayAs: today)
        let jesusSaidOnly = defaults.bool(forKey: DailyVerseLiveActivityCoordinator.jesusSaidKey)
        let preferredRaw = defaults.string(forKey: DailyVerseLiveActivityCoordinator.versionKey) ?? VerseVersion.aave.rawValue
        let preferredVersion = VerseVersion(rawValue: preferredRaw) ?? .aave
        let lastMode = defaults.string(forKey: lastModeKey)
        let lastVersion = defaults.string(forKey: lastVersionKey)
        let settingsChanged = lastMode != (jesusSaidOnly ? "jesus" : "daily") || lastVersion != preferredVersion.rawValue

        let homeSnapshot = readHomeVerseSnapshot()

        // Prefer the verse currently displayed on Home so Lock Screen always matches what the user sees.
        // If user is in Jesus Said mode, only accept a snapshot that isJesusSaid=true.
        if let snap = homeSnapshot, (!jesusSaidOnly || snap.isJesusSaid) {
            let versionUsed = VerseVersion(rawValue: snap.versionUsedRaw) ?? preferredVersion
            let contentState = DailyVerseAttributes.ContentState(
                reference: snap.reference,
                excerpt: snap.excerpt,
                verseId: snap.verseId,
                versionLabel: versionUsed.rawValue,
                isJesusSaid: snap.isJesusSaid
            )

            print("LA-DEBUG using HOME snapshot verseId=\(snap.verseId) isJesusSaid=\(snap.isJesusSaid) versionUsed=\(versionUsed.rawValue)")
            await upsertActivity(
                contentState: contentState,
                today: today,
                verseId: snap.verseId,
                mode: jesusSaidOnly,
                version: versionUsed.rawValue,
                forceUpdate: forceUpdate,
                needsUpdate: needsUpdate,
                settingsChanged: settingsChanged
            )
            return
        }

        guard let todayVerse = await VerseOfDayProvider.today(
            jesusSaidOnly: jesusSaidOnly,
            preferredVersion: preferredVersion
        ) else {
            print("LA-DEBUG no daily verse available for mode=\(jesusSaidOnly ? "jesus" : "daily")")
            return
        }

        print("LA-DEBUG mode jesusSaidOnly=\(jesusSaidOnly) requestedVersion=\(preferredVersion.rawValue) versionUsed=\(todayVerse.versionUsed.rawValue)")
        print("LA-DEBUG selection verseId=\(todayVerse.verseId) isJesusSaid=\(todayVerse.isJesusSaid) versionUsed=\(todayVerse.versionUsed.rawValue)")
        print("LA-DEBUG content reference=\(todayVerse.reference) excerptLength=\(todayVerse.excerpt.count) verseId=\(todayVerse.verseId)")
        let contentState = DailyVerseAttributes.ContentState(
            reference: todayVerse.reference,
            excerpt: todayVerse.excerpt,
            verseId: todayVerse.verseId,
            versionLabel: todayVerse.versionUsed.rawValue,
            isJesusSaid: todayVerse.isJesusSaid
        )

        await upsertActivity(
            contentState: contentState,
            today: today,
            verseId: todayVerse.verseId,
            mode: jesusSaidOnly,
            version: todayVerse.versionUsed.rawValue,
            forceUpdate: forceUpdate,
            needsUpdate: needsUpdate,
            settingsChanged: settingsChanged
        )
    }

    private func upsertActivity(
        contentState: DailyVerseAttributes.ContentState,
        today: Date,
        verseId: String,
        mode: Bool,
        version: String,
        forceUpdate: Bool,
        needsUpdate: Bool,
        settingsChanged: Bool
    ) async {
        if let activity = Activity<DailyVerseAttributes>.activities.first {
            if forceUpdate || needsUpdate || settingsChanged || defaults.string(forKey: lastVerseIdKey) != verseId {
                await activity.update(using: contentState)
                recordUpdate(for: today, verseId: verseId, mode: mode, version: version)
            }
            return
        }

        do {
            debugDailyVerseLiveActivities("before-request")
            let attributes = DailyVerseAttributes(activityId: UUID().uuidString)
            let activity = try Activity.request(attributes: attributes, contentState: contentState)
            print("LA-DEBUG request SUCCESS id=\(activity.id)")
            print("LA-DEBUG UI should render via widget extension: AAVEBibleLiveActivities")
            debugDailyVerseLiveActivities("after-request-success")
            recordUpdate(for: today, verseId: verseId, mode: mode, version: version)
        } catch {
            print("LA-DEBUG request FAILED error=\(error)")
            debugDailyVerseLiveActivities("after-request-failed")
        }
    }

    func endAllActivities() async {
        for activity in Activity<DailyVerseAttributes>.activities {
            await activity.end(dismissalPolicy: .immediate)
        }
    }

    private func recordUpdate(for date: Date, verseId: String, mode: Bool, version: String) {
        defaults.set(date.timeIntervalSince1970, forKey: lastUpdateKey)
        defaults.set(verseId, forKey: lastVerseIdKey)
        defaults.set(mode ? "jesus" : "daily", forKey: lastModeKey)
        defaults.set(version, forKey: lastVersionKey)
    }
}
