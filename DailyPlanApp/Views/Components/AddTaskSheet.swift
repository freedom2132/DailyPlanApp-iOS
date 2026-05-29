import SwiftUI
import SwiftData

struct AddTaskSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var priority: TaskPriority = .medium
    @State private var category: TaskCategory = .todo
    @State private var hasDeadline = false
    @State private var deadline = Date().addingTimeInterval(3600)

    var body: some View {
        NavigationStack {
            Form {
                Section("任务内容") {
                    TextField("输入任务标题", text: $title)
                }

                Section("优先级") {
                    Picker("优先级", selection: $priority) {
                        ForEach(TaskPriority.allCases, id: \.self) { p in
                            Text(p.label).tag(p)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("分类") {
                    Picker("分类", selection: $category) {
                        ForEach([TaskCategory.todayKey, .todo, .collect], id: \.self) { c in
                            Text(c.label).tag(c)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("截止时间") {
                    Toggle("设置截止时间", isOn: $hasDeadline)
                    if hasDeadline {
                        DatePicker("截止时间", selection: $deadline)
                            .datePickerStyle(.graphical)
                    }
                }
            }
            .navigationTitle("添加任务")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("添加") {
                        addTask()
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func addTask() {
        let task = TaskItem(
            title: title.trimmingCharacters(in: .whitespaces),
            priority: priority,
            deadline: hasDeadline ? deadline : nil,
            category: category
        )
        modelContext.insert(task)
    }
}
