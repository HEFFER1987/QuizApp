import Foundation

enum ResultsRepositoryError: Error {
    case loadFailed
}

protocol ResultsRepository {
    func fetchResults() async throws -> [QuizResult]
    func fetchSummary() async throws -> ResultsSummary
}

struct ResultsRepositoryMock: ResultsRepository {
    func fetchResults() async throws -> [QuizResult] {
        Self.sampleResults
    }

    func fetchSummary() async throws -> ResultsSummary {
        ResultsSummary(
            averageScorePercent: 84,
            quizzesCompleted: 48,
            totalAttempts: 63,
            streakDays: 12
        )
    }

    private static let sampleResults: [QuizResult] = {
        let now = Date()
        let calendar = Calendar.current

        func date(daysAgo: Int, hour: Int, minute: Int) -> Date {
            var components = calendar.dateComponents([.year, .month, .day], from: now)
            components.hour = hour
            components.minute = minute
            let base = calendar.date(from: components) ?? now
            return calendar.date(byAdding: .day, value: -daysAgo, to: base) ?? now
        }

        return [
            QuizResult(
                id: "1",
                quizTitle: "Swift Basics",
                iconName: "chevron.left.forwardslash.chevron.right",
                iconGlow: .blue,
                completedAt: date(daysAgo: 1, hour: 18, minute: 30),
                correctCount: 12,
                totalCount: 15,
                durationSeconds: 225,
                xpEarned: 150,
                scorePercent: 80,
                isComposite: false
            ),
            QuizResult(
                id: "2",
                quizTitle: "World History",
                iconName: "globe.americas.fill",
                iconGlow: .blue,
                completedAt: date(daysAgo: 2, hour: 14, minute: 10),
                correctCount: 18,
                totalCount: 20,
                durationSeconds: 512,
                xpEarned: 220,
                scorePercent: 90,
                isComposite: false
            ),
            QuizResult(
                id: "3",
                quizTitle: "English Grammar",
                iconName: "book.fill",
                iconGlow: .purple,
                completedAt: date(daysAgo: 3, hour: 20, minute: 5),
                correctCount: 8,
                totalCount: 12,
                durationSeconds: 245,
                xpEarned: 90,
                scorePercent: 67,
                isComposite: false
            ),
            QuizResult(
                id: "4",
                quizTitle: "Swift Advanced",
                iconName: "chevron.left.forwardslash.chevron.right",
                iconGlow: .orange,
                completedAt: date(daysAgo: 5, hour: 11, minute: 40),
                correctCount: 20,
                totalCount: 20,
                durationSeconds: 380,
                xpEarned: 300,
                scorePercent: 100,
                isComposite: false
            ),
            QuizResult(
                id: "5",
                quizTitle: "Mixed Challenge",
                iconName: "square.stack.3d.up.fill",
                iconGlow: .green,
                completedAt: date(daysAgo: 6, hour: 16, minute: 0),
                correctCount: 14,
                totalCount: 18,
                durationSeconds: 410,
                xpEarned: 180,
                scorePercent: 78,
                isComposite: true
            ),
            QuizResult(
                id: "6",
                quizTitle: "Literature Classics",
                iconName: "text.book.closed.fill",
                iconGlow: .purple,
                completedAt: date(daysAgo: 7, hour: 19, minute: 25),
                correctCount: 9,
                totalCount: 10,
                durationSeconds: 198,
                xpEarned: 160,
                scorePercent: 90,
                isComposite: false
            )
        ]
    }()
}
