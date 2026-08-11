import SwiftUI

struct CommonSearchField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(QuizTheme.mutedText)
            TextField(placeholder, text: $text)
                .foregroundStyle(.white)
                .autocorrectionDisabled()
                #if os(iOS)
                .textInputAutocapitalization(.never)
                #endif
        }
        .padding(.horizontal, 16)
        .frame(height: 48)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(QuizTheme.cardFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(QuizTheme.searchGlow.opacity(0.85), lineWidth: 1)
        )
        .shadow(color: QuizTheme.searchGlow.opacity(0.35), radius: 8, x: 0, y: 0)
    }
}
