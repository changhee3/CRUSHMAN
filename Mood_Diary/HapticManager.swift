import UIKit

enum HapticManager {

    /// 이모지 감정에 맞는 햅틱을 재생한다.
    static func play(for emoji: String) {
        switch emoji {

        case "😀":  // 활짝 웃음 → 경쾌한 성공 진동
            UINotificationFeedbackGenerator().notificationOccurred(.success)

        case "🥰":  // 사랑스러움 → 부드럽게 두 번 톡톡 (두근거림)
            softDoubleTap()

        case "🙂":  // 잔잔한 미소 → 가벼운 톡
            UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.7)

        case "😐":  // 무덤덤 → 딱딱하고 짧게 (건조한 느낌)
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.6)

        case "😴":  // 졸림 → 아주 부드럽고 약하게
            UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.4)

        case "😞":  // 실망 → 묵직하게 한 번
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred(intensity: 0.7)

        case "😢":  // 슬픔 → 무겁고 느리게 두 번 (가라앉는 느낌)
            heavySlowDouble()

        case "😡":  // 화남 → 강하고 딱딱하게 세 번 (두두두)
            angryTriple()
            angryTriple()

        default:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }

    // MARK: - 커스텀 패턴 (여러 번 진동)

    // 🥰 부드럽게 톡톡 (0.1초 간격 2회)
    private static func softDoubleTap() {
        let gen = UIImpactFeedbackGenerator(style: .soft)
        gen.impactOccurred(intensity: 0.6)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            gen.impactOccurred(intensity: 0.9)
        }
    }

    // 😢 무겁고 느리게 2회 (가라앉는 느낌)
    private static func heavySlowDouble() {
        let gen = UIImpactFeedbackGenerator(style: .heavy)
        gen.impactOccurred(intensity: 0.6)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            gen.impactOccurred(intensity: 0.5)
        }
    }

    // 😡 강하게 3연타 (두두두)
    private static func angryTriple() {
        let gen = UIImpactFeedbackGenerator(style: .rigid)
        gen.impactOccurred(intensity: 1.0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            gen.impactOccurred(intensity: 1.0)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
            gen.impactOccurred(intensity: 1.0)
        }
    }
}

