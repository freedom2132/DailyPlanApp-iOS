import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Label("今日", systemImage: "sun.max.fill")
                }

            CollectView()
                .tabItem {
                    Label("收集箱", systemImage: "tray.and.arrow.down.fill")
                }

            ArchiveView()
                .tabItem {
                    Label("归档", systemImage: "chart.bar.fill")
                }

            HabitsView()
                .tabItem {
                    Label("习惯", systemImage: "checkmark.circle.fill")
                }

            ProfileView()
                .tabItem {
                    Label("我的", systemImage: "person.fill")
                }
        }
        .tint(Color("Primary"))
    }
}
