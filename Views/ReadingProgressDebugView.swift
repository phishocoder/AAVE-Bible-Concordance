import SwiftUI

struct ReadingProgressDebugView: View {
    @ObservedObject private var progress = ReadingProgressService.shared

    var body: some View {
        List {
            Section("Progress") {
                row("Last Read", value: formattedDate(progress.lastReadDate))
                row("Current Streak", value: "\(progress.currentStreak)")
                row("Longest Streak", value: "\(progress.longestStreak)")
                row("Verses Read Today", value: "\(progress.versesReadToday)")
                row("Daily Goal", value: "\(progress.dailyGoalVerses)")
            }
        }
        .navigationTitle("Reading Debug")
    }

    private func row(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }

    private func formattedDate(_ date: Date?) -> String {
        guard let date else { return "nil" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
