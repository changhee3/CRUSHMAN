import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        // AppDelegate가 소유한 공유 컨테이너의 mainContext를 화면 계층으로 전달한다.
        let context = (UIApplication.shared.delegate as! AppDelegate)
            .modelContainer.mainContext

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = RootTabBarController(context: context)
        window.makeKeyAndVisible()
        self.window = window
    }
}
