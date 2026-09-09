import Foundation
import SUICoordinator

protocol SignUpCoordinator {
    func moveBackToLogin() async
    func showMainApp() async
}

class SignUpCoordinatorImpl: Coordinator<DefaultRoute>, SignUpCoordinator {

    override func start() async {
        let viewModel = SignUpViewModelImpl(coordinator: self)

        let route = DefaultRoute(presentationStyle: .push, content: {
            SignUpView(viewModel: viewModel)
        })

        await startFlow(route: route)
    }

    func moveBackToLogin() async {
        await finishFlow(animated: true)
    }

    func showMainApp() async {
        // Present from Login so MainTab covers the whole auth stack,
        // not from SignUp (a non-fullscreen push overlay).
        if let loginCoordinator = parent as? LoginCoordinatorImpl {
            await loginCoordinator.showMainApp()
            return
        }

        #if os(macOS)
        await navigate(
            to: MacRootCoordinatorImpl(),
            presentationStyle: .platformModalFlow
        )
        #else
        await navigate(
            to: MainTabCoordinatorImpl(),
            presentationStyle: .platformModalFlow
        )
        #endif
    }
}
