import Foundation

enum QuizRepositoryError: Error {
    case loadFailed
}

protocol QuizRepository {
    func fetchQuizzes() async throws -> [Quiz]
}

struct QuizRepositoryMock: QuizRepository {
    func fetchQuizzes() async throws -> [Quiz] {
        let now = Date()
        let calendar = Calendar.current

        return [
            Quiz(
                id: "1",
                title: "Swift Basics",
                subtitle: nil,
                categoryLabel: "Programming • Swift",
                tags: ["Swift", "Programming"],
                difficulty: "Medium",
                questionCount: 12,
                status: .published,
                iconName: "chevron.left.forwardslash.chevron.right",
                updatedAt: calendar.date(byAdding: .hour, value: -2, to: now),
                attemptCount: 24,
                averageScorePercent: 82
            ),
            Quiz(
                id: "2",
                title: "World History",
                subtitle: nil,
                categoryLabel: "History • Ancient",
                tags: ["History"],
                difficulty: "Hard",
                questionCount: 20,
                status: .published,
                iconName: "globe.americas.fill",
                updatedAt: nil,
                attemptCount: 18,
                averageScorePercent: 75
            ),
            Quiz(
                id: "3",
                title: "Physics 101",
                subtitle: nil,
                categoryLabel: "Science • Physics",
                tags: ["Science", "Physics"],
                difficulty: "Medium",
                questionCount: 15,
                status: .draft,
                iconName: "atom",
                updatedAt: calendar.date(byAdding: .day, value: -1, to: now),
                attemptCount: nil,
                averageScorePercent: nil
            ),
            Quiz(
                id: "4",
                title: "English Grammar",
                subtitle: "Intermediate",
                categoryLabel: "Languages • English",
                tags: ["English"],
                difficulty: "Medium",
                questionCount: 12,
                status: .draft,
                iconName: "book.fill",
                updatedAt: calendar.date(byAdding: .hour, value: -2, to: now),
                attemptCount: nil,
                averageScorePercent: nil
            ),
            Quiz(
                id: "5",
                title: "JavaScript Essentials",
                subtitle: nil,
                categoryLabel: "Programming • JavaScript",
                tags: ["JavaScript"],
                difficulty: "Easy",
                questionCount: 18,
                status: .published,
                iconName: "curlybraces",
                updatedAt: nil,
                attemptCount: 32,
                averageScorePercent: 88
            ),
            Quiz(
                id: "6",
                title: "Art History",
                subtitle: nil,
                categoryLabel: "Art • Renaissance",
                tags: ["Art"],
                difficulty: "Hard",
                questionCount: 10,
                status: .draft,
                iconName: "paintpalette.fill",
                updatedAt: calendar.date(byAdding: .day, value: -3, to: now),
                attemptCount: nil,
                averageScorePercent: nil
            )
        ]
    }
}

struct QuizRepositoryLive: QuizRepository {
    private let fallback = QuizRepositoryMock()

    func fetchQuizzes() async throws -> [Quiz] {
        try await fallback.fetchQuizzes()
    }
}
