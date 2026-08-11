import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import AuthenticationServices
import CryptoKit

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
                    submitLabel: .go
                )
                .focused($focusedField, equals: .password)
                .onSubmit { viewModel.login() }
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

// MARK: - Apple login string extension
extension String {
    static func randomNonceString(length: Int = 32) -> String {
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = String()
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    Logger.shared.log(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)",
                        level: .error
                    )
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    // Make sha256 internal (default) so other files in the module can call it.
    func sha256() -> String {
        let inputData = Data(self.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()

        return hashString
    }
}

#Preview {
    LoginView(viewModel: LoginViewModelImpl(coordinator: LoginCoordinatorImpl()))
}
