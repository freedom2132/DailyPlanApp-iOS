import Foundation
import SwiftData

@Model
final class DailyArchive {
    var id: UUID
    var date: Date
    var totalTasks: Int
    var completedTasks: Int
    var completionRate: Double
    var noteToTomorrow: String
    var createdAt: Date

    init(date: Date = Date(), totalTasks: Int = 0, completedTasks: Int = 0, noteToTomorrow: String = "") {
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: date)
        self.totalTasks = totalTasks
        self.completedTasks = completedTasks
        self.completionRate = totalTasks > 0 ? Double(completedTasks) / Double(totalTasks) : 0
        self.noteToTomorrow = noteToTomorrow
        self.createdAt = Date()
    }
}
