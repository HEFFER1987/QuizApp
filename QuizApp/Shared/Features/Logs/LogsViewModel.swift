import Foundation

protocol LogsViewModel: ObservableObject {
    
}

class LogsViewModelImpl: LogsViewModel {

    let coordinator: LogsCoordinator

    init (coordinator: LogsCoordinator) {
        self.coordinator = coordinator
    }

}