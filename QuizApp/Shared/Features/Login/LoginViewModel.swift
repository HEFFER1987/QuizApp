import Foundation

protocol LoginViewModel: ObservableObject {
    func login() 
}

class LoginViewModelImpl: LoginViewModel {

    let coordinator: LoginCoordinator

    init (coordinator: LoginCoordinator) {
        self.coordinator = coordinator
    }

    func login() {
        
    }
}
