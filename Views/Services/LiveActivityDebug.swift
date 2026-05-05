import Foundation
#if canImport(ActivityKit)
import ActivityKit
#endif

@available(iOS 16.1, *)
func debugDailyVerseLiveActivities(_ label: String) {
#if DEBUG
#if canImport(ActivityKit)
    let authorization = ActivityAuthorizationInfo()
    let activities = Activity<DailyVerseAttributes>.activities
    print("LA-DEBUG \(label) enabled=\(authorization.areActivitiesEnabled) count=\(activities.count)")
    for activity in activities {
        print("LA-DEBUG \(label) id=\(activity.id) state=\(activity.activityState)")
    }
#else
    print("LA-DEBUG \(label) ActivityKit unavailable")
#endif
#endif
}
