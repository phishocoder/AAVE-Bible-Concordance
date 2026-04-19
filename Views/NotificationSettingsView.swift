//
//  NotificationSettingsView.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/25/25.
//

import SwiftUI

struct NotificationSettingsView: View {
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var showTimePicker = false
    
    var body: some View {
        Form {
            Section(header: Text("Notifications")) {
                if !notificationManager.isAuthorized {
                    Button("Enable Notifications") {
                        notificationManager.requestAuthorization()
                    }
                    .foregroundColor(.blue)
                }
                
                if notificationManager.isAuthorized {
                    Toggle("Daily Verse", isOn: $notificationManager.dailyVerseNotificationEnabled)
                        .onChange(of: notificationManager.dailyVerseNotificationEnabled) { _, _ in
                            notificationManager.scheduleVerseOfDayNotification()
                        }
                    
                    if notificationManager.dailyVerseNotificationEnabled {
                        HStack {
                            Text("Time")
                            Spacer()
                            Button(action: {
                                showTimePicker = true
                            }) {
                                Text(timeFormatter.string(from: notificationManager.dailyVerseNotificationTime))
                                    .foregroundColor(.blue)
                            }
                        }
                        if notificationManager.smartTimingEnabled {
                            let optimized = notificationManager.smartTimingDescription() ?? "Not enough recent activity yet"
                            Text("Smart Timing is on. Auto-optimized target: \(optimized). Manual time remains as backup.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }

                    Toggle("Smart Timing", isOn: $notificationManager.smartTimingEnabled)
                        .onChange(of: notificationManager.smartTimingEnabled) { _, _ in
                            notificationManager.scheduleVerseOfDayNotification()
                        }
                    Text("Uses your local 7-day open pattern to optimize Daily Verse timing. Updates at most once per week.")
                        .font(.footnote)
                        .foregroundColor(.secondary)

                    Toggle("Gentle Mode", isOn: $notificationManager.gentleModeEnabled)
                        .onChange(of: notificationManager.gentleModeEnabled) { _, _ in
                            notificationManager.scheduleAllNotifications()
                        }
                    Text("Shorter, softer notification copy with no urgency language.")
                        .font(.footnote)
                        .foregroundColor(.secondary)

                    Toggle("Streak Nudge", isOn: $notificationManager.streakNudgeEnabled)
                        .onChange(of: notificationManager.streakNudgeEnabled) { _, _ in
                            notificationManager.scheduleStreakNudge()
                        }
                    Text("Optional reminder only when your streak is established and no other push has gone out today.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                    Toggle("Midweek Motivation", isOn: $notificationManager.midweekMotivationEnabled)
                        .onChange(of: notificationManager.midweekMotivationEnabled) { _, _ in
                            notificationManager.scheduleMidweekMotivation()
                        }
                    
                    Toggle("Weekend Refocus", isOn: $notificationManager.weekendRefocusEnabled)
                        .onChange(of: notificationManager.weekendRefocusEnabled) { _, _ in
                            notificationManager.scheduleWeekendRefocus()
                        }
                    
                    if notificationManager.weekendRefocusEnabled {
                        Picker("Day", selection: $notificationManager.weekendRefocusDay) {
                            Text("Saturday").tag("Saturday")
                            Text("Sunday").tag("Sunday")
                        }
                        .onChange(of: notificationManager.weekendRefocusDay) { _, _ in
                            notificationManager.scheduleWeekendRefocus()
                        }
                    }
                    
                    Toggle("App Feedback", isOn: $notificationManager.betaFeedbackEnabled)
                        .onChange(of: notificationManager.betaFeedbackEnabled) { _, _ in
                            notificationManager.scheduleAllNotifications()
                        }
                    
                    Toggle("Feature Discovery", isOn: $notificationManager.featureDiscoveryEnabled)
                        .onChange(of: notificationManager.featureDiscoveryEnabled) { _, _ in
                            notificationManager.scheduleAllNotifications()
                        }
                    Text("Feature Discovery is intentionally rare. Most feature tips now appear in-app.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Notification Settings")
        .sheet(isPresented: $showTimePicker) {
            TimePickerView(selectedTime: $notificationManager.dailyVerseNotificationTime, isPresented: $showTimePicker)
                .onChange(of: notificationManager.dailyVerseNotificationTime) { _, _ in
                    notificationManager.scheduleVerseOfDayNotification()
                }
        }
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}

struct TimePickerView: View {
    @Binding var selectedTime: Date
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
            }
            .navigationTitle("Select Time")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Save") {
                    isPresented = false
                }
            )
        }
    }
}

#Preview {
    NotificationSettingsView()
}
