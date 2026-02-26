import SwiftUI

struct LoginView<ViewModel: LoginViewModel>: View {

    @StateObject private var viewModel: ViewModel
    
    init(viewModel: @autoclosure @escaping () -> ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        NavigationStack {
            List {
                Button("Login") {
                    viewModel.login()
                }
            }
            .navigationTitle("Login View")
        }
    }
}