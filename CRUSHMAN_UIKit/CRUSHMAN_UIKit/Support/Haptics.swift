import UIKit

enum Haptics {
    /// 이모지를 탭했을 때의 가벼운 피드백.
    static func select() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }

    /// 기록이 저장됐을 때의 완료 피드백.
    static func saved() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
