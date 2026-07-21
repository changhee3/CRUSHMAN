import SwiftUI
import SwiftData

struct CalendarView: View {
    @Query private var entries: [MoodEntry]
    @State private var monthOffset = 0          // 0 = 이번 달, -1 = 지난 달
    @State private var selectedEntry: MoodEntry?

    private let cal = Calendar.current
    private let weekdays = ["일", "월", "화", "수", "목", "금", "토"]

    // 현재 보고 있는 달의 기준 날짜
    private var displayedMonth: Date {
        cal.date(byAdding: .month, value: monthOffset, to: Date()) ?? Date()
    }

    var body: some View {
        VStack(spacing: 16) {
            monthHeader

            // 요일 헤더
            HStack {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // 날짜 그리드
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                ForEach(daysInMonth(), id: \.self) { day in
                    if let day {
                        dayCell(for: day)
                    } else {
                        Color.clear.frame(height: 44)   // 달 시작 전 빈칸
                    }
                }
            }
            .padding(.horizontal, 8)

            Spacer()
        }
        .padding(.top, 20)
        .sheet(item: $selectedEntry) { entry in
            entryDetail(entry)
        }
    }

    // MARK: - 월 이동 헤더
    private var monthHeader: some View {
        HStack {
            Button { monthOffset -= 1 } label: {
                Image(systemName: "chevron.left")
            }
            Spacer()
            Text(monthTitle(displayedMonth))
                .font(.title2.bold())
            Spacer()
            Button { monthOffset += 1 } label: {
                Image(systemName: "chevron.right")
            }
            .disabled(monthOffset >= 0)   // 미래 달로는 못 넘어가게
        }
        .padding(.horizontal, 24)
    }

    // MARK: - 날짜 한 칸
    private func dayCell(for day: Date) -> some View {
        let key = MoodEntry.key(for: day)
        let entry = entries.first { $0.dayKey == key }

        return VStack(spacing: 2) {
            if let entry {
                Text(entry.emoji).font(.system(size: 24))
            } else {
                Text("\(cal.component(.day, from: day))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 44)
        .contentShape(Rectangle())
        .onTapGesture {
            if let entry { selectedEntry = entry }
        }
    }

    // MARK: - 날짜 상세 시트
    private func entryDetail(_ entry: MoodEntry) -> some View {
        VStack(spacing: 20) {
            Text(entry.emoji).font(.system(size: 80))
            Text(fullDate(entry.date)).font(.headline)
            Text(entry.note.isEmpty ? "메모 없음" : entry.note)
                .foregroundStyle(entry.note.isEmpty ? .secondary : .primary)
            Spacer()
        }
        .padding(.top, 40)
        .presentationDetents([.medium])
    }

    // MARK: - 달력 계산
    private func daysInMonth() -> [Date?] {
        guard
            let monthInterval = cal.dateInterval(of: .month, for: displayedMonth),
            let firstWeekday = cal.dateComponents([.weekday], from: monthInterval.start).weekday
        else { return [] }

        let daysCount = cal.range(of: .day, in: .month, for: displayedMonth)?.count ?? 0
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)  // 앞쪽 빈칸

        for offset in 0..<daysCount {
            if let date = cal.date(byAdding: .day, value: offset, to: monthInterval.start) {
                days.append(date)
            }
        }
        return days
    }

    private func monthTitle(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy년 M월"
        return f.string(from: date)
    }

    private func fullDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "M월 d일 EEEE"
        return f.string(from: date)
    }
}
