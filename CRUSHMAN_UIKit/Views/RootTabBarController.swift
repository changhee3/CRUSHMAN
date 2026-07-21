import UIKit
import SwiftData

/// 탭 2개(오늘 / 기록). SwiftUI의 `RootView`가 하던 일을 UITabBarController로 옮긴 것.
final class RootTabBarController: UITabBarController {

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()

        let today = UINavigationController(rootViewController: TodayViewController(context: context))
        today.tabBarItem = UITabBarItem(
            title: "오늘",
            image: UIImage(systemName: "sun.max"),
            selectedImage: UIImage(systemName: "sun.max.fill")
        )

        let history = UINavigationController(rootViewController: HistoryViewController(context: context))
        history.tabBarItem = UITabBarItem(
            title: "기록",
            image: UIImage(systemName: "calendar"),
            selectedImage: UIImage(systemName: "calendar")
        )

        viewControllers = [today, history]
    }
}
