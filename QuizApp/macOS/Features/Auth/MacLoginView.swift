import SwiftUI
import AuthenticationServices

private enum MacLoginField: Hashable {
    case email
    case password
}

struct MacLoginView: View {

    @StateObject private var viewModel: LoginViewModelImpl
    @FocusState private var focusedField: MacLoginField?
    @State private var isPasswordVisible = false
    @State private var currentNonce: String?

    init(viewModel: @autoclosure @escaping () -> LoginViewModelImpl) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                MacAuthHeaderBar()

                loginForm
                    .frame(maxWidth: 420)
                    .padding(.horizontal, 32)
                    .padding(.top, 28)

                Spacer(minLength: 0)
            }
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
            .background {
                MacAuthDecorationsView()
            }
        }
    }

    private var loginForm: some View {
        VStack(spacing: 16) {
            MacAuthCenterLogo()

            MacAuthWelcomeTitle()

            Text(Strings.Login.Welcome.subtitle)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(QuizTheme.mutedText)
                .multilineTextAlignment(.center)
                .padding(.bottom, 8)

            if let error = viewModel.error {
                MacAuthFormErrorBanner(message: error.userMessage)
            }

            VStack(spacing: 14) {
                AuthFormValidatedField(validationMessage: viewModel.emailValidationMessage) {
                    MacGlassTextField(
                        placeholder: Strings.Common.Email.placeholder,
                        systemImage: "envelope",
                        text: $viewModel.email,
                        submitLabel: .next,
                        showsValidationError: viewModel.emailValidationMessage != nil
                    ) {
                        focusedField = .password
                    }
                    .focused($focusedField, equals: .email)
                    .onChange(of: viewModel.email) { _, _ in
                        viewModel.clearEmailValidation()
                    }
                }

                AuthFormValidatedField(validationMessage: viewModel.passwordValidationMessage) {
                    MacGlassPasswordField(
                        placeholder: Strings.Common.Password.placeholder,
                        text: $viewModel.password,
                        isVisible: $isPasswordVisible,
                        submitLabel: .go,
                        showsValidationError: viewModel.passwordValidationMessage != nil
                    ) {
                        viewModel.login()
                    }
                    .focused($focusedField, equals: .password)
                    .onChange(of: viewModel.password) { _, _ in
                        viewModel.clearPasswordValidation()
                    }
                }
            }

            MacNeonPrimaryButton(
                title: Strings.Login.Action.login,
                isDisabled: viewModel.isLoading
            ) {
                viewModel.login()
            }
            .padding(.top, 4)

            MacAuthDivider()

            MacAuthOutlineButton(
                title: Strings.Login.Google.button,
                icon: .google
            ) {
                viewModel.loginWithGoogle()
            }
            .disabled(viewModel.isLoading)

            appleSignInButton

            Button(action: viewModel.signUp) {
                Text(Strings.Common.Action.signup)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(QuizTheme.searchGlow)
            }
            .buttonStyle(.plain)
            .padding(.top, 8)
        }
    }

    private var appleSignInButton: some View {
        ZStack {
            MacAuthOutlineButton(
                title: Strings.Login.Apple.button,
                icon: .apple
            ) {}

            SignInWithAppleButton(.signIn) { request in
                let nonce = String.randomNonceString()
                currentNonce = nonce
                request.requestedScopes = [.fullName, .email]
                request.nonce = nonce.sha256()
            } onCompletion: { result in
                viewModel.loginWithApple(result: result, rawNonce: currentNonce)
            }
            .signInWithAppleButtonStyle(.white)
            .opacity(0.015)
            .frame(height: 48)
            .disabled(viewModel.isLoading)
        }
    }
}

#Preview {
    ZStack {
        MacSpaceBackgroundView()
        MacLoginView(viewModel: LoginViewModelImpl(coordinator: LoginCoordinatorImpl()))
    }
    .frame(width: 1100, height: 720)
}
