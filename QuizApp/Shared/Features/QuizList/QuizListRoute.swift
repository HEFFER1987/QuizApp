import SwiftUI
import SUICoordinator

enum QuizListRoute: RouteType {

    case main(viewModel: QuizListViewModelImpl)

    var presentationStyle: TransitionPresentationStyle {
        .push
    }

    @ViewBuilder
    var body: some View {
        switch self {
        case .main(let viewModel):
            QuizListView(viewModel: viewModel)
        }
    }
}
