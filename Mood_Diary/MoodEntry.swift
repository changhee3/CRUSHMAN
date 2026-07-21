import SwiftData
import Foundation

@Model
final class MoodEntry {
    // yyyy-MM-dd 문자열을 키로 사용 (하루 하나 보장)
    @Attribute(.unique) var dayKey: String
    var date: Date
    var emoji: String
    var note: String

    init(date: Date, emoji: String, note: String) {
        self.date = date
        self.emoji = emoji
        self.note = note
        self.dayKey = MoodEntry.key(for: date)
    }

    static func key(for date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }
}

