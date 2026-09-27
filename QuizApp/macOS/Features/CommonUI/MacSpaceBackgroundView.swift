import SwiftUI

struct MacSpaceBackgroundView: View {
    var body: some View {
        ZStack {
            Color.black

            Image(asset: Asset.background)
                .resizable()
                .scaledToFill()
                .opacity(0.55)

            LinearGradient(
                colors: [
                    Color.black.opacity(0.35),
                    Color(red: 0.02, green: 0.08, blue: 0.22).opacity(0.65),
                    Color.black.opacity(0.85)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            QuizTheme.publishedGlow.opacity(0.35),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 220
                    )
                )
                .frame(width: 440, height: 440)
                .blur(radius: 40)
                .offset(x: -280, y: 320)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    MacSpaceBackgroundView()
        .frame(width: 1200, height: 800)
}
