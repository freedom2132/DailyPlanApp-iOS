import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<TaskItem> { !$0.isDeleted && $0.status == "PENDING" && $0.category == "TODAY_KEY" },
           sort: \TaskItem.createdAt, order: .reverse)
    private var todayKeyTasks: [TaskItem]

    @Query(filter: #Predicate<TaskItem> { !$0.isDeleted && $0.status == "PENDING" && $0.category == "TODO" },
           sort: \TaskItem.createdAt, order: .reverse)
    private var todoTasks: [TaskItem]

    @Query(filter: #Predicate<TaskItem> { !$0.isDeleted && $0.status == "COMPLETED" },
           sort: \TaskItem.completedAt, order: .reverse)
    private var completedTasks: [TaskItem]

    @State private var showAddTask = false
    @State private var isCompletedExpanded = false

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<6: return "夜深了"
        case 6..<12: return "上午好"
        case 12..<18: return "下午好"
        default: return "晚上好"
        }
    }

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日 EEEE"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: Date())
    }

    private var todayCompletedCount: Int {
        completedTasks.filter { Calendar.current.isDateInToday($0.completedAt ?? Date.distantPast) }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Header
                    headerSection

                    // Today Key
                    taskSection(title: "今日关键", tasks: todayKeyTasks, emptyText: "添加今日关键任务")

                    // DDL Radar
                    ddlRadarSection

                    // Todo
                    taskSection(title: "待办事项", tasks: todoTasks, emptyText: "暂无待办事项")

                    // Completed
                    completedSection
                }
                .padding()
            }
            .background(Color("BackgroundPrimary"))
            .navigationTitle("今日")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddTask = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(Color("Primary"))
                    }
                }
            }
            .sheet(isPresented: $showAddTask) {
                AddTaskSheet()
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(dateString)，\(greeting)")
                        .font(.headline)
                        .foregroundColor(Color("TextPrimary"))

                    Text("今天专注三件事")
                        .font(.caption)
                        .foregroundColor(Color("TextSecondary"))
                }
                Spacer()

                // Completion ring
                ZStack {
                    Circle()
                        .stroke(Color("ProgressBackground"), lineWidth: 4)
                    Circle()
                        .trim(from: 0, to: completionRate)
                        .stroke(Color("Primary"), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Text("\(Int(completionRate * 100))%")
                        .font(.caption2)
                        .bold()
                        .foregroundColor(Color("Primary"))
                }
                .frame(width: 48, height: 48)
            }
        }
        .padding()
        .background(Color("Surface"))
        .cornerRadius(10)
    }

    private var completionRate: CGFloat {
        let total = todayKeyTasks.count + todoTasks.count + todayCompletedCount
        guard total > 0 else { return 0 }
        return CGFloat(todayCompletedCount) / CGFloat(total)
    }

    private func taskSection(title: String, tasks: [TaskItem], emptyText: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(Color("Primary"))

            if tasks.isEmpty {
                Text(emptyText)
                    .font(.caption)
                    .foregroundColor(Color("TextHint"))
                    .frame(maxWidth: .infinity, minHeight: 56)
            } else {
                ForEach(tasks) { task in
                    NavigationLink(destination: TaskDetailView(task: task)) {
                        TaskRowView(task: task, onComplete: { completeTask(task) }, onDelete: { deleteTask(task) })
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var ddlRadarSection: some View {
        let now = Date()
        let threeDaysLater = Calendar.current.date(byAdding: .day, value: 3, to: now)!
        let weekLater = Calendar.current.date(byAdding: .day, value: 7, to: now)!

        let allPending = todayKeyTasks + todoTasks
        let todayDdl = allPending.filter { ($0.deadline ?? .distantFuture) < Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: now)!) }
        let todayDdlIds = Set(todayDdl.map(\.id))
        let threeDayDdl = allPending.filter { let d = $0.deadline ?? .distantFuture; return d >= now && d < threeDaysLater && !todayDdlIds.contains($0.id) }
        let weekDdl = allPending.filter { let d = $0.deadline ?? .distantFuture; return d >= threeDaysLater && d < weekLater }

        return VStack(alignment: .leading, spacing: 8) {
            Text("DDL 雷达")
                .font(.headline)
                .foregroundColor(Color("Primary"))

            HStack(spacing: 12) {
                DdlBadge(count: todayDdl.count, label: "今日", color: Color("DdlToday"))
                DdlBadge(count: threeDayDdl.count, label: "3天内", color: Color("Ddl3Day"))
                DdlBadge(count: weekDdl.count, label: "7天内", color: Color("DdlWeek"))
            }
        }
    }

    private var completedSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("已完成 (\(todayCompletedCount))")
                    .font(.headline)
                    .foregroundColor(Color("Success"))
                Spacer()
                Image(systemName: isCompletedExpanded ? "chevron.up" : "chevron.down")
                    .foregroundColor(Color("TextHint"))
                    .font(.caption)
            }
            .onTapGesture { withAnimation(.easeInOut(duration: 0.2)) { isCompletedExpanded.toggle() } }

            if isCompletedExpanded {
                let todayCompleted = completedTasks.filter { Calendar.current.isDateInToday($0.completedAt ?? Date.distantPast) }
                if todayCompleted.isEmpty {
                    Text("还没有完成的任务")
                        .font(.caption)
                        .foregroundColor(Color("TextHint"))
                        .frame(maxWidth: .infinity, minHeight: 56)
                } else {
                    ForEach(todayCompleted) { task in
                        TaskRowView(task: task, onComplete: {}, onDelete: { deleteTask(task) })
                    }
                }
            }
        }
    }

    private func completeTask(_ task: TaskItem) {
        withAnimation {
            task.status = TaskStatus.completed.rawValue
            task.completedAt = Date()
        }
    }

    private func deleteTask(_ task: TaskItem) {
        withAnimation {
            task.isDeleted = true
        }
    }
}

struct DdlBadge: View {
    let count: Int
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.title2)
                .bold()
                .foregroundColor(count > 0 ? color : Color("TextHint"))
            Text(label)
                .font(.caption2)
                .foregroundColor(Color("TextSecondary"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color("Surface"))
        .cornerRadius(10)
    }
}
