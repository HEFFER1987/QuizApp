import SwiftUI
import AuthenticationServices

private enum MacSignUpField: Hashable {
    case email
    case password
    case confirmPassword
}

struct MacSignUpView: View {

    @StateObject private var viewModel: SignUpViewModelImpl
    @FocusState private var focusedField: MacSignUpField?
    @State private var isPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    @State private var currentNonce: String?

    init(viewModel: @autoclosure @escaping () -> SignUpViewModelImpl) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                MacAuthHeaderBar()

                signUpForm
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

    private var signUpForm: some View {
        VStack(spacing: 16) {
            MacAuthCenterLogo()

            MacAuthCreateTitle()

            Text(Strings.Signup.Create.subtitle)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(QuizTheme.mutedText)
                .multilineTextAlignment(.center)
                .padding(.bottom, 8)

            if let error = viewModel.error {
                MacAuthFormErrorBanner(message: error.userMessage)
            }

            VStack(spacing: 14) {
                MacGlassTextField(
                    placeholder: Strings.Common.Email.placeholder,
                    systemImage: "envelope",
                    text: $viewModel.email,
                    submitLabel: .next
                ) {
                    focusedField = .password
                }
                .focused($focusedField, equals: .email)

                MacGlassPasswordField(
                    placeholder: Strings.Common.Password.placeholder,
                    text: $viewModel.password,
                    isVisible: $isPasswordVisible,
                    submitLabel: .next
                ) {
                    focusedField = .confirmPassword
                }
                .focused($focusedField, equals: .password)

                MacGlassPasswordField(
                    placeholder: Strings.Signup.Confirm.Password.placeholder,
                    text: $viewModel.confirmPassword,
                    isVisible: $isConfirmPasswordVisible,
                    submitLabel: .go
                ) {
                    viewModel.signUp()
                }
                .focused($focusedField, equals: .confirmPassword)
            }

            MacNeonPrimaryButton(
                title: Strings.Common.Action.signup,
                isDisabled: viewModel.isLoading
            ) {
                viewModel.signUp()
            }
            .padding(.top, 4)

            MacAuthDivider(label: Strings.Signup.continueWith)

            MacAuthOutlineButton(
                title: Strings.Signup.Google.button,
                icon: .google
            ) {
                viewModel.signUpWithGoogle()
            }
            .disabled(viewModel.isLoading)

            appleSignUpButton

            loginLink
                .padding(.top, 8)
        }
    }

    private var loginLink: some View {
        HStack(spacing: 4) {
            Text(Strings.Signup.Action.alreadyHaveAccount)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(QuizTheme.mutedText)

            Button(action: viewModel.login) {
                Text(Strings.Signup.Action.login)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(QuizTheme.searchGlow)
            }
            .buttonStyle(.plain)
        }
    }

    private var appleSignUpButton: some View {
        ZStack {
            MacAuthOutlineButton(
                title: Strings.Signup.Apple.button,
                icon: .apple
            ) {}

            SignInWithAppleButton(.signUp) { request in
                let nonce = String.randomNonceString()
                currentNonce = nonce
                request.requestedScopes = [.fullName, .email]
                request.nonce = nonce.sha256()
            } onCompletion: { result in
                viewModel.signUpWithApple(result: result, rawNonce: currentNonce)
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
        MacSignUpView(viewModel: SignUpViewModelImpl(coordinator: SignUpCoordinatorImpl()))
    }
    .frame(width: 1100, height: 720)
}
