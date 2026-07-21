import UIKit
import SwiftData

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    /// 앱 전역에서 공유하는 SwiftData 컨테이너.
    /// SwiftUI의 `.modelContainer(for:)`를 UIKit에서 직접 만든 것과 같다.
    let modelContainer: ModelContainer = {
        do {
            return try ModelContainer(for: MoodEntry.self)
        } catch {
            fatalError("ModelContainer 생성 실패: \(error)")
        }
    }()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        true
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: "Default", sessionRole: connectingSceneSession.role)
        config.delegateClass = SceneDelegate.self
        return config
    }
}
