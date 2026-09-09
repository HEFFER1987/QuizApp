import SwiftUI
import SUICoordinator
import FirebaseCore

@main
struct QuizAppApp: App {
    @NSApplicationDelegateAdaptor(MacAppDelegate.self) var appDelegate

    let coordinator: Coordinator = LaunchCoordinatorImpl()

    var body: some Scene {
        WindowGroup {
            ZStack {
                MacSpaceBackgroundView()
                coordinator.getView()
            }
            .frame(minWidth: 1100, minHeight: 720)
        }

        Settings {
            MacSettingsView(viewModel: SettingsViewModelImpl())
        }
    }
}
