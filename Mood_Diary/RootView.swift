import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            TodayView()
                .tabItem { Label("오늘", systemImage: "square.and.pencil") }

            CalendarView()
                .tabItem { Label("달력", systemImage: "calendar") }

            HeatmapView()
                .tabItem { Label("히트맵", systemImage: "square.grid.3x3.fill") }

            StatsView()
                .tabItem { Label("통계", systemImage: "chart.bar.fill") }
        }
    }
}
