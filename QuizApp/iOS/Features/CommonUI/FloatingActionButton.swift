import SwiftUI

struct FloatingActionButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(QuizTheme.cardFill)
                )
                .overlay(
                    Circle()
                        .stroke(QuizTheme.publishedGlow, lineWidth: 2)
                )
                .shadow(color: QuizTheme.publishedGlow.opacity(0.7), radius: 14, x: 0, y: 0)
                .shadow(color: QuizTheme.publishedGlow.opacity(0.35), radius: 6, x: 0, y: 0)
        }
        .buttonStyle(.plain)
    }
}
