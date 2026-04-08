import Foundation
import AuthenticationServices

protocol LoginViewModel: ObservableObject {
    var email: String { get set }
    var password: String { get set }

    func login()
    func signUp()
    func loginWithApple(result: Result<ASAuthorization, any Error>)
    func loginWithGoogle()
}

class LoginViewModelImpl: LoginViewModel {

    let coordinator: LoginCoordinator
    @Published var email: String = ""
    @Published var password: String = ""

    init (coordinator: LoginCoordinator) {
        self.coordinator = coordinator
    }

    func login() {

    }

    func signUp() {

    }

    func loginWithApple(result: Result<ASAuthorization, any Error>) {

    }

    func loginWithGoogle() {
        
    }
}
