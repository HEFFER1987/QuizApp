import Foundation
import AuthenticationServices

protocol SignUpViewModel: ObservableObject {
    var email: String { get set }
    var password: String { get set }
    var confirmPassword: String { get set }

    func signUp()
    func login() async
    func signUpWithApple(result: Result<ASAuthorization, any Error>)
    func signUpWithGoogle()
}

class SignUpViewModelImpl: SignUpViewModel {

    let coordinator: SignUpCoordinator
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""

    init (coordinator: SignUpCoordinator) {
        self.coordinator = coordinator
    }

    func signUp() {

    }

    @MainActor func login() async {
        await coordinator.moveBackToLogin()
    }

    func signUpWithApple(result: Result<ASAuthorization, any Error>) {

    }

    func signUpWithGoogle() {

    }
}
