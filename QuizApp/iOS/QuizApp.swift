//
//  QuizAppApp.swift
//  QuizApp
//
//  Created by Roman Seredenko on 2/16/26.
//

import SwiftUI
import SUICoordinator

@main
struct QuizAppApp: App {

    let coordinator: Coordinator = LaunchCoordinatorImpl()

    var body: some Scene {
        WindowGroup {
            coordinator.getView()
        }
    }
}
