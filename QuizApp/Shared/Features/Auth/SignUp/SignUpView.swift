import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import AuthenticationServices

struct SignUpView<ViewModel: SignUpViewModel>: View {

    @StateObject private var viewModel: ViewModel
    @FocusState private var focusedField: Field?
    @State private var isPasswordVisible: Bool = false
    @State private var isConfirmPasswordVisible: Bool = false
    // Unhashed nonce.
    @State private var currentNonce: String?
    @State private var contentHeight: CGFloat = 0
    @State private var containerHeight: CGFloat = 0

    init(viewModel: @autoclosure @escaping () -> ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        CenterScrollView {
            Text(Strings.Signup.Create.title)
                .font(.system(size: 34, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.35), radius: 10, x: 0, y: 6)
                .padding(.bottom, 12)

            VStack(spacing: 14) {
                CommonTextField(
                    placeholder: Strings.Common.Email.placeholder,
                    text: $viewModel.email,
                    submitLabel: .next
                )
                #if os(iOS)
                .textInputAutocapitalization(.never)
                #endif
                .autocorrectionDisabled()
                .focused($focusedField, equals: .email)
                .onSubmit { focusedField = .password }

                CommonPasswordField(
                    placeholder: Strings.Common.Password.placeholder,
                    text: $viewModel.password,
                    isVisible: $isPasswordVisible,
                    submitLabel: .next
                )
                .focused($focusedField, equals: .password)
                .onSubmit { focusedField = .confirmPassword }

                CommonPasswordField(
                    placeholder: Strings.Signup.Confirm.Password.placeholder,
                    text: $viewModel.confirmPassword,
                    isVisible: $isConfirmPasswordVisible,
                    submitLabel: .go
                )
                .focused($focusedField, equals: .confirmPassword)
                .onSubmit { viewModel.signUp() }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)

            VStack(spacing: 12) {
                CommonButton(
                    title: Strings.Common.Action.signup,
                    background: Color(red: 0.29, green: 0.39, blue: 0.92),
                    foreground: .white
                ) {
                    viewModel.signUp()
                }

                GoogleButton(title: Strings.Signup.Google.button) {
                    viewModel.signUpWithGoogle()
                }

                SignInWithAppleButton(.signUp) { request in
                    let nonce = String.randomNonceString()
                    currentNonce = nonce
                    request.requestedScopes = [.fullName, .email]
                    request.nonce = nonce.sha256()
                } onCompletion: { result in
                    viewModel.signUpWithApple(result: result)
                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 50)
                .cornerRadius(12)

                Spacer(minLength: 0)
                    .frame(height: 20)

                CommonButton(
                    title: Strings.Signup.Action.back,
                    background: .black,
                    foreground: .white
                ) {
                    viewModel.login()
                }
            }
            .padding(.horizontal, 20)
        }
    }

}

private enum Field: Hashable {
    case email
    case password
    case confirmPassword
}

private struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private struct HeightReader: View {
    var body: some View {
        GeometryReader { proxy in
            Color.clear
                .preference(key: ViewHeightKey.self, value: proxy.size.height)
        }
    }
}

#Preview {
    SignUpView(viewModel: SignUpViewModelImpl(coordinator: SignUpCoordinatorImpl()))
}
