import Foundation

protocol SignUpViewModel: ObservableObject {

}

class SignUpViewModelImpl: SignUpViewModel {

    let coordinator: SignUpCoordinator
    @Published var email: String = ""
    @Published var password: String = ""

    init (coordinator: SignUpCoordinator) {
        self.coordinator = coordinator
    }
}
