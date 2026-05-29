import Foundation
import SwiftData

enum TaskPriority: String, Codable, CaseIterable {
    case high = "HIGH"
    case medium = "MEDIUM"
    case low = "LOW"

    var label: String {
        switch self {
        case .high: return "高"
        case .medium: return "中"
        case .low: return "低"
        }
    }

    var color: String {
        switch self {
        case .high: return "priorityHigh"
        case .medium: return "priorityMedium"
        case .low: return "priorityLow"
        }
    }
}

enum TaskStatus: String, Codable {
    case pending = "PENDING"
    case completed = "COMPLETED"
    case overdue = "OVERDUE"
}

enum TaskCategory: String, Codable, CaseIterable {
    case todayKey = "TODAY_KEY"
    case todo = "TODO"
    case completed = "COMPLETED"
    case upcomingDdl = "UPCOMING_DDL"
    case collect = "COLLECT"

    var label: String {
        switch self {
        case .todayKey: return "今日关键"
        case .todo: return "待办"
        case .completed: return "已完成"
        case .upcomingDdl: return "即将到期"
        case .collect: return "收集箱"
        }
    }
}

@Model
final class TaskItem {
    var id: UUID
    var title: String
    var taskDescription: String
    var priority: String
    var deadline: Date?
    var isPostponable: Bool
    var source: String
    var status: String
    var category: String
    var estimatedMinutes: Int
    var tags: String
    var createdAt: Date
    var completedAt: Date?
    var isDeleted: Bool
    var sortOrder: Int

    init(
        title: String,
        description: String = "",
        priority: TaskPriority = .medium,
        deadline: Date? = nil,
        isPostponable: Bool = false,
        source: String = "MANUAL",
        category: TaskCategory = .todo
    ) {
        self.id = UUID()
        self.title = title
        self.taskDescription = description
        self.priority = priority.rawValue
        self.deadline = deadline
        self.isPostponable = isPostponable
        self.source = source
        self.status = TaskStatus.pending.rawValue
        self.category = category.rawValue
        self.estimatedMinutes = 0
        self.tags = ""
        self.createdAt = Date()
        self.completedAt = nil
        self.isDeleted = false
        self.sortOrder = 0
    }

    var priorityEnum: TaskPriority {
        TaskPriority(rawValue: priority) ?? .medium
    }

    var statusEnum: TaskStatus {
        TaskStatus(rawValue: status) ?? .pending
    }

    var categoryEnum: TaskCategory {
        TaskCategory(rawValue: category) ?? .todo
    }

    var isOverdue: Bool {
        guard let deadline = deadline else { return false }
        return deadline < Date() && statusEnum == .pending
    }

    var deadlineDisplay: String {
        guard let deadline = deadline else { return "" }
        let formatter = DateFormatter()
        let calendar = Calendar.current
        if calendar.isDateInToday(deadline) {
            formatter.dateFormat = "HH:mm"
            return "今天 \(formatter.string(from: deadline))"
        } else if calendar.isDateInTomorrow(deadline) {
            formatter.dateFormat = "HH:mm"
            return "明天 \(formatter.string(from: deadline))"
        } else {
            formatter.dateFormat = "M/d HH:mm"
            return formatter.string(from: deadline)
        }
    }
}
