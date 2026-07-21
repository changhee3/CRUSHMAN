import SwiftData
import Foundation

@Model
final class MoodEntry {
    @Attribute(.unique) var dayKey: String
    var date: Date
    var emoji: String
    var note: String
    @Attribute(.externalStorage) var photoData: Data?   // ← 추가 (사진은 외부 저장)

    init(date: Date, emoji: String, note: String, photoData: Data? = nil) {
        self.date = date
        self.emoji = emoji
        self.note = note
        self.photoData = photoData
        self.dayKey = MoodEntry.key(for: date)
    }

    static func key(for date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    // 이모지 → 점수 (통계/히트맵용)
    var score: Int {
        switch emoji {
        case "😀", "🥰": return 5
        case "🙂":       return 4
        case "😐", "😴": return 3
        case "😞":       return 2
        case "😢", "😡": return 1
        default:         return 3
        }
    }
}
