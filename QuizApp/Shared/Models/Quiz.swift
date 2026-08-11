import Foundation

enum QuizStatus: String, Codable, CaseIterable {
    case draft
    case published
}

enum QuizListFilter: CaseIterable, Equatable {
    case all
    case drafts
    case published
}

struct Quiz: Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String?
    let questionCount: Int
    let status: QuizStatus
    let iconName: String
    let updatedAt: Date?
    let attemptCount: Int?
    let averageScorePercent: Int?
}

extension Quiz {
    var matchesDraftFilter: Bool {
        status == .draft
    }

    var matchesPublishedFilter: Bool {
        status == .published
    }

    func matchesSearch(_ query: String) -> Bool {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return true }
        let lowercasedQuery = trimmed.lowercased()
        if title.lowercased().contains(lowercasedQuery) { return true }
        if let subtitle, subtitle.lowercased().contains(lowercasedQuery) { return true }
        return false
    }
}
