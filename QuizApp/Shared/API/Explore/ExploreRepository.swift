import Foundation

enum ExploreRepositoryError: Error {
    case loadFailed
}

protocol ExploreRepository {
    func fetchPopularQuizzes() async throws -> [ExploreQuiz]
    func fetchQuiz(id: String) async throws -> ExploreQuiz
}

struct ExploreRepositoryMock: ExploreRepository {
    private let quizzes: [ExploreQuiz] = [
        ExploreQuiz(
            id: "explore-1",
            title: "Swift Basics",
            categoryLabel: "Programming • Swift",
            questionCount: 12,
            difficulty: "Medium",
            rating: 4.5,
            attemptCount: 1200,
            authorHandle: "@swiftmaster",
            about: "Learn the fundamentals of Swift.",
            iconName: "chevron.left.forwardslash.chevron.right",
            bestScorePercent: 92
        ),
        ExploreQuiz(
            id: "explore-2",
            title: "World History",
            categoryLabel: "History",
            questionCount: 20,
            difficulty: "Hard",
            rating: 5.0,
            attemptCount: 840,
            authorHandle: "@historian",
            about: "Journey through world history.",
            iconName: "globe.americas.fill",
            bestScorePercent: 88
        ),
        ExploreQuiz(
            id: "explore-3",
            title: "English Grammar",
            categoryLabel: "Languages • English",
            questionCount: 15,
            difficulty: "Medium",
            rating: 4.2,
            attemptCount: 2100,
            authorHandle: "@englishpro",
            about: "Master English grammar rules.",
            iconName: "book.fill",
            bestScorePercent: 76
        )
    ]

    func fetchPopularQuizzes() async throws -> [ExploreQuiz] {
        quizzes
    }

    func fetchQuiz(id: String) async throws -> ExploreQuiz {
        guard let quiz = quizzes.first(where: { $0.id == id }) else {
            throw ExploreRepositoryError.loadFailed
        }
        return quiz
    }
}

struct ExploreRepositoryLive: ExploreRepository {
    private let fallback = ExploreRepositoryMock()

    func fetchPopularQuizzes() async throws -> [ExploreQuiz] {
        try await fallback.fetchPopularQuizzes()
    }

    func fetchQuiz(id: String) async throws -> ExploreQuiz {
        try await fallback.fetchQuiz(id: id)
    }
}
