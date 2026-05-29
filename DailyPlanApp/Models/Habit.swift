import Foundation
import SwiftData

@Model
final class Habit {
    var id: UUID
    var name: String
    var icon: String
    var dailyTarget: Int
    var currentStreak: Int
    var maxStreak: Int
    var totalCount: Int
    var isActive: Bool
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \HabitRecord.habit)
    var records: [HabitRecord]?

    init(name: String, icon: String = "⭐", dailyTarget: Int = 1) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.dailyTarget = dailyTarget
        self.currentStreak = 0
        self.maxStreak = 0
        self.totalCount = 0
        self.isActive = true
        self.createdAt = Date()
    }

    func todayRecord(context: ModelContext) -> HabitRecord? {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let habitId = self.id
        let descriptor = FetchDescriptor<HabitRecord>(
            predicate: #Predicate { record in
                record.habitId == habitId && record.date >= today && record.date < tomorrow
            }
        )
        return try? context.fetch(descriptor).first
    }

    var todayCount: Int {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        return records?.filter { $0.date >= today && $0.date < tomorrow }.first?.count ?? 0
    }

    var isCompletedToday: Bool {
        todayCount >= dailyTarget
    }
}

@Model
final class HabitRecord {
    var id: UUID
    var habitId: UUID
    var date: Date
    var count: Int
    var target: Int
    var isCompleted: Bool
    var createdAt: Date

    @Relationship var habit: Habit?

    init(habitId: UUID, date: Date, count: Int = 1, target: Int = 1) {
        self.id = UUID()
        self.habitId = habitId
        self.date = Calendar.current.startOfDay(for: date)
        self.count = count
        self.target = target
        self.isCompleted = count >= target
        self.createdAt = Date()
    }
}
