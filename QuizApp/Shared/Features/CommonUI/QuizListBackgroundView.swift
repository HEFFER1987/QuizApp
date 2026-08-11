import SwiftUI

struct QuizListBackgroundView: View {
    var body: some View {
        GeometryReader { geometry in
            Image(asset: Asset.quizListBackground)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
                .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .background(Color.black)
    }
}

#Preview {
    QuizListBackgroundView()
}
