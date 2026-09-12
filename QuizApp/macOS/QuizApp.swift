import SwiftUI
import SUICoordinator
import FirebaseCore

@main
struct QuizAppApp: App {
    @NSApplicationDelegateAdaptor(MacAppDelegate.self) var appDelegate
    @ObservedObject private var launchUI = MacLaunchUIState.shared

    let coordinator: Coordinator = LaunchCoordinatorImpl()

    var body: some Scene {
        WindowGroup {
            GeometryReader { window in
                ZStack(alignment: .topLeading) {
                    MacSpaceBackgroundView()
                        .frame(width: window.size.width, height: window.size.height)

                    coordinator.getView()
                        .frame(width: window.size.width, height: window.size.height)

                    if let loginCoordinator = launchUI.loginCoordinator {
                        MacLoginView(viewModel: LoginViewModelImpl(coordinator: loginCoordinator))
                            .frame(width: window.size.width, height: window.size.height, alignment: .top)
                            .zIndex(1)
                    }
                }
                .frame(width: window.size.width, height: window.size.height, alignment: .topLeading)
                .clipped()
            }
            .frame(minWidth: 1100, minHeight: 720)
        }
        .defaultSize(width: 1100, height: 720)

        Settings {
            MacSettingsView(viewModel: SettingsViewModelImpl())
        }
    }
}
