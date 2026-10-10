import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import AuthenticationServices

private enum Field: Hashable {
    case email
    case password
}

struct LoginView<ViewModel: LoginViewModel>: View {

    @StateObject private var viewModel: ViewModel
    @FocusState private var focusedField: Field?
    @State private var isPasswordVisible: Bool = false
    // Unhashed nonce.
    @State private var currentNonce: String?
    @State private var contentHeight: CGFloat = 0
    @State private var containerHeight: CGFloat = 0

    init(viewModel: @autoclosure @escaping () -> ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        CenterScrollView {
            Text(Strings.Login.Welcome.title)
                .font(.system(size: 34, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.35), radius: 10, x: 0, y: 6)
                .padding(.bottom, 12)

            if let error = viewModel.error {
                AuthFormErrorBanner(message: error.userMessage)
                    .padding(.bottom, 4)
            }

            VStack(spacing: 14) {
                AuthFormValidatedField(validationMessage: viewModel.emailValidationMessage) {
                    CommonTextField(
                        placeholder: Strings.Common.Email.placeholder,
                        text: $viewModel.email,
                        submitLabel: .next,
                        showsValidationError: viewModel.emailValidationMessage != nil
                    )
                    #if os(iOS)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    #endif
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .email)
                    .onSubmit { focusedField = .password }
                    .onChange(of: viewModel.email) { _, _ in
                        viewModel.clearEmailValidation()
                    }
                }

                AuthFormValidatedField(validationMessage: viewModel.passwordValidationMessage) {
                    CommonPasswordField(
                        placeholder: Strings.Common.Password.placeholder,
                        text: $viewModel.password,
                        isVisible: $isPasswordVisible,
                        submitLabel: .go,
                        showsValidationError: viewModel.passwordValidationMessage != nil
                    )
                    .focused($focusedField, equals: .password)
                    .onSubmit { viewModel.login() }
                    .onChange(of: viewModel.password) { _, _ in
                        viewModel.clearPasswordValidation()
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)

            VStack(spacing: 12) {
                CommonButton(
                    title: Strings.Login.Action.login,
                    background: Color(red: 0.29, green: 0.39, blue: 0.92),
                    foreground: .white
                ) {
                    viewModel.login()
                }
                .disabled(viewModel.isLoading)
                .opacity(viewModel.isLoading ? 0.6 : 1)

                GoogleButton(title: Strings.Login.Google.button) {
                    viewModel.loginWithGoogle()
                }

                SignInWithAppleButton(.signIn) { request in
                    let nonce = String.randomNonceString()
                    currentNonce = nonce
                    request.requestedScopes = [.fullName, .email]
                    request.nonce = nonce.sha256()
                } onCompletion: { result in
                    viewModel.loginWithApple(result: result, rawNonce: currentNonce)
                }
                // Styles: .black, .white, .whiteOutline
                .signInWithAppleButtonStyle(.black)
                .frame(height: 50) // Height customization
                .cornerRadius(12) // Corner radius customization

                Spacer(minLength: 0)
                    .frame(height: 20)

                CommonButton(
                    title: Strings.Common.Action.signup,
                    background: .black,
                    foreground: .white
                ) {
                    viewModel.signUp()
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

private struct AuthFormErrorBanner: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.red.opacity(0.85))
            )
            .padding(.horizontal, 20)
    }
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
    LoginView(viewModel: LoginViewModelImpl(coordinator: LoginCoordinatorImpl()))
}
