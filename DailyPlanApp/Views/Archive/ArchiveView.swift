import SwiftUI
import SwiftData
import Charts

struct ArchiveView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<TaskItem> { !$0.isDeleted }, sort: \TaskItem.createdAt, order: .reverse)
    private var allTasks: [TaskItem]

    @Query(sort: \DailyArchive.date, order: .reverse)
    private var archives: [DailyArchive]

    @State private var showArchiveConfirm = false
    @State private var noteText = ""
    @State private var showNoteSheet = false

    private var todayCompleted: Int {
        allTasks.filter { $0.statusEnum == .completed && Calendar.current.isDateInToday($0.completedAt ?? .distantPast) }.count
    }

    private var todayPending: Int {
        allTasks.filter { $0.statusEnum == .pending }.count
    }

    private var completionRate: Double {
        let total = todayCompleted + todayPending
        guard total > 0 else { return 0 }
        return Double(todayCompleted) / Double(total)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Today stats card
                    todayStatsCard

                    // 7-day chart
                    weeklyChartCard

                    // Category distribution
                    categoryPieCard

                    // Actions
                    VStack(spacing: 12) {
                        actionButton(title: "给明天的我留言", icon: "pencil.line") {
                            showNoteSheet = true
                        }
                        actionButton(title: "手动归档今日", icon: "archivebox") {
                            showArchiveConfirm = true
                        }
                    }
                }
                .padding()
            }
            .background(Color("BackgroundPrimary"))
            .navigationTitle("归档")
            .confirmationDialog("确认归档？", isPresented: $showArchiveConfirm) {
                Button("归档") { archiveToday() }
            }
            .alert("给明天的留言", isPresented: $showNoteSheet) {
                TextField("写点什么...", text: $noteText)
                Button("保存") { saveNote() }
                Button("取消", role: .cancel) {}
            }
        }
    }

    private var todayStatsCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text(todayDateString)
                    .font(.headline)
                    .foregroundColor(Color("TextPrimary"))
                Spacer()
                Text("\(Int(completionRate * 100))%")
                    .font(.title)
                    .bold()
                    .foregroundColor(Color("Primary"))
            }

            ProgressView(value: completionRate)
                .tint(Color("Primary"))

            HStack {
                statItem(value: "\(todayCompleted)", label: "已完成")
                Spacer()
                statItem(value: "\(todayPending)", label: "待处理")
                Spacer()
                statItem(value: "\(allTasks.count)", label: "总任务")
            }
        }
        .padding()
        .background(Color("Surface"))
        .cornerRadius(10)
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.title2).bold().foregroundColor(Color("Primary"))
            Text(label).font(.caption).foregroundColor(Color("TextSecondary"))
        }
    }

    private var todayDateString: String {
        let f = DateFormatter()
        f.dateFormat = "M月d日"
        f.locale = Locale(identifier: "zh_CN")
        return f.string(from: Date())
    }

    private var weeklyChartCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("近7天完成率")
                .font(.headline)
                .foregroundColor(Color("TextPrimary"))

            Chart(weekData, id: \.date) { item in
                BarMark(x: .value("日期", item.date, unit: .day), y: .value("完成率", item.rate))
                    .foregroundStyle(item.rate >= 0.8 ? Color("Success") : item.rate >= 0.5 ? Color("PriorityMedium") : Color("PriorityHigh"))
                    .cornerRadius(4)
            }
            .frame(height: 160)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisValueLabel(format: .dateTime.weekday(.narrow), centered: true)
                }
            }
            .chartYAxis { AxisMarks(position: .leading) }
        }
        .padding()
        .background(Color("Surface"))
        .cornerRadius(10)
    }

    private var weekData: [(date: Date, rate: Double)] {
        let calendar = Calendar.current
        return (0..<7).reversed().map { daysAgo in
            let date = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -daysAgo, to: Date())!)
            let dayTasks = allTasks.filter { $0.completedAt != nil && calendar.isDate($0.completedAt!, inSameDayAs: date) }
            let completed = dayTasks.count
            let total = completed + (allTasks.filter { $0.statusEnum == .pending && calendar.startOfDay(for: $0.createdAt) == date }.count)
            return (date: date, rate: total > 0 ? Double(completed) / Double(total) : 0)
        }
    }

    private var categoryPieCard: some View {
        let grouped = Dictionary(grouping: allTasks.filter { $0.statusEnum == .pending }, by: { $0.categoryEnum })

        return VStack(alignment: .leading, spacing: 8) {
            Text("任务分布")
                .font(.headline)
                .foregroundColor(Color("TextPrimary"))

            Chart(grouped.sorted(by: { $0.value.count > $1.value.count }), id: \.key) { category, tasks in
                SectorMark(angle: .value("数量", tasks.count))
                    .foregroundStyle(by: .value("分类", category.label))
            }
            .frame(height: 180)
            .chartLegend(position: .bottom, spacing: 8)
        }
        .padding()
        .background(Color("Surface"))
        .cornerRadius(10)
    }

    private func actionButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
                Spacer()
                Image(systemName: "chevron.right")
            }
            .foregroundColor(Color("TextPrimary"))
            .padding()
            .background(Color("Surface"))
            .cornerRadius(10)
        }
    }

    private func archiveToday() {
        let archive = DailyArchive(
            date: Date(),
            totalTasks: todayCompleted + todayPending,
            completedTasks: todayCompleted
        )
        modelContext.insert(archive)
    }

    private func saveNote() {
        let archive = DailyArchive(date: Date(), noteToTomorrow: noteText)
        modelContext.insert(archive)
        noteText = ""
    }
}
