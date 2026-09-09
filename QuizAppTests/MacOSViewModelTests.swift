import XCTest
@testable import QuizApp_iOS

final class MacOSViewModelTests: XCTestCase {
    @MainActor
    func testExploreViewModelFiltersByCategory() async {
        let viewModel = ExploreViewModelImpl(coordinator: ExploreCoordinatorStub())
        await viewModel.load()
        viewModel.selectedCategory = .swift
        XCTAssertFalse(viewModel.filteredQuizzes.isEmpty)
        XCTAssertTrue(viewModel.filteredQuizzes.allSatisfy {
            $0.categoryLabel.lowercased().contains("swift")
        })
    }

    @MainActor
    func testQuizPlayViewModelScoresSession() async {
        let viewModel = QuizPlayViewModelImpl(quizID: "1", coordinator: QuizPlayCoordinatorStub())
        await viewModel.load()
        guard let first = viewModel.currentQuestion else {
            XCTFail("Expected question")
            return
        }
        for optionID in first.correctOptionIDs {
            viewModel.selectOption(optionID)
        }
        viewModel.confirmAnswer()
        if viewModel.currentQuestion != nil {
            viewModel.confirmAnswer()
        }
        viewModel.finishSession()
        XCTAssertTrue(viewModel.isComplete)
        XCTAssertNotNil(viewModel.sessionResult)
    }

    @MainActor
    func testQuizPublishViewModelCreatesLink() {
        let viewModel = QuizPublishViewModelImpl()
        viewModel.publish(title: "Swift Basics")
        XCTAssertEqual(viewModel.publishedInfo?.title, "Swift Basics")
        XCTAssertFalse(viewModel.publishedInfo?.link.isEmpty ?? true)
    }

    @MainActor
    func testSettingsViewModelPersistsSnapshot() {
        let repository = SettingsRepositoryUserDefaults(defaults: UserDefaults(suiteName: "MacOSViewModelTests")!)
        var snapshot = repository.load()
        snapshot.notificationsEnabled = false
        repository.save(snapshot)
        XCTAssertFalse(repository.load().notificationsEnabled)
    }

    @MainActor
    func testQuizListViewModelCounts() async {
        let viewModel = QuizListViewModelImpl(coordinator: QuizListCoordinatorStub())
        await viewModel.loadQuizzes()
        XCTAssertEqual(viewModel.allCount, viewModel.quizzes.count)
        XCTAssertGreaterThanOrEqual(viewModel.allCount, viewModel.draftCount)
        XCTAssertGreaterThanOrEqual(viewModel.allCount, viewModel.publishedCount)
    }
}

private final class ExploreCoordinatorStub: ExploreCoordinator {
    func showPublicQuizDetail(quizID: String) async {}
    func startQuiz(quizID: String) async {}
}

private final class QuizPlayCoordinatorStub: QuizPlayCoordinator {
    func showSessionResult(_ result: QuizPlaySessionResult) async {}
    func dismiss() async {}
}

private final class QuizListCoordinatorStub: QuizListCoordinator {
    func showQuizBuilder() async {}
    func playQuiz(_ quiz: Quiz) async {}
}
