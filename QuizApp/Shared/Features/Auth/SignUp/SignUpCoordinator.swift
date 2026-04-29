import Foundation
import SUICoordinator

protocol SignUpCoordinator {
    func moveBackToLogin() async
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

    func singup() async {
        
    }
}
