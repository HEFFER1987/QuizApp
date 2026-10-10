import Foundation

final class MacQuizListCoordinatorImpl: QuizListCoordinator {
    private weak var macRootCoordinator: MacRootCoordinator?

    init(macRootCoordinator: MacRootCoordinator? = nil) {
        self.macRootCoordinator = macRootCoordinator
    }

    func showQuizBuilder() async {
        await macRootCoordinator?.showQuizBuilder()
    }

    func playQuiz(_ quiz: Quiz) async {
        await macRootCoordinator?.showQuizPlay(quizID: quiz.id)
    }
}

final class MacResultsCoordinatorImpl: ResultsCoordinator {
    private weak var macRootCoordinator: MacRootCoordinator?

    init(macRootCoordinator: MacRootCoordinator? = nil) {
        self.macRootCoordinator = macRootCoordinator
    }

    func openResult(_ result: QuizResult) {
        Task {
            await macRootCoordinator?.showResultDetail(result)
        }
    }
}

final class MacProfileCoordinatorImpl: ProfileCoordinator {
    private weak var macRootCoordinator: MacRootCoordinator?

    init(macRootCoordinator: MacRootCoordinator? = nil) {
        self.macRootCoordinator = macRootCoordinator
    }

    func openResult(_ result: QuizResult) {
        Task {
            await macRootCoordinator?.showResultDetail(result)
        }
    }

    func openSettings() {
        Task {
            await macRootCoordinator?.showSettings()
        }
    }

    func openEditProfile() {
        Task {
            await macRootCoordinator?.showSettings()
        }
    }

    func openAllAchievements() {
        Task {
            await macRootCoordinator?.showAchievements()
        }
    }

    func openRegistration() {}
}

final class MacQuizBuilderCoordinatorImpl: QuizBuilderCoordinator {
    private weak var macRootCoordinator: MacRootCoordinator?

    init(macRootCoordinator: MacRootCoordinator? = nil) {
        self.macRootCoordinator = macRootCoordinator
    }

    func dismiss() async {
        await macRootCoordinator?.dismissEditor()
    }
}

final class MacResultDetailCoordinatorImpl: ResultDetailCoordinator {
    private let resultId: String
    private weak var macRootCoordinator: MacRootCoordinator?

    init(resultId: String, macRootCoordinator: MacRootCoordinator? = nil) {
        self.resultId = resultId
        self.macRootCoordinator = macRootCoordinator
    }

    func dismiss() async {
        await macRootCoordinator?.dismissEditor()
    }

    func retakeQuiz(title: String) async {
        await macRootCoordinator?.showQuizPlay(quizID: resultId)
    }
}

final class MacQuizPlayCoordinatorImpl: QuizPlayCoordinator {
    private weak var macRootCoordinator: MacRootCoordinator?

    init(macRootCoordinator: MacRootCoordinator? = nil) {
        self.macRootCoordinator = macRootCoordinator
    }

    func showSessionResult(_ result: QuizPlaySessionResult) async {
        await macRootCoordinator?.dismissQuizPlay()
        await macRootCoordinator?.showResultDetail(
            QuizResult(
                id: result.sessionID,
                quizTitle: result.quizTitle,
                iconName: result.iconName,
                iconGlow: .blue,
                completedAt: Date(),
                correctCount: result.correctCount,
                totalCount: result.totalCount,
                durationSeconds: result.durationSeconds,
                xpEarned: result.xpEarned,
                scorePercent: result.scorePercent,
                isComposite: false
            )
        )
    }

    func dismiss() async {
        await macRootCoordinator?.dismissQuizPlay()
    }
}

final class ExploreCoordinatorImpl: ExploreCoordinator {
    private weak var macRootCoordinator: MacRootCoordinator?

    init(macRootCoordinator: MacRootCoordinator? = nil) {
        self.macRootCoordinator = macRootCoordinator
    }

    func showPublicQuizDetail(quizID: String) async {
        await macRootCoordinator?.showPublicQuizDetail(quizID: quizID)
    }

    func startQuiz(quizID: String) async {
        await macRootCoordinator?.showQuizPlay(quizID: quizID)
    }
}
