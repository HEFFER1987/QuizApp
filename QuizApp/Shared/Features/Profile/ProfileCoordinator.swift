import Foundation

protocol ProfileCoordinator {
    func openResult(_ result: QuizResult)
    func openSettings()
    func openEditProfile()
    func openAllAchievements()
}

final class ProfileCoordinatorImpl: ProfileCoordinator {

    private weak var mainTabCoordinator: MainTabCoordinatorImpl?

    init(mainTabCoordinator: MainTabCoordinatorImpl? = nil) {
        self.mainTabCoordinator = mainTabCoordinator
    }

    func openResult(_ result: QuizResult) {
        Task {
            await mainTabCoordinator?.showResultDetail(result)
        }
    }

    func openSettings() {
        Logger.shared.log("Profile settings tapped", level: .info)
    }

    func openEditProfile() {
        Logger.shared.log("Edit profile tapped", level: .info)
    }

    func openAllAchievements() {
        Logger.shared.log("See all achievements tapped", level: .info)
    }
}
