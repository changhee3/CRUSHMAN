import SwiftUI
import SwiftData

struct HeatmapView: View {
    @Query(sort: \MoodEntry.date) private var entries: [MoodEntry]
    private let cal = Calendar.current

    private let weeksToShow = 17   // 최근 약 4개월

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("무드 히트맵")
                    .font(.title.bold())
                    .padding(.horizontal)

                Text("최근 \(weeksToShow)주 · 좋을수록 초록, 나쁠수록 빨강")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 4) {
                        ForEach(weeks(), id: \.self) { week in
                            VStack(spacing: 4) {
                                ForEach(week, id: \.self) { day in
                                    cell(for: day)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                legend
                    .padding(.horizontal)
                    .padding(.top, 8)
            }
            .padding(.top, 30)
        }
    }

    private func cell(for day: Date?) -> some View {
        let color: Color
        if let day, let entry = entry(for: day) {
            color = heatColor(for: entry.score)
        } else {
            color = Color.gray.opacity(0.12)   // 기록 없음
        }
        return RoundedRectangle(cornerRadius: 3)
            .fill(color)
            .frame(width: 20, height: 20)
    }

    private var legend: some View {
        HStack(spacing: 6) {
            Text("나쁨").font(.caption2).foregroundStyle(.secondary)
            ForEach(1...5, id: \.self) { score in
                RoundedRectangle(cornerRadius: 3)
                    .fill(heatColor(for: score))
                    .frame(width: 16, height: 16)
            }
            Text("좋음").font(.caption2).foregroundStyle(.secondary)
        }
    }

    private func heatColor(for score: Int) -> Color {
        switch score {
        case 5: return Color.green.opacity(0.9)
        case 4: return Color.green.opacity(0.6)
        case 3: return Color.yellow.opacity(0.6)
        case 2: return Color.orange.opacity(0.6)
        case 1: return Color.red.opacity(0.7)
        default: return Color.gray.opacity(0.12)
        }
    }

    private func entry(for day: Date) -> MoodEntry? {
        let key = MoodEntry.key(for: day)
        return entries.first { $0.dayKey == key }
    }

    private func weeks() -> [[Date?]] {
        let today = cal.startOfDay(for: Date())
        guard let thisWeekStart = cal.dateInterval(of: .weekOfYear, for: today)?.start
        else { return [] }

        var result: [[Date?]] = []
        for w in stride(from: weeksToShow - 1, through: 0, by: -1) {
            guard let weekStart = cal.date(byAdding: .weekOfYear, value: -w, to: thisWeekStart)
            else { continue }
            var week: [Date?] = []
            for d in 0..<7 {
                if let day = cal.date(byAdding: .day, value: d, to: weekStart) {
                    week.append(day > today ? nil : day)   // 미래는 빈칸
                }
            }
            result.append(week)
        }
        return result
    }
}
