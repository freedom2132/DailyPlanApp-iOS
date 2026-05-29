import SwiftUI
import SwiftData

struct HabitsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Habit> { $0.isActive }, sort: \Habit.createdAt, order: .reverse)
    private var habits: [Habit]

    @State private var showAddSheet = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Stats card
                    statsCard

                    // Section title
                    HStack {
                        Text("我的习惯")
                            .font(.headline)
                            .foregroundColor(Color("Primary"))
                        Spacer()
                    }

                    if habits.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 48))
                                .foregroundColor(Color("TextHint"))
                            Text("还没有习惯\n点击右下角添加")
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color("TextHint"))
                        }
                        .padding(.top, 60)
                    } else {
                        ForEach(habits) { habit in
                            HabitRowView(habit: habit)
                        }
                    }
                }
                .padding()
            }
            .background(Color("BackgroundPrimary"))
            .navigationTitle("习惯")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showAddSheet = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(Color("Primary"))
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddHabitSheet()
            }
        }
    }

    private var statsCard: some View {
        HStack {
            VStack {
                Text("\(habits.count)")
                    .font(.title)
                    .bold()
                    .foregroundColor(Color("Primary"))
                Text("活跃习惯")
                    .font(.caption)
                    .foregroundColor(Color("TextSecondary"))
            }
            .frame(maxWidth: .infinity)

            Divider().frame(height: 40)

            VStack {
                Text("\(completedTodayCount)")
                    .font(.title)
                    .bold()
                    .foregroundColor(Color("Primary"))
                Text("今日已完成")
                    .font(.caption)
                    .foregroundColor(Color("TextSecondary"))
            }
            .frame(maxWidth: .infinity)

            Divider().frame(height: 40)

            VStack {
                Text("\(maxStreak)")
                    .font(.title)
                    .bold()
                    .foregroundColor(Color("Primary"))
                Text("最长连续")
                    .font(.caption)
                    .foregroundColor(Color("TextSecondary"))
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(Color("Surface"))
        .cornerRadius(10)
    }

    private var completedTodayCount: Int {
        habits.filter { $0.isCompletedToday }.count
    }

    private var maxStreak: Int {
        habits.map(\.maxStreak).max() ?? 0
    }
}

struct HabitRowView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var habit: Habit

    var body: some View {
        HStack(spacing: 14) {
            // Icon
            Text(habit.icon)
                .font(.title)
                .frame(width: 48, height: 48)
                .background(Color("HabitIconBg"))
                .cornerRadius(24)

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.body)
                    .bold()
                    .foregroundColor(Color("TextPrimary"))
                Text("\(habit.todayCount)/\(habit.dailyTarget) · 连续\(habit.currentStreak)天")
                    .font(.caption)
                    .foregroundColor(Color("TextSecondary"))
            }

            Spacer()

            // Progress + button
            VStack(spacing: 6) {
                CircularProgressView(progress: min(Double(habit.todayCount) / Double(habit.dailyTarget), 1.0))
                    .frame(width: 36, height: 36)

                Button { incrementHabit() } label: {
                    Text("+1")
                        .font(.caption)
                        .bold()
                        .frame(width: 44, height: 28)
                        .background(Color("Primary"))
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
            }
        }
        .padding()
        .background(Color("Surface"))
        .cornerRadius(10)
    }

    private func incrementHabit() {
        withAnimation(.spring(response: 0.3)) {
            let wasCompleted = habit.isCompletedToday
            let today = Calendar.current.startOfDay(for: Date())
            if let record = habit.records?.filter({ Calendar.current.isDateInToday($0.date) }).first {
                record.count += 1
                record.isCompleted = record.count >= record.target
            } else {
                let record = HabitRecord(habitId: habit.id, date: today, count: 1, target: habit.dailyTarget)
                record.habit = habit
                modelContext.insert(record)
            }

            habit.totalCount += 1
            if !wasCompleted && habit.isCompletedToday {
                habit.currentStreak += 1
                habit.maxStreak = max(habit.maxStreak, habit.currentStreak)
            }
        }
    }
}

struct CircularProgressView: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color("ProgressBackground"), lineWidth: 3)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color("Primary"), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
            if progress >= 1.0 {
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color("Success"))
            }
        }
    }
}

struct AddHabitSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var selectedIcon = "⭐"
    @State private var dailyTarget = 1

    private let icons = ["⭐", "📖", "🏃", "✍️", "💧", "🧘", "📚", "🌅", "🌙", "💪", "🎯", "🧹", "🍎", "💊", "🎵"]

    var body: some View {
        NavigationStack {
            Form {
                Section("习惯名称") {
                    TextField("如：读书、运动、喝水", text: $name)
                        .onChange(of: name) { _, newValue in
                            selectedIcon = pickIcon(for: newValue)
                        }
                }

                Section("图标") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(icons, id: \.self) { icon in
                            Text(icon)
                                .font(.title)
                                .frame(width: 48, height: 48)
                                .background(selectedIcon == icon ? Color("Primary").opacity(0.2) : Color.clear)
                                .cornerRadius(8)
                                .onTapGesture { selectedIcon = icon }
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("每日目标") {
                    Stepper("\(dailyTarget) 次/天", value: $dailyTarget, in: 1...20)
                }
            }
            .navigationTitle("添加习惯")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("添加") {
                        let habit = Habit(name: name.trimmingCharacters(in: .whitespaces), icon: selectedIcon, dailyTarget: dailyTarget)
                        modelContext.insert(habit)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func pickIcon(for name: String) -> String {
        if name.contains("读") || name.contains("书") { return "📖" }
        if name.contains("运动") || name.contains("跑") || name.contains("健身") { return "🏃" }
        if name.contains("写") || name.contains("记") { return "✍️" }
        if name.contains("水") || name.contains("喝") { return "💧" }
        if name.contains("冥想") || name.contains("静") { return "🧘" }
        if name.contains("学") || name.contains("习") { return "📚" }
        if name.contains("早") || name.contains("起") { return "🌅" }
        if name.contains("睡") || name.contains("眠") { return "🌙" }
        return "⭐"
    }
}
