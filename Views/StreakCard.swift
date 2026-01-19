import SwiftUI

struct StreakCard: View {
    @ObservedObject private var progress = ReadingProgressService.shared
    @State private var animateFlame = false

    private var streakLabel: String {
        let d = progress.currentStreak
        return d == 1 ? "1 day" : "\(d) days"
    }

    private var bestLabel: String {
        let d = progress.longestStreak
        return d == 1 ? "1 day" : "\(d) days"
    }

    private var didReadToday: Bool {
        progress.versesReadToday > 0
    }

    private var todayStatusText: String {
        didReadToday ? "Done ✅" : "Not yet"
    }

    private var clampedVersesRead: Int {
        min(progress.versesReadToday, max(progress.dailyGoalVerses, 1))
    }

    private var goalProgress: Double {
        Double(clampedVersesRead) / Double(max(progress.dailyGoalVerses, 1))
    }

    private var shouldShowGracePassNote: Bool {
        progress.currentStreak > 0 && progress.gracePassesRemaining == 1
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .font(.headline)
                        .foregroundStyle(.orange)
                        .scaleEffect(animateFlame ? 1.2 : 1.0)
                    Text("Reading Streak")
                        .font(.headline)
                }
                Spacer()
                Text(streakLabel)
                    .font(.title3)
                    .fontWeight(.bold)
            }

            // Show goal progress only while Today isn't completed.
            if progress.dailyGoalVerses > 0 && !didReadToday {
                ProgressView(value: goalProgress)
                    .tint(.orange)
            }

            HStack {
                Text("Today: \(todayStatusText)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()

                Text("Best: \(bestLabel)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Optional: keep the goal detail, but avoid showing over-goal counts.
            if progress.dailyGoalVerses > 0 {
                if didReadToday && goalProgress >= 1.0 {
                    Text("Goal hit ✅")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Goal: \(clampedVersesRead)/\(progress.dailyGoalVerses) verses")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            if shouldShowGracePassNote {
                Text("Grace pass available this month")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .homeCard()
        .onChange(of: progress.currentStreak) { oldValue, newValue in
            guard newValue > oldValue else { return }
            withAnimation(.easeOut(duration: 0.3)) {
                animateFlame = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.easeIn(duration: 0.2)) {
                    animateFlame = false
                }
            }
        }
    }
}
