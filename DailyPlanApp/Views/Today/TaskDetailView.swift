import SwiftUI

struct TaskDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var task: TaskItem

    @State private var title: String = ""
    @State private var description: String = ""
    @State private var priority: TaskPriority = .medium
    @State private var category: TaskCategory = .todo
    @State private var hasDeadline = false
    @State private var deadline = Date()

    @State private var showDeleteConfirm = false

    var body: some View {
        Form {
            Section("任务信息") {
                TextField("标题", text: $title)
                TextField("描述", text: $description, axis: .vertical)
                    .lineLimit(3...6)
            }

            Section("设置") {
                Picker("优先级", selection: $priority) {
                    ForEach(TaskPriority.allCases, id: \.self) { Text($0.label).tag($0) }
                }
                Picker("分类", selection: $category) {
                    ForEach(TaskCategory.allCases, id: \.self) { Text($0.label).tag($0) }
                }
                Toggle("截止时间", isOn: $hasDeadline)
                if hasDeadline {
                    DatePicker("截止", selection: $deadline)
                }
            }

            Section {
                HStack {
                    Text("状态")
                    Spacer()
                    Text(task.statusEnum == .completed ? "已完成" : task.isOverdue ? "已逾期" : "进行中")
                        .foregroundColor(task.statusEnum == .completed ? Color("Success") : task.isOverdue ? Color("DdlOverdue") : Color("TextSecondary"))
                }
                HStack {
                    Text("创建时间")
                    Spacer()
                    Text(task.createdAt, style: .date)
                        .foregroundColor(Color("TextSecondary"))
                }
            }

            Section {
                if task.statusEnum != .completed {
                    Button("完成任务") {
                        task.status = TaskStatus.completed.rawValue
                        task.completedAt = Date()
                        dismiss()
                    }
                    .foregroundColor(Color("Success"))
                    .frame(maxWidth: .infinity)
                }

                Button("删除任务", role: .destructive) {
                    showDeleteConfirm = true
                }
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("任务详情")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            title = task.title
            description = task.taskDescription
            priority = task.priorityEnum
            category = task.categoryEnum
            hasDeadline = task.deadline != nil
            deadline = task.deadline ?? Date()
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("保存") { save() }
            }
        }
        .confirmationDialog("确认删除？", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("删除", role: .destructive) {
                task.isDeleted = true
                dismiss()
            }
        }
    }

    private func save() {
        task.title = title
        task.taskDescription = description
        task.priority = priority.rawValue
        task.category = category.rawValue
        task.deadline = hasDeadline ? deadline : nil
        dismiss()
    }
}
