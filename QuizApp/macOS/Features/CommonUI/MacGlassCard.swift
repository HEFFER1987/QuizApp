import SwiftUI

struct MacGlassCard<Content: View>: View {
    var cornerRadius: CGFloat = 16
    var glowColor: Color = QuizTheme.publishedGlow
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(QuizTheme.cardFill.opacity(0.85))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: glowColor.opacity(0.15), radius: 12, x: 0, y: 4)
    }
}

#Preview {
    ZStack {
        MacSpaceBackgroundView()
        MacGlassCard {
            Text("Glass Card")
                .foregroundStyle(.white)
        }
        .padding()
    }
    .frame(width: 320, height: 200)
}
