import SwiftUI

struct SignUpView<ViewModel: SignUpViewModel>: View {
    
    @StateObject private var viewModel: ViewModel
    @FocusState private var focusedField: Field?
    @State private var isPasswordVisible: Bool = false

    init(viewModel: @autoclosure @escaping () -> ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        NavigationStack {
            ZStack {
                CommonBackgroundView()

                ScrollView {
                    VStack(spacing: 16) {

                    }
                }
            }
        }
    }

}

private enum Field: Hashable {
    case email 
    case password
    case confirmPassword
}