import SwiftUI

struct FortuneView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("fortuneItems") private var fortuneItemsData: Data = "[]".data(using: .utf8)!
    @AppStorage("fortuneHistory") private var fortuneHistoryData: Data = "[]".data(using: .utf8)!

    @State private var items: [String] = []
    @State private var history: [String] = []
    @State private var currentResult: String?
    @State private var isShaking = false
    @State private var showAddSheet = false
    @State private var newItemText = ""

    private let quickItems = [
        "今天会有好事发生", "保持耐心，静待花开", "行动比完美更重要",
        "今天适合专注工作", "给自己一个微笑", "困难是暂时的，成长是永久的",
        "相信直觉，跟着心走", "今天会遇到贵人"
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Pool display
                VStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 48))
                        .foregroundColor(Color("Primary"))

                    if let result = currentResult {
                        Text("\"\(result)\"")
                            .font(.title3)
                            .italic()
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color("TextPrimary"))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color("Surface"))
                            .cornerRadius(10)

                        HStack(spacing: 12) {
                            Button("再抽一次") { drawFortune() }
                                .buttonStyle(.bordered)
                                .tint(Color("Primary"))
                            Button("移除此签") { removeCurrentItem() }
                                .buttonStyle(.bordered)
                                .tint(Color("PriorityHigh"))
                        }
                    } else if isShaking {
                        VStack {
                            ProgressView()
                            Text("摇签中...")
                                .font(.caption)
                                .foregroundColor(Color("TextSecondary"))
                        }
                    } else if items.isEmpty {
                        VStack(spacing: 8) {
                            Text("签筒是空的")
                                .foregroundColor(Color("TextHint"))
                            Text("点击下方添加签文")
                                .font(.caption)
                                .foregroundColor(Color("TextHint"))
                        }
                    } else {
                        Text("签筒中有 \(items.count) 支签")
                            .foregroundColor(Color("TextSecondary"))
                        Button { drawFortune() } label: {
                            Text("抽签")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("Primary"))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal, 40)
                    }
                }
                .padding()

                // History
                if !history.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("抽签记录")
                                .font(.headline)
                                .foregroundColor(Color("TextPrimary"))
                            Spacer()
                            Button("清除") { history.removeAll(); saveHistory() }
                                .font(.caption)
                                .foregroundColor(Color("TextHint"))
                        }

                        ForEach(history.prefix(10), id: \.self) { item in
                            Text("• \(item)")
                                .font(.caption)
                                .foregroundColor(Color("TextSecondary"))
                        }
                    }
                    .padding()
                    .background(Color("Surface"))
                    .cornerRadius(10)
                }

                Spacer()
            }
            .padding()
            .background(Color("BackgroundPrimary"))
            .navigationTitle("今日一签")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button { showAddSheet = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear { loadItems() }
            .sheet(isPresented: $showAddSheet) {
                addSheet
            }
        }
    }

    private var addSheet: some View {
        NavigationStack {
            List {
                Section("快捷签文") {
                    ForEach(quickItems, id: \.self) { item in
                        Button {
                            items.append(item)
                            saveItems()
                            showAddSheet = false
                        } label: {
                            Text(item)
                                .foregroundColor(Color("TextPrimary"))
                        }
                    }
                }
                Section("自定义") {
                    TextField("输入签文", text: $newItemText)
                    Button("添加") {
                        if !newItemText.isEmpty {
                            items.append(newItemText)
                            saveItems()
                            newItemText = ""
                            showAddSheet = false
                        }
                    }
                    .disabled(newItemText.isEmpty)
                }
            }
            .navigationTitle("添加签文")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { showAddSheet = false }
                }
            }
        }
    }

    private func drawFortune() {
        guard !items.isEmpty else { return }
        isShaking = true
        currentResult = nil

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let result = items.randomElement()!
            currentResult = result
            history.insert(result, at: 0)
            if history.count > 50 { history = Array(history.prefix(50)) }
            saveHistory()
            isShaking = false
        }
    }

    private func removeCurrentItem() {
        if let result = currentResult, let idx = items.firstIndex(of: result) {
            items.remove(at: idx)
            saveItems()
        }
        currentResult = nil
    }

    private func loadItems() {
        items = (try? JSONDecoder().decode([String].self, from: fortuneItemsData)) ?? []
        history = (try? JSONDecoder().decode([String].self, from: fortuneHistoryData)) ?? []
    }

    private func saveItems() {
        fortuneItemsData = (try? JSONEncoder().encode(items)) ?? Data()
    }

    private func saveHistory() {
        fortuneHistoryData = (try? JSONEncoder().encode(history)) ?? Data()
    }
}
