import Foundation

struct StoredQuizResult: Codable, Equatable {
    let id: String
    let quizTitle: String
    let iconName: String
    let iconGlow: ResultIconGlow
    let completedAt: Date
    let correctCount: Int
    let totalCount: Int
    let durationSeconds: Int
    let xpEarned: Int
    let scorePercent: Int
    let isComposite: Bool
}

extension StoredQuizResult {
    init(result: QuizResult) {
        id = result.id
        quizTitle = result.quizTitle
        iconName = result.iconName
        iconGlow = result.iconGlow
        completedAt = result.completedAt
        correctCount = result.correctCount
        totalCount = result.totalCount
        durationSeconds = result.durationSeconds
        xpEarned = result.xpEarned
        scorePercent = result.scorePercent
        isComposite = result.isComposite
    }

    var quizResult: QuizResult {
        QuizResult(
            id: id,
            quizTitle: quizTitle,
            iconName: iconName,
            iconGlow: iconGlow,
            completedAt: completedAt,
            correctCount: correctCount,
            totalCount: totalCount,
            durationSeconds: durationSeconds,
            xpEarned: xpEarned,
            scorePercent: scorePercent,
            isComposite: isComposite
        )
    }
}

extension QuizPlaySessionResult {
    func makeQuizResult() -> QuizResult {
        QuizResult(
            id: sessionID,
            quizTitle: quizTitle,
            iconName: iconName,
            iconGlow: .blue,
            completedAt: Date(),
            correctCount: correctCount,
            totalCount: totalCount,
            durationSeconds: durationSeconds,
            xpEarned: xpEarned,
            scorePercent: scorePercent,
            isComposite: false
        )
    }
}

extension ResultIconGlow: Codable {}

final class GuestProgressStore {
    static let shared = GuestProgressStore()

    private let userDefaults: UserDefaults
    private let storageKey = "guest.localProgress"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func append(_ result: QuizResult) {
        var stored = loadStored()
        stored.insert(StoredQuizResult(result: result), at: 0)
        save(stored)
    }

    func fetchResults() -> [QuizResult] {
        loadStored().map(\.quizResult)
    }

    func fetchSummary() -> ResultsSummary {
        let results = fetchResults()
        guard !results.isEmpty else {
            return ResultsSummary(
                averageScorePercent: 0,
                quizzesCompleted: 0,
                totalAttempts: 0,
                streakDays: 0,
                globalRank: 0
            )
        }
        let totalScore = results.reduce(0) { $0 + $1.scorePercent }
        let average = totalScore / results.count
        let uniqueQuizzes = Set(results.map(\.quizTitle)).count
        return ResultsSummary(
            averageScorePercent: average,
            quizzesCompleted: uniqueQuizzes,
            totalAttempts: results.count,
            streakDays: 1,
            globalRank: 0
        )
    }

    func clear() {
        userDefaults.removeObject(forKey: storageKey)
    }

    private func loadStored() -> [StoredQuizResult] {
        guard
            let data = userDefaults.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode([StoredQuizResult].self, from: data)
        else {
            return []
        }
        return decoded
    }

    private func save(_ results: [StoredQuizResult]) {
        guard let data = try? JSONEncoder().encode(results) else { return }
        userDefaults.set(data, forKey: storageKey)
    }
}
