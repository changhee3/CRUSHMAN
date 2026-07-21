import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Label("오늘", systemImage: "square.and.pencil")
                }
            CalendarView()
                .tabItem {
                    Label("달력", systemImage: "calendar")
                }
        }
    }
}
