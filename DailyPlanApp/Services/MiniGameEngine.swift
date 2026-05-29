import Foundation

enum MiniGameEngine {

    // MARK: - Idiom Quiz (成语填字)

    struct IdiomQuiz {
        let idiom: String       // 完整成语
        let display: String     // 显示（__表示空）
        let answer: Character   // 正确答案
        let options: [Character] // 4个选项
        let meaning: String     // 释义
    }

    private static let idiomBank: [IdiomQuiz] = [
        IdiomQuiz(idiom: "一心一意", display: "一__一意", answer: "心",
                  options: ["心", "意", "思", "想"],
                  meaning: "形容心思专一，别无他念"),
        IdiomQuiz(idiom: "画龙点睛", display: "画__点睛", answer: "龙",
                  options: ["龙", "凤", "虎", "蛇"],
                  meaning: "比喻在关键处用几句话点明实质"),
        IdiomQuiz(idiom: "锦上添花", display: "锦上__花", answer: "添",
                  options: ["添", "加", "插", "缀"],
                  meaning: "比喻好上加好，美上添美"),
        IdiomQuiz(idiom: "鹤立鸡群", display: "__立鸡群", answer: "鹤",
                  options: ["鹤", "凤", "鹰", "雁"],
                  meaning: "比喻一个人的才能或仪表在一群人中显得很突出"),
        IdiomQuiz(idiom: "对牛弹琴", display: "对__弹琴", answer: "牛",
                  options: ["牛", "马", "羊", "猪"],
                  meaning: "比喻对不懂事理的人讲道理"),
        IdiomQuiz(idiom: "马到成功", display: "马到__功", answer: "成",
                  options: ["成", "立", "见", "收"],
                  meaning: "形容事情顺利，一开始就取得成功"),
        IdiomQuiz(idiom: "井底之蛙", display: "井__之蛙", answer: "底",
                  options: ["底", "中", "下", "里"],
                  meaning: "比喻见识狭窄的人"),
        IdiomQuiz(idiom: "掩耳盗铃", display: "掩__盗铃", answer: "耳",
                  options: ["耳", "目", "鼻", "口"],
                  meaning: "比喻自己欺骗自己"),
        IdiomQuiz(idiom: "亡羊补牢", display: "亡羊__牢", answer: "补",
                  options: ["补", "修", "建", "筑"],
                  meaning: "比喻出了问题以后想办法补救"),
        IdiomQuiz(idiom: "守株待兔", display: "守__待兔", answer: "株",
                  options: ["株", "树", "林", "木"],
                  meaning: "比喻不主动努力，存在侥幸心理"),
        IdiomQuiz(idiom: "叶公好龙", display: "__公好龙", answer: "叶",
                  options: ["叶", "李", "王", "张"],
                  meaning: "比喻口头上说爱好某事物，实际上并不真爱好"),
        IdiomQuiz(idiom: "杯弓蛇影", display: "杯__蛇影", answer: "弓",
                  options: ["弓", "箭", "刀", "剑"],
                  meaning: "比喻因疑神疑鬼而引起恐惧"),
        IdiomQuiz(idiom: "塞翁失马", display: "塞翁__马", answer: "失",
                  options: ["失", "得", "买", "卖"],
                  meaning: "比喻坏事在一定条件下可变为好事"),
        IdiomQuiz(idiom: "刻舟求剑", display: "刻__求剑", answer: "舟",
                  options: ["舟", "船", "木", "石"],
                  meaning: "比喻办事刻板，拘泥而不知变通"),
        IdiomQuiz(idiom: "闻鸡起舞", display: "闻鸡__舞", answer: "起",
                  options: ["起", "跳", "飞", "狂"],
                  meaning: "比喻有志报国的人及时奋起"),
        IdiomQuiz(idiom: "胸有成竹", display: "胸有__竹", answer: "成",
                  options: ["成", "翠", "绿", "青"],
                  meaning: "比喻在做事之前已经拿定主意"),
        IdiomQuiz(idiom: "水滴石穿", display: "水__石穿", answer: "滴",
                  options: ["滴", "流", "冲", "击"],
                  meaning: "比喻只要有恒心，不断努力，事情一定成功"),
        IdiomQuiz(idiom: "百发百中", display: "百__百中", answer: "发",
                  options: ["发", "射", "击", "投"],
                  meaning: "形容射箭或射击非常准"),
        IdiomQuiz(idiom: "千钧一发", display: "千钧一__", answer: "发",
                  options: ["发", "刻", "瞬", "秒"],
                  meaning: "比喻情况万分危急"),
        IdiomQuiz(idiom: "举一反三", display: "举一__三", answer: "反",
                  options: ["反", "返", "回", "推"],
                  meaning: "比喻从一件事情类推而知道其他许多事情"),
    ]

    /// Returns a random idiom quiz.
    static func getIdiomQuiz() -> IdiomQuiz {
        idiomBank.randomElement()!
    }

    /// Returns an idiom quiz deterministic for the current calendar day.
    private static func getIdiomQuizOfDay() -> IdiomQuiz {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return idiomBank[day % idiomBank.count]
    }

    // MARK: - Poetry Quiz (诗词配对)

    struct PoetryPair {
        let upperLine: String
        let lowerLine: String
        let author: String
        let title: String
    }

    private static let poetryBank: [PoetryPair] = [
        PoetryPair(upperLine: "床前明月光", lowerLine: "疑是地上霜",
                   author: "李白", title: "静夜思"),
        PoetryPair(upperLine: "举头望明月", lowerLine: "低头思故乡",
                   author: "李白", title: "静夜思"),
        PoetryPair(upperLine: "白日依山尽", lowerLine: "黄河入海流",
                   author: "王之涣", title: "登鹳雀楼"),
        PoetryPair(upperLine: "欲穷千里目", lowerLine: "更上一层楼",
                   author: "王之涣", title: "登鹳雀楼"),
        PoetryPair(upperLine: "春眠不觉晓", lowerLine: "处处闻啼鸟",
                   author: "孟浩然", title: "春晓"),
        PoetryPair(upperLine: "夜来风雨声", lowerLine: "花落知多少",
                   author: "孟浩然", title: "春晓"),
        PoetryPair(upperLine: "锄禾日当午", lowerLine: "汗滴禾下土",
                   author: "李绅", title: "悯农"),
        PoetryPair(upperLine: "谁知盘中餐", lowerLine: "粒粒皆辛苦",
                   author: "李绅", title: "悯农"),
        PoetryPair(upperLine: "离离原上草", lowerLine: "一岁一枯荣",
                   author: "白居易", title: "赋得古原草送别"),
        PoetryPair(upperLine: "野火烧不尽", lowerLine: "春风吹又生",
                   author: "白居易", title: "赋得古原草送别"),
        PoetryPair(upperLine: "千山鸟飞绝", lowerLine: "万径人踪灭",
                   author: "柳宗元", title: "江雪"),
        PoetryPair(upperLine: "孤舟蓑笠翁", lowerLine: "独钓寒江雪",
                   author: "柳宗元", title: "江雪"),
        PoetryPair(upperLine: "远上寒山石径斜", lowerLine: "白云生处有人家",
                   author: "杜牧", title: "山行"),
        PoetryPair(upperLine: "停车坐爱枫林晚", lowerLine: "霜叶红于二月花",
                   author: "杜牧", title: "山行"),
        PoetryPair(upperLine: "两个黄鹂鸣翠柳", lowerLine: "一行白鹭上青天",
                   author: "杜甫", title: "绝句"),
        PoetryPair(upperLine: "窗含西岭千秋雪", lowerLine: "门泊东吴万里船",
                   author: "杜甫", title: "绝句"),
    ]

    struct PoetryQuiz {
        let upperLine: String
        let correctLower: String
        let options: [String]   // 4个下联选项
        let author: String
        let title: String
    }

    /// Returns a random poetry quiz with 4 options (1 correct + 3 wrong).
    static func getPoetryQuiz() -> PoetryQuiz {
        let correct = poetryBank.randomElement()!
        let wrongOptions = poetryBank
            .filter { $0.upperLine != correct.upperLine || $0.lowerLine != correct.lowerLine }
            .shuffled()
            .prefix(3)
            .map { $0.lowerLine }
        let options = ([correct.lowerLine] + wrongOptions).shuffled()
        return PoetryQuiz(
            upperLine: correct.upperLine,
            correctLower: correct.lowerLine,
            options: options,
            author: correct.author,
            title: correct.title
        )
    }

    // MARK: - Daily Challenge (每日挑战)

    struct DailyChallenge {
        let idiomQuiz: IdiomQuiz
    }

    /// Returns the daily challenge (deterministic per day).
    static func getDailyChallenge() -> DailyChallenge {
        DailyChallenge(idiomQuiz: getIdiomQuizOfDay())
    }

    // MARK: - 1024 Game

    struct Game1024State {
        let grid: [[Int]]
        let score: Int
        let gameOver: Bool
        let won: Bool

        /// Creates the initial game state with two random tiles.
        static func initial() -> Game1024State {
            var grid = [[Int]](repeating: [Int](repeating: 0, count: 4), count: 4)
            let state = Game1024State(grid: grid, score: 0, gameOver: false, won: false)
            let first = state.addRandomTile(to: &grid)
            let second = state.addRandomTile(to: &grid)
            _ = first; _ = second
            return Game1024State(grid: grid, score: 0, gameOver: false, won: false)
        }

        /// Moves tiles in the given direction ("left", "right", "up", "down")
        /// and returns a new game state.
        func move(direction: String) -> Game1024State {
            var newGrid = grid
            var gained = 0
            var moved = false

            switch direction {
            case "left":
                for r in 0..<4 {
                    let result = slideAndMerge(newGrid[r])
                    newGrid[r] = result.line
                    gained += result.gained
                    if result.didMove { moved = true }
                }
            case "right":
                for r in 0..<4 {
                    let row = newGrid[r].reversed()
                    let result = slideAndMerge(Array(row))
                    newGrid[r] = result.line.reversed()
                    gained += result.gained
                    if result.didMove { moved = true }
                }
            case "up":
                for c in 0..<4 {
                    var col = [Int]()
                    for r in 0..<4 { col.append(newGrid[r][c]) }
                    let result = slideAndMerge(col)
                    for r in 0..<4 {
                        if newGrid[r][c] != result.line[r] { moved = true }
                        newGrid[r][c] = result.line[r]
                    }
                    gained += result.gained
                }
            case "down":
                for c in 0..<4 {
                    var col = [Int]()
                    for r in stride(from: 3, through: 0, by: -1) { col.append(newGrid[r][c]) }
                    let result = slideAndMerge(col)
                    for r in 0..<4 {
                        let newVal = result.line[3 - r]
                        if newGrid[r][c] != newVal { moved = true }
                        newGrid[r][c] = newVal
                    }
                    gained += result.gained
                }
            default:
                break
            }

            guard moved else { return self }

            let resultGrid = newGrid
            let newScore = score + gained
            let hasWon = resultGrid.contains { $0.contains { $0 >= 1024 } }

            var mutableGrid = resultGrid
            addRandomTile(to: &mutableGrid)
            let isGameOver = checkGameOver(mutableGrid)

            return Game1024State(
                grid: mutableGrid,
                score: newScore,
                gameOver: isGameOver,
                won: hasWon
            )
        }

        // MARK: - Private helpers

        private func slideAndMerge(_ line: [Int]) -> (line: [Int], gained: Int, didMove: Bool) {
            let filtered = line.filter { $0 != 0 }
            var result = [Int]()
            var gained = 0
            var i = 0
            while i < filtered.count {
                if i + 1 < filtered.count && filtered[i] == filtered[i + 1] {
                    result.append(filtered[i] * 2)
                    gained += filtered[i] * 2
                    i += 2
                } else {
                    result.append(filtered[i])
                    i += 1
                }
            }
            while result.count < 4 { result.append(0) }

            var didMove = false
            for j in 0..<4 {
                if result[j] != line[j] { didMove = true }
            }
            return (result, gained, didMove)
        }

        @discardableResult
        private func addRandomTile(to grid: inout [[Int]]) -> Bool {
            var empty = [(Int, Int)]()
            for r in 0..<4 {
                for c in 0..<4 {
                    if grid[r][c] == 0 { empty.append((r, c)) }
                }
            }
            guard let pos = empty.randomElement() else { return false }
            grid[pos.0][pos.1] = Double.random(in: 0..<1) < 0.9 ? 2 : 4
            return true
        }

        private func checkGameOver(_ grid: [[Int]]) -> Bool {
            for r in 0..<4 {
                for c in 0..<4 {
                    if grid[r][c] == 0 { return false }
                    if c < 3 && grid[r][c] == grid[r][c + 1] { return false }
                    if r < 3 && grid[r][c] == grid[r + 1][c] { return false }
                }
            }
            return true
        }
    }
}
