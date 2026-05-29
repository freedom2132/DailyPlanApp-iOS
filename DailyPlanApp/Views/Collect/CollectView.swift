import SwiftUI
import SwiftData
import UIKit

struct CollectView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<TaskItem> { !$0.isDeleted && $0.category == "COLLECT" },
           sort: \TaskItem.createdAt, order: .reverse)
    private var collectTasks: [TaskItem]

    @State private var showAddSheet = false
    @State private var showImportSheet = false
    @State private var importText = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Description
                    VStack(spacing: 8) {
                        Image(systemName: "tray.and.arrow.down.fill")
                            .font(.largeTitle)
                            .foregroundColor(Color("Primary"))
                        Text("收集箱 - 快速记录想法")
                            .font(.headline)
                            .foregroundColor(Color("TextPrimary"))
                        Text("粘贴文字、导入微信聊天，稍后整理")
                            .font(.caption)
                            .foregroundColor(Color("TextSecondary"))
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color("Surface"))
                    .cornerRadius(10)

                    // Quick actions
                    HStack(spacing: 12) {
                        quickActionButton(icon: "doc.on.clipboard", title: "粘贴剪贴板") {
                            pasteFromClipboard()
                        }
                        quickActionButton(icon: "message.fill", title: "微信导入") {
                            showImportSheet = true
                        }
                    }

                    // Task list
                    if collectTasks.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "tray")
                                .font(.system(size: 48))
                                .foregroundColor(Color("TextHint"))
                            Text("收集箱是空的")
                                .foregroundColor(Color("TextHint"))
                        }
                        .padding(.top, 40)
                    } else {
                        ForEach(collectTasks) { task in
                            TaskRowView(task: task, onComplete: { completeTask(task) }, onDelete: { deleteTask(task) })
                        }
                    }
                }
                .padding()
            }
            .background(Color("BackgroundPrimary"))
            .navigationTitle("收集箱")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showAddSheet = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddTaskSheet()
            }
            .alert("微信导入", isPresented: $showImportSheet) {
                TextField("粘贴微信聊天内容", text: $importText, axis: .vertical)
                    .lineLimit(5...10)
                Button("导入") { importFromWechat() }
                Button("取消", role: .cancel) { importText = "" }
            }
        }
    }

    private func quickActionButton(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.caption)
            }
            .foregroundColor(Color("Primary"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color("Surface"))
            .cornerRadius(10)
        }
    }

    private func pasteFromClipboard() {
        #if canImport(UIKit)
        if let text = UIPasteboard.general.string, !text.isEmpty {
            let task = TaskItem(title: text, source: "CLIPBOARD", category: .collect)
            modelContext.insert(task)
        }
        #endif
    }

    private func importFromWechat() {
        let lines = importText.components(separatedBy: .newlines)
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.count > 2 && !trimmed.hasSuffix(":") && !trimmed.hasSuffix("：") {
                let task = TaskItem(title: trimmed, source: "WECHAT", category: .collect)
                modelContext.insert(task)
            }
        }
        importText = ""
    }

    private func completeTask(_ task: TaskItem) {
        withAnimation {
            task.status = TaskStatus.completed.rawValue
            task.completedAt = Date()
        }
    }

    private func deleteTask(_ task: TaskItem) {
        withAnimation { task.isDeleted = true }
    }
}
