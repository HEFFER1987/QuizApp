import SwiftUI

struct LaunchView<ViewModel: LaunchViewModel>: View {

    @StateObject private var viewModel: ViewModel

    init(viewModel: @autoclosure @escaping () -> ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        ZStack {

            CommonBackgroundView()

            ProgressView()
                .progressViewStyle(.circular)
                .tint(.white)
                .controlSize(.large)
                .scaleEffect(1.6)

            Color.clear
                .contentShape(Rectangle())
                .ignoresSafeArea()
                .onTapGesture(count: 3) {
                    Task {
                        await viewModel.trippleTap()
                    }
                }
             .onAppear(perform: {
                 Task {
                     await viewModel.startTimer()
                 }
              })
        }
        .ignoresSafeArea()
    }
}

#Preview {
    LaunchView(viewModel: LaunchViewModelImpl(coordinator: LaunchCoordinatorImpl()))
}
