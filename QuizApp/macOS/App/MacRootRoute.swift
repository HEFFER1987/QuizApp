import SwiftUI
import SUICoordinator

enum MacRootRoute: RouteType {
    case main(coordinator: MacRootCoordinatorImpl)

    var presentationStyle: TransitionPresentationStyle {
        .platformRootFlow
    }

    @ViewBuilder
    var body: some View {
        switch self {
        case .main(let coordinator):
            MacRootSplitView(viewModel: coordinator.makeRootViewModel())
        }
    }
}
