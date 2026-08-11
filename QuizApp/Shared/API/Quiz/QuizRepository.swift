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
                title: "English Grammar",
                subtitle: "Intermediate",
                questionCount: 12,
                status: .draft,
                iconName: "book.fill",
                updatedAt: calendar.date(byAdding: .hour, value: -2, to: now),
                attemptCount: nil,
                averageScorePercent: nil
            ),
            Quiz(
                id: "2",
                title: "World History",
                subtitle: nil,
                questionCount: 20,
                status: .published,
                iconName: "globe.americas.fill",
                updatedAt: nil,
                attemptCount: 24,
                averageScorePercent: 82
            ),
            Quiz(
                id: "3",
                title: "Swift Basics",
                subtitle: nil,
                questionCount: 15,
                status: .draft,
                iconName: "chevron.left.forwardslash.chevron.right",
                updatedAt: calendar.date(byAdding: .day, value: -1, to: now),
                attemptCount: nil,
                averageScorePercent: nil
            )
        ]
    }
}
