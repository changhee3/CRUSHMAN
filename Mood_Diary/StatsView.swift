import SwiftUI
import SwiftData

struct StatsView: View {
    @Query private var entries: [MoodEntry]
    private let cal = Calendar.current

    private let emojis = ["😀", "🙂", "😐", "😞", "😢", "😡", "😴", "🥰"]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("통계")
                    .font(.title.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                HStack(spacing: 16) {
                    statCard(title: "연속 기록", value: "\(currentStreak())일", emoji: "🔥")
                    statCard(title: "총 기록", value: "\(entries.count)개", emoji: "📝")
                }
                .padding(.horizontal)

                if let top = topMood() {
                    statCard(title: "가장 많은 기분", value: "\(top.emoji) ×\(top.count)", emoji: "")
                        .padding(.horizontal)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("이번 달 기분 분포")
                        .font(.headline)
                    ForEach(emojis, id: \.self) { emoji in
                        let count = monthCount(for: emoji)
                        if count > 0 {
                            HStack {
                                Text(emoji).font(.title3)
                                GeometryReader { geo in
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.accentColor.opacity(0.7))
                                        .frame(width: barWidth(count: count, max: geo.size.width))
                                }
                                .frame(height: 20)
                                Text("\(count)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .frame(width: 30, alignment: .trailing)
                            }
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
            }
            .padding(.top, 30)
        }
    }

    private func statCard(title: String, value: String, emoji: String) -> some View {
        VStack(spacing: 6) {
            if !emoji.isEmpty { Text(emoji).font(.largeTitle) }
            Text(value).font(.title2.bold())
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // 오늘부터 거꾸로 연속 기록된 일수
    private func currentStreak() -> Int {
        var streak = 0
        var day = cal.startOfDay(for: Date())
        let keys = Set(entries.map { $0.dayKey })
        while keys.contains(MoodEntry.key(for: day)) {
            streak += 1
            guard let prev = cal.date(byAdding: .day, value: -1, to: day) else { break }
            day = prev
        }
        return streak
    }

    private func topMood() -> (emoji: String, count: Int)? {
        let counts = Dictionary(grouping: entries, by: { $0.emoji }).mapValues { $0.count }
        guard let top = counts.max(by: { $0.value < $1.value }) else { return nil }
        return (top.key, top.value)
    }

    private func monthCount(for emoji: String) -> Int {
        let now = Date()
        return entries.filter {
            $0.emoji == emoji &&
            cal.isDate($0.date, equalTo: now, toGranularity: .month)
        }.count
    }

    private func barWidth(count: Int, max: CGFloat) -> CGFloat {
        let maxCount = emojis.map { monthCount(for: $0) }.max() ?? 1
        guard maxCount > 0 else { return 0 }
        return max * CGFloat(count) / CGFloat(maxCount)
    }
}
