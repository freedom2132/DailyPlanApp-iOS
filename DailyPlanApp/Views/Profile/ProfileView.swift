import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<TaskItem> { $0.status == "COMPLETED" && !$0.isDeleted })
    private var completedTasks: [TaskItem]

    @Query(filter: #Predicate<Habit> { $0.isActive })
    private var activeHabits: [Habit]

    @AppStorage("darkMode") private var darkMode = false

    @State private var showFortune = false
    @State private var showMiniGame = false
    @State private var showExportAlert = false
    @State private var exportMessage = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Stats card
                    HStack {
                        statCard(value: "\(completedTasks.count)", label: "已完成任务")
                        Divider().frame(height: 60)
                        statCard(value: "\(activeHabits.count)", label: "活跃习惯")
                    }
                    .padding()
                    .background(Color("Surface"))
                    .cornerRadius(10)

                    // Cards
                    profileCard(title: "今日一签", subtitle: "摇一摇抽签", icon: "sparkles") {
                        showFortune = true
                    }

                    profileCard(title: "小游戏", subtitle: "成语、诗词、1024", icon: "gamecontroller.fill") {
                        showMiniGame = true
                    }

                    // Dark mode toggle
                    HStack {
                        Image(systemName: "moon.fill")
                            .foregroundColor(Color("Primary"))
                            .frame(width: 32)
                        Toggle("深色模式", isOn: $darkMode)
                    }
                    .padding()
                    .background(Color("Surface"))
                    .cornerRadius(10)

                    // Export
                    profileCard(title: "导出数据", subtitle: "备份到文件", icon: "square.and.arrow.up") {
                        exportData()
                    }

                    // Version
                    VStack(spacing: 4) {
                        Text("今日三件 v1.0")
                            .font(.caption)
                            .foregroundColor(Color("TextHint"))
                        Text("每天专注三件事，让生活更有掌控感")
                            .font(.caption2)
                            .foregroundColor(Color("TextHint"))
                    }
                    .padding(.top, 20)
                }
                .padding()
            }
            .background(Color("BackgroundPrimary"))
            .navigationTitle("我的")
            .sheet(isPresented: $showFortune) {
                FortuneView()
            }
            .sheet(isPresented: $showMiniGame) {
                MiniGameView()
            }
            .alert("导出", isPresented: $showExportAlert) {
                Button("好的", role: .cancel) {}
            } message: {
                Text(exportMessage)
            }
        }
    }

    private func statCard(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title)
                .bold()
                .foregroundColor(Color("Primary"))
            Text(label)
                .font(.caption)
                .foregroundColor(Color("TextSecondary"))
        }
        .frame(maxWidth: .infinity)
    }

    private func profileCard(title: String, subtitle: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Color("Primary"))
                    .frame(width: 32)
                VStack(alignment: .leading) {
                    Text(title).font(.body).bold().foregroundColor(Color("TextPrimary"))
                    Text(subtitle).font(.caption).foregroundColor(Color("TextSecondary"))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(Color("TextHint"))
                    .font(.caption)
            }
            .padding()
            .background(Color("Surface"))
            .cornerRadius(10)
        }
    }

    private func exportData() {
        exportMessage = "数据已准备导出"
        showExportAlert = true
    }
}
