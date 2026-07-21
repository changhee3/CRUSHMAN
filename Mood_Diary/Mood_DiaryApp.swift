import SwiftUI
import SwiftData

@main
struct MoodDiaryApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: MoodEntry.self)
    }
}
