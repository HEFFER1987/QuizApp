import SwiftUI

enum QuizTheme {
    static let draftGlow = Color(asset: Asset.QuizTheme.draftGlow)
    static let publishedGlow = Color(asset: Asset.QuizTheme.publishedGlow)
    static let searchGlow = Color(asset: Asset.QuizTheme.searchGlow)
    static let cardFill = Color(asset: Asset.QuizTheme.cardFill)
    static let mutedText = Color(asset: Asset.QuizTheme.mutedText)
    static let tabBarFill = Color(asset: Asset.QuizTheme.tabBarFill)
    static let activeTab = Color(asset: Asset.QuizTheme.activeTab)

    static func glowColor(for status: QuizStatus) -> Color {
        switch status {
        case .draft:
            return draftGlow
        case .published:
            return publishedGlow
        }
    }
}
