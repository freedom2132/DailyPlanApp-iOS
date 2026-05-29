import SwiftUI
import SwiftData

@main
struct DailyPlanApp: App {
    @AppStorage("darkMode") private var darkMode = false

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TaskItem.self,
            Habit.self,
            HabitRecord.self,
            DailyArchive.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(darkMode ? .dark : .light)
        }
        .modelContainer(sharedModelContainer)
    }
}
