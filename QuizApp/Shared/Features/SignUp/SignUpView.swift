import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import AuthenticationServices

private enum Field: Hashable {
    case email
    case password
    case confirmPassword
}

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
        NavigationStack {
            ZStack {
                CommonBackgroundView()

                GeometryReader { proxy in
                    let availableHeight = proxy.size.height
                    let shouldScroll = contentHeight > (availableHeight + 1)

                    ScrollView {
                        VStack(spacing: 16) {
                            if !shouldScroll { Spacer(minLength: 0) }

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
                                    placeholder: "Confirm password",
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
                                    title: "Sign up",
                                    background: Color(red: 0.29, green: 0.39, blue: 0.92),
                                    foreground: .white
                                ) {
                                    viewModel.signUp()
                                }

                                CommonButton(
                                    title: "Already have an account? Log in",
                                    background: .black,
                                    foreground: .white
                                ) {
                                    viewModel.login()
                                }

                                GoogleButton(title: "Sign up with Google") {
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
                            }
                            .padding(.horizontal, 20)

                            if !shouldScroll { Spacer(minLength: 0) }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: availableHeight)
                        .background(
                            HeightReader()
                        )
                    }
                    .scrollDisabled(!shouldScroll)
                    .scrollIndicators(.hidden)
                    .onPreferenceChange(ViewHeightKey.self) { newValue in
                        contentHeight = newValue
                        containerHeight = availableHeight
                    }
                }
            }
            #if os(iOS)
            .toolbar(.hidden, for: .navigationBar)
            #endif
        }
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
    SignUpView(viewModel: SignUpViewModelImpl(coordinator: SignUpCoordinatorImpl()))
}
