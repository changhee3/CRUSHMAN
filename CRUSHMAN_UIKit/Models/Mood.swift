import Foundation

/// 기록에 사용할 고정 이모지 프리셋.
/// 선택지를 8개로 제한해 "탭 한 번으로 끝"이라는 목표를 지킨다.
enum Mood: String, CaseIterable, Identifiable {
    case great = "😄"
    case good  = "🙂"
    case calm  = "😌"
    case meh   = "😐"
    case tired = "😪"
    case sad   = "😢"
    case angry = "😤"
    case love  = "🥰"

    var id: String { rawValue }
    var emoji: String { rawValue }

    var label: String {
        switch self {
        case .great: "최고"
        case .good:  "좋음"
        case .calm:  "평온"
        case .meh:   "그냥"
        case .tired: "지침"
        case .sad:   "슬픔"
        case .angry: "화남"
        case .love:  "설렘"
        }
    }
}
