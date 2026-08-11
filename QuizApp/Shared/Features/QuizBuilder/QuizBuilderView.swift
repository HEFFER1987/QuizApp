import SwiftUI

struct QuizBuilderView<ViewModel: QuizBuilderViewModel>: View {

    @StateObject private var viewModel: ViewModel

    init(viewModel: @autoclosure @escaping () -> ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        VStack {
            Text(Strings.QuizBuilder.title)
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ZStack {
        CommonBackgroundView()
        QuizBuilderView(viewModel: QuizBuilderViewModelImpl(coordinator: QuizBuilderCoordinatorImpl()))
    }
}
