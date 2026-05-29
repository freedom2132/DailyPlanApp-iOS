import SwiftUI

struct TaskRowView: View {
    let task: TaskItem
    let onComplete: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Priority bar
            RoundedRectangle(cornerRadius: 2)
                .fill(priorityColor)
                .frame(width: 3, height: 40)

            // Checkbox
            Button(action: onComplete) {
                Image(systemName: task.statusEnum == .completed ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(task.statusEnum == .completed ? Color("Success") : Color("TextHint"))
            }
            .buttonStyle(.plain)

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.body)
                    .foregroundColor(Color("TextPrimary"))
                    .strikethrough(task.statusEnum == .completed)

                HStack(spacing: 8) {
                    if !task.deadlineDisplay.isEmpty {
                        Label(task.deadlineDisplay, systemImage: "clock")
                            .font(.caption)
                            .foregroundColor(task.isOverdue ? Color("DdlOverdue") : Color("TextSecondary"))
                    }

                    Text(task.categoryEnum.label)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color("Primary").opacity(0.1))
                        .foregroundColor(Color("Primary"))
                        .cornerRadius(4)
                }
            }

            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color("Surface"))
        .cornerRadius(10)
        .contextMenu {
            if task.statusEnum != .completed {
                Button(action: onComplete) {
                    Label("完成", systemImage: "checkmark.circle")
                }
            }
            Button(role: .destructive, action: onDelete) {
                Label("删除", systemImage: "trash")
            }
        }
    }

    private var priorityColor: Color {
        switch task.priorityEnum {
        case .high: return Color("PriorityHigh")
        case .medium: return Color("PriorityMedium")
        case .low: return Color("PriorityLow")
        }
    }
}
