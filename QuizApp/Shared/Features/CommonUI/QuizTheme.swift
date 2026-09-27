import SwiftUI

enum QuizTheme {
    static let draftGlow = Color(asset: Asset.QuizTheme.draftGlow)
    static let publishedGlow = Color(asset: Asset.QuizTheme.publishedGlow)
    static let searchGlow = Color(asset: Asset.QuizTheme.searchGlow)
    static let cardFill = Color(asset: Asset.QuizTheme.cardFill)
    static let mutedText = Color(asset: Asset.QuizTheme.mutedText)
    static let activeTab = Color(asset: Asset.QuizTheme.activeTab)
    static let excellentGlow = Color(asset: Asset.QuizTheme.excellentGlow)
    static let reviewGlow = Color(asset: Asset.QuizTheme.reviewGlow)

    static func glowColor(for status: QuizStatus) -> Color {
        switch status {
        case .draft:
            return draftGlow
        case .published:
            return publishedGlow
        }
    }

    static func glowColor(for iconGlow: ResultIconGlow) -> Color {
        switch iconGlow {
        case .blue:
            return publishedGlow
        case .orange:
            return draftGlow
        case .purple:
            return reviewGlow
        case .green:
            return excellentGlow
        }
    }

    static func scoreBadgeColor(for scorePercent: Int) -> Color {
        if scorePercent >= 90 {
            return excellentGlow
        }
        if scorePercent >= 80 {
            return publishedGlow
        }
        return draftGlow
    }
}
