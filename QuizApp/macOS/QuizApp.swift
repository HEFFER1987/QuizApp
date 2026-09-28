import SwiftUI
import SUICoordinator
#if !MOCK_DATA
import FirebaseCore
#endif

@main
struct QuizAppApp: App {
    @NSApplicationDelegateAdaptor(MacAppDelegate.self) var appDelegate
    @ObservedObject private var launchUI = MacLaunchUIState.shared

    let coordinator: Coordinator = LaunchCoordinatorImpl()

    var body: some Scene {
        WindowGroup {
            GeometryReader { window in
                ZStack {
                    MacSpaceBackgroundView()
                        .frame(width: window.size.width, height: window.size.height)

                    if let mainCoordinator = launchUI.mainCoordinator {
                        MacRootSplitView(viewModel: mainCoordinator.makeRootViewModel())
                            .frame(width: window.size.width, height: window.size.height)
                    } else if let authScreen = launchUI.authScreen {
                        authView(for: authScreen)
                            .frame(width: window.size.width, height: window.size.height, alignment: .top)
                    } else {
                        coordinator.getView()
                            .frame(width: window.size.width, height: window.size.height)
                    }
                }
                .frame(width: window.size.width, height: window.size.height)
            }
            .frame(minWidth: 1100, minHeight: 720)
        }
        .defaultSize(width: 1100, height: 720)

        Settings {
            MacSettingsView(viewModel: SettingsViewModelImpl())
        }
    }

    @ViewBuilder
    private func authView(for authScreen: MacLaunchUIState.AuthScreen) -> some View {
        switch authScreen {
        case .login(let loginCoordinator):
            MacLoginView(viewModel: LoginViewModelImpl(coordinator: loginCoordinator))
        case .signup(let signUpCoordinator):
            MacSignUpView(viewModel: SignUpViewModelImpl(coordinator: signUpCoordinator))
        }
    }
}
