import Foundation

struct ExploreQuiz: Identifiable, Equatable {
    let id: String
    let title: String
    let categoryLabel: String
    let questionCount: Int
    let difficulty: String
    let rating: Double
    let attemptCount: Int
    let authorHandle: String
    let about: String
    let iconName: String
    let bestScorePercent: Int?
}

enum ExploreCategory: String, CaseIterable, Identifiable {
    case swift
    case history
    case science
    case english

    var id: String { rawValue }

    var title: String {
        switch self {
        case .swift: return "Swift"
        case .history: return "History"
        case .science: return "Science"
        case .english: return "English"
        }
    }
}
