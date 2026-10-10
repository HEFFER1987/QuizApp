import Foundation

enum QuizPublishAccess: String, CaseIterable, Identifiable {
    case `public`
    case link
    case privateAccess

    var id: String { rawValue }
}

struct QuizPublishSettings: Equatable {
    var shuffleQuestions: Bool = true
    var shuffleAnswers: Bool = true
    var timeLimitMinutes: Int = 0
    var showCorrectAnswers: Bool = true
    var allowRetry: Bool = true
    var passingScorePercent: Int = 70
    var access: QuizPublishAccess = .public
    var uniqueLink: String = ""
}

struct QuizPublishedInfo: Equatable {
    let title: String
    let link: String
}

@MainActor
protocol QuizPublishViewModel: ObservableObject {
    var settings: QuizPublishSettings { get set }
    var publishedInfo: QuizPublishedInfo? { get set }
    var isPublishing: Bool { get }

    func publish(title: String)
    func copyLink()
}

@MainActor
final class QuizPublishViewModelImpl: QuizPublishViewModel {
    @Published var settings = QuizPublishSettings()
    @Published var publishedInfo: QuizPublishedInfo?
    @Published private(set) var isPublishing: Bool = false

    func publish(title: String) {
        guard AppStateManager.shared.canPublishContent else { return }
        isPublishing = true
        defer { isPublishing = false }
        let slug = title
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .filter { $0.isLetter || $0.isNumber || $0 == "-" }
        let link = settings.uniqueLink.isEmpty
            ? "https://quiz.app/\(slug.isEmpty ? "quiz" : slug)"
            : settings.uniqueLink
        publishedInfo = QuizPublishedInfo(title: title, link: link)
    }

    func copyLink() {
        guard let link = publishedInfo?.link else { return }
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(link, forType: .string)
        #endif
    }
}

#if os(macOS)
import AppKit
#endif
