import SwiftUI

struct LogsView<ViewModel: LogsViewModel>: View {

    @StateObject private var viewModel: ViewModel

    init(viewModel: @autoclosure @escaping () -> ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        ZStack {
            Color.red
            Text("Logs view")
        }
    }
}