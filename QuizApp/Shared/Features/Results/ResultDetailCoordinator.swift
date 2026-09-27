import SwiftUI
import SUICoordinator

protocol ResultDetailCoordinator {
    func dismiss() async
    func retakeQuiz(title: String) async
}

final class ResultDetailCoordinatorImpl: Coordinator<DefaultRoute>, ResultDetailCoordinator {

    private let resultId: String

    init(resultId: String) {
        self.resultId = resultId
        super.init()
    }

    override func start() async {
        let viewModel = ResultDetailViewModelImpl(
            resultId: resultId,
            coordinator: self
        )
        let route = DefaultRoute(presentationStyle: .push, content: {
            ResultDetailView(viewModel: viewModel)
        })
        await startFlow(route: route)
    }

    func dismiss() async {
        await finishFlow(animated: true)
    }

    func retakeQuiz(title: String) async {
        Logger.shared.log("Retake quiz tapped: \(title)", level: .info)
    }
}
