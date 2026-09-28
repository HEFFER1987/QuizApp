import SwiftUI

enum MacSidebarItem: String, CaseIterable, Identifiable, Hashable {
    case myQuizzes
    case explore
    case results
    case profile

    var id: String { rawValue }

    var title: String {
        switch self {
        case .myQuizzes: return Strings.MainTab.quizzes
        case .explore: return Strings.MainTab.explore
        case .results: return Strings.MainTab.results
        case .profile: return Strings.MainTab.profile
        }
    }

    var iconName: String {
        switch self {
        case .myQuizzes: return "folder.fill"
        case .explore: return "safari"
        case .results: return "chart.bar.fill"
        case .profile: return "person.fill"
        }
    }
}

enum MacInspectorMode: Equatable {
    case profile
    case question
}

enum MacContentDestination: Equatable, Hashable {
    case sidebar(MacSidebarItem)
    case quizEditor
    case resultDetail(String)
    case quizPlay(String)
    case publicQuizDetail(String)
    case achievements
    case quizPublishedSuccess
}
