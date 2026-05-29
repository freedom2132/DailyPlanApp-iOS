import SwiftUI

struct MiniGameView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab bar
                HStack(spacing: 0) {
                    gameTab("成语填字", index: 0)
                    gameTab("诗词配对", index: 1)
                    gameTab("每日挑战", index: 2)
                    gameTab("1024", index: 3)
                }
                .padding(.horizontal)
                .padding(.top, 8)

                // Game content
                TabView(selection: $selectedTab) {
                    IdiomGameView().tag(0)
                    PoetryGameView().tag(1)
                    DailyChallengeView().tag(2)
                    Game1024View().tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .background(Color("BackgroundPrimary"))
            .navigationTitle("小游戏")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") { dismiss() }
                }
            }
        }
    }

    private func gameTab(_ title: String, index: Int) -> some View {
        Button { withAnimation { selectedTab = index } } label: {
            Text(title)
                .font(.subheadline)
                .fontWeight(selectedTab == index ? .bold : .regular)
                .foregroundColor(selectedTab == index ? Color("Primary") : Color("TextHint"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    VStack {
                        Spacer()
                        if selectedTab == index {
                            Rectangle()
                                .fill(Color("Primary"))
                                .frame(height: 2)
                        }
                    }
                )
        }
    }
}

// MARK: - Idiom Game

struct IdiomGameView: View {
    @State private var quiz = MiniGameEngine.getIdiomQuiz()
    @State private var selectedAnswer: Character?
    @State private var isAnswered = false
    @State private var streak = 0

    var body: some View {
        VStack(spacing: 20) {
            Text("成语填字")
                .font(.headline)
                .foregroundColor(Color("TextPrimary"))

            Text("连续答对: \(streak)")
                .font(.caption)
                .foregroundColor(Color("TextSecondary"))

            Text(quiz.display)
                .font(.system(size: 36, weight: .bold, design: .serif))
                .foregroundColor(Color("TextPrimary"))
                .padding()

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(quiz.options, id: \.self) { option in
                    Button {
                        selectAnswer(option)
                    } label: {
                        Text(String(option))
                            .font(.title2)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(answerBackground(option))
                            .foregroundColor(answerForeground(option))
                            .cornerRadius(10)
                    }
                    .disabled(isAnswered)
                }
            }
            .padding(.horizontal)

            if isAnswered {
                VStack(spacing: 8) {
                    Text(selectedAnswer == quiz.answer ? "✅ 正确！" : "❌ 答案是: \(quiz.answer)")
                        .font(.headline)
                        .foregroundColor(selectedAnswer == quiz.answer ? Color("Success") : Color("PriorityHigh"))
                    Text(quiz.meaning)
                        .font(.caption)
                        .foregroundColor(Color("TextSecondary"))
                        .multilineTextAlignment(.center)

                    Button("下一题") { nextQuiz() }
                        .buttonStyle(.bordered)
                        .tint(Color("Primary"))
                }
                .padding()
                .background(Color("Surface"))
                .cornerRadius(10)
            }

            Spacer()
        }
        .padding()
    }

    private func selectAnswer(_ answer: Character) {
        selectedAnswer = answer
        isAnswered = true
        if answer == quiz.answer {
            streak += 1
        } else {
            streak = 0
        }
    }

    private func nextQuiz() {
        quiz = MiniGameEngine.getIdiomQuiz()
        selectedAnswer = nil
        isAnswered = false
    }

    private func answerBackground(_ option: Character) -> Color {
        guard isAnswered else { return Color("Surface") }
        if option == quiz.answer { return Color("Success").opacity(0.2) }
        if option == selectedAnswer { return Color("PriorityHigh").opacity(0.2) }
        return Color("Surface")
    }

    private func answerForeground(_ option: Character) -> Color {
        guard isAnswered else { return Color("TextPrimary") }
        if option == quiz.answer { return Color("Success") }
        if option == selectedAnswer { return Color("PriorityHigh") }
        return Color("TextPrimary")
    }
}

// MARK: - Poetry Game

struct PoetryGameView: View {
    @State private var quiz = MiniGameEngine.getPoetryQuiz()
    @State private var selectedAnswer: String?
    @State private var isAnswered = false

    var body: some View {
        VStack(spacing: 20) {
            Text("诗词配对")
                .font(.headline)
                .foregroundColor(Color("TextPrimary"))

            Text(quiz.upperLine)
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundColor(Color("TextPrimary"))
                .padding()

            Text("请选择下联：")
                .font(.subheadline)
                .foregroundColor(Color("TextSecondary"))

            ForEach(quiz.options, id: \.self) { option in
                Button { selectAnswer(option) } label: {
                    Text(option)
                        .font(.title3)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(answerBg(option))
                        .foregroundColor(answerFg(option))
                        .cornerRadius(10)
                }
                .disabled(isAnswered)
            }
            .padding(.horizontal)

            if isAnswered {
                VStack(spacing: 4) {
                    Text(selectedAnswer == quiz.correctLower ? "✅ 正确！" : "❌ 正确答案: \(quiz.correctLower)")
                        .font(.headline)
                        .foregroundColor(selectedAnswer == quiz.correctLower ? Color("Success") : Color("PriorityHigh"))
                    Text("—— \(quiz.author)《\(quiz.title)》")
                        .font(.caption)
                        .foregroundColor(Color("TextSecondary"))

                    Button("下一题") { nextQuiz() }
                        .buttonStyle(.bordered)
                        .tint(Color("Primary"))
                }
                .padding()
                .background(Color("Surface"))
                .cornerRadius(10)
            }

            Spacer()
        }
        .padding()
    }

    private func selectAnswer(_ answer: String) {
        selectedAnswer = answer
        isAnswered = true
    }

    private func nextQuiz() {
        quiz = MiniGameEngine.getPoetryQuiz()
        selectedAnswer = nil
        isAnswered = false
    }

    private func answerBg(_ option: String) -> Color {
        guard isAnswered else { return Color("Surface") }
        if option == quiz.correctLower { return Color("Success").opacity(0.2) }
        if option == selectedAnswer { return Color("PriorityHigh").opacity(0.2) }
        return Color("Surface")
    }

    private func answerFg(_ option: String) -> Color {
        guard isAnswered else { return Color("TextPrimary") }
        if option == quiz.correctLower { return Color("Success") }
        if option == selectedAnswer { return Color("PriorityHigh") }
        return Color("TextPrimary")
    }
}

// MARK: - Daily Challenge

struct DailyChallengeView: View {
    @State private var challenge = MiniGameEngine.getDailyChallenge()
    @State private var selectedAnswer: Character?
    @State private var isAnswered = false

    var body: some View {
        VStack(spacing: 20) {
            Text("每日挑战")
                .font(.headline)
                .foregroundColor(Color("TextPrimary"))

            Text(dateString)
                .font(.caption)
                .foregroundColor(Color("TextSecondary"))

            let quiz = challenge.idiomQuiz
            Text(quiz.display)
                .font(.system(size: 36, weight: .bold, design: .serif))
                .foregroundColor(Color("TextPrimary"))
                .padding()

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(quiz.options, id: \.self) { option in
                    Button {
                        selectedAnswer = option
                        isAnswered = true
                    } label: {
                        Text(String(option))
                            .font(.title2)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                isAnswered ?
                                    (option == quiz.answer ? Color("Success").opacity(0.2) :
                                        option == selectedAnswer ? Color("PriorityHigh").opacity(0.2) : Color("Surface"))
                                    : Color("Surface")
                            )
                            .cornerRadius(10)
                    }
                    .disabled(isAnswered)
                }
            }
            .padding(.horizontal)

            if isAnswered {
                VStack(spacing: 8) {
                    Text(selectedAnswer == quiz.answer ? "🎉 恭喜！" : "答案是: \(quiz.answer)")
                        .font(.headline)
                        .foregroundColor(selectedAnswer == quiz.answer ? Color("Success") : Color("PriorityHigh"))
                    Text(quiz.meaning)
                        .font(.caption)
                        .foregroundColor(Color("TextSecondary"))
                }
                .padding()
                .background(Color("Surface"))
                .cornerRadius(10)
            }

            Spacer()
        }
        .padding()
    }

    private var dateString: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy年M月d日"
        f.locale = Locale(identifier: "zh_CN")
        return f.string(from: Date())
    }
}

// MARK: - 1024 Game

struct Game1024View: View {
    @State private var state = MiniGameEngine.Game1024State.initial()
    @State private var dragOffset: CGSize = .zero
    @State private var hasContinuedAfterWin = false

    private let gridSize = 4
    private let cellSize: CGFloat = 70
    private let spacing: CGFloat = 6

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text("1024")
                        .font(.title2).bold()
                        .foregroundColor(Color("TextPrimary"))
                    Text("合并数字，达到1024！")
                        .font(.caption)
                        .foregroundColor(Color("TextSecondary"))
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("分数")
                        .font(.caption)
                        .foregroundColor(Color("TextSecondary"))
                    Text("\(state.score)")
                        .font(.title2).bold()
                        .foregroundColor(Color("Primary"))
                }
            }
            .padding(.horizontal)

            // Grid
            VStack(spacing: spacing) {
                ForEach(0..<gridSize, id: \.self) { row in
                    HStack(spacing: spacing) {
                        ForEach(0..<gridSize, id: \.self) { col in
                            let value = state.grid[row][col]
                            Text(value == 0 ? "" : "\(value)")
                                .font(value >= 100 ? .title3 : .title2)
                                .bold()
                                .frame(width: cellSize, height: cellSize)
                                .background(cellColor(value))
                                .foregroundColor(cellTextColor(value))
                                .cornerRadius(8)
                        }
                    }
                }
            }
            .padding()
            .background(Color("Surface"))
            .cornerRadius(12)
            .gesture(
                DragGesture()
                    .onEnded { value in
                        let horizontal = value.translation.width
                        let vertical = value.translation.height
                        if abs(horizontal) > abs(vertical) {
                            state = state.move(direction: horizontal > 0 ? "right" : "left")
                        } else {
                            state = state.move(direction: vertical > 0 ? "down" : "up")
                        }
                    }
            )

            if state.gameOver {
                VStack(spacing: 8) {
                    Text("游戏结束！")
                        .font(.headline)
                        .foregroundColor(Color("PriorityHigh"))
                    Text("最终得分: \(state.score)")
                        .foregroundColor(Color("TextSecondary"))
                    Button("重新开始") { state = .initial(); hasContinuedAfterWin = false }
                        .buttonStyle(.bordered)
                        .tint(Color("Primary"))
                }
            } else if state.won && !hasContinuedAfterWin {
                VStack(spacing: 8) {
                    Text("🎉 达到1024！")
                        .font(.headline)
                        .foregroundColor(Color("Success"))
                    Button("继续游戏") { hasContinuedAfterWin = true }
                        .buttonStyle(.bordered)
                        .tint(Color("Primary"))
                    Button("重新开始") { state = .initial(); hasContinuedAfterWin = false }
                        .font(.caption)
                        .foregroundColor(Color("TextHint"))
                }
            }

            Button("新游戏") { state = .initial(); hasContinuedAfterWin = false }
                .buttonStyle(.bordered)
                .tint(Color("Primary"))

            Spacer()
        }
        .padding()
    }

    private func cellColor(_ value: Int) -> Color {
        switch value {
        case 0: return Color("Divider").opacity(0.3)
        case 2: return Color(red: 0.93, green: 0.90, blue: 0.85)
        case 4: return Color(red: 0.93, green: 0.88, blue: 0.78)
        case 8: return Color(red: 0.95, green: 0.72, blue: 0.48)
        case 16: return Color(red: 0.95, green: 0.58, blue: 0.38)
        case 32: return Color(red: 0.95, green: 0.48, blue: 0.36)
        case 64: return Color(red: 0.95, green: 0.36, blue: 0.24)
        case 128: return Color(red: 0.92, green: 0.82, blue: 0.42)
        case 256: return Color(red: 0.92, green: 0.80, blue: 0.36)
        case 512: return Color(red: 0.92, green: 0.78, blue: 0.28)
        case 1024: return Color(red: 0.92, green: 0.75, blue: 0.20)
        default: return Color(red: 0.20, green: 0.20, blue: 0.20)
        }
    }

    private func cellTextColor(_ value: Int) -> Color {
        value <= 4 ? Color("TextPrimary") : .white
    }
}
