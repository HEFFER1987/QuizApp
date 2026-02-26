import SwiftUI

struct LaunchView<ViewModel: LaunchViewModel>: View {

    @StateObject private var viewModel: ViewModel

    init(viewModel: @autoclosure @escaping () -> ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            ProgressView()
                .progressViewStyle(.circular)

            Color.clear
                .contentShape(Rectangle())
                .ignoresSafeArea()
                .onTapGesture(count: 3) {
                    Task {
                        await viewModel.trippleTap()
                    }
                }
        }
    }
}