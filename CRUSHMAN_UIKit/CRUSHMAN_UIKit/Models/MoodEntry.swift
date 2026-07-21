import Foundation
import SwiftData

/// 하루 한 건의 기분 기록.
/// `day`는 항상 자정으로 정규화해서 저장하므로 "그날의 기록"을 == 로 조회할 수 있다.
@Model
final class MoodEntry {
    var emoji: String
    var note: String
    var day: Date
    var updatedAt: Date

    init(emoji: String, note: String = "", day: Date = .now) {
        self.emoji = emoji
        self.note = note
        self.day = Calendar.current.startOfDay(for: day)
        self.updatedAt = .now
    }
}
