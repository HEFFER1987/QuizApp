//
//  QuizAppApp.swift
//  QuizApp
//
//  Created by Roman Seredenko on 2/16/26.
//

import SwiftUI
import SUICoordinator
#if !MOCK_DATA
import FirebaseCore
#endif

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
    #if !MOCK_DATA
    FirebaseApp.configure()
    if let options = FirebaseApp.app()?.options {
        print("Firebase Project ID: \(options.projectID ?? "unknown")")
        print("Firebase Bundle ID: \(Bundle.main.bundleIdentifier ?? "unknown")")
    }
    #endif
    return true
  }
}

@main
struct QuizAppApp: App {

    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    let coordinator: Coordinator = LaunchCoordinatorImpl()

    var body: some Scene {
        WindowGroup {
            ZStack {
                CommonBackgroundView()

                coordinator.getView()
            }
        }
    }
}
