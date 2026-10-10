import Foundation

enum AuthEmailValidationFailure: Equatable {
    case empty
    case invalidFormat
}

enum AuthPasswordValidationFailure: Equatable {
    case empty
    case tooShort(minLength: Int)
}

enum AuthConfirmPasswordValidationFailure: Equatable {
    case empty
    case mismatch
}

struct AuthFieldValidationMessages: Equatable {
    var email: String?
    var password: String?
    var confirmPassword: String?

    var isValid: Bool {
        email == nil && password == nil && confirmPassword == nil
    }
}

enum AuthCredentialsValidator {

    /// Firebase Auth minimum password length.
    static let minimumPasswordLength = 6

    private static let emailPattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#

    static func normalizedEmail(_ raw: String) -> String {
        raw.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func validateEmail(_ raw: String) -> AuthEmailValidationFailure? {
        let email = normalizedEmail(raw)
        if email.isEmpty {
            return .empty
        }
        if !isValidEmailFormat(email) {
            return .invalidFormat
        }
        return nil
    }

    static func isValidEmailFormat(_ email: String) -> Bool {
        email.range(of: emailPattern, options: .regularExpression) != nil
    }

    static func validatePasswordForLogin(_ password: String) -> AuthPasswordValidationFailure? {
        if password.isEmpty {
            return .empty
        }
        return nil
    }

    static func validatePasswordForSignUp(_ password: String) -> AuthPasswordValidationFailure? {
        if password.isEmpty {
            return .empty
        }
        if password.count < minimumPasswordLength {
            return .tooShort(minLength: minimumPasswordLength)
        }
        return nil
    }

    static func validateConfirmPassword(_ password: String, confirmPassword: String) -> AuthConfirmPasswordValidationFailure? {
        if confirmPassword.isEmpty {
            return .empty
        }
        if password != confirmPassword {
            return .mismatch
        }
        return nil
    }

    static func validateLogin(email: String, password: String) -> AuthFieldValidationMessages {
        var messages = AuthFieldValidationMessages()
        if let failure = validateEmail(email) {
            messages.email = localizedEmailMessage(failure)
        }
        if let failure = validatePasswordForLogin(password) {
            messages.password = localizedPasswordMessage(failure)
        }
        return messages
    }

    static func validateSignUp(
        email: String,
        password: String,
        confirmPassword: String
    ) -> AuthFieldValidationMessages {
        var messages = AuthFieldValidationMessages()
        if let failure = validateEmail(email) {
            messages.email = localizedEmailMessage(failure)
        }
        if let failure = validatePasswordForSignUp(password) {
            messages.password = localizedPasswordMessage(failure)
        } else if let failure = validateConfirmPassword(password, confirmPassword: confirmPassword) {
            messages.confirmPassword = localizedConfirmPasswordMessage(failure)
        }
        return messages
    }

    static func loginError(email: String, password: String) -> LoginError? {
        if let emailFailure = validateEmail(email) {
            switch emailFailure {
            case .empty: return .emailEmpty
            case .invalidFormat: return .emailInvalid
            }
        }
        if let passwordFailure = validatePasswordForLogin(password) {
            switch passwordFailure {
            case .empty: return .passwordEmpty
            case .tooShort: return nil
            }
        }
        return nil
    }

    static func signUpError(email: String, password: String, confirmPassword: String) -> SignUpError? {
        if let emailFailure = validateEmail(email) {
            switch emailFailure {
            case .empty: return .emailEmpty
            case .invalidFormat: return .emailInvalid
            }
        }
        if let passwordFailure = validatePasswordForSignUp(password) {
            switch passwordFailure {
            case .empty: return .passwordEmpty
            case .tooShort: return .passwordTooShort
            }
        }
        if let confirmFailure = validateConfirmPassword(password, confirmPassword: confirmPassword) {
            switch confirmFailure {
            case .empty: return .confirmPasswordEmpty
            case .mismatch: return .passwordMismatch
            }
        }
        return nil
    }

    static func localizedEmailMessage(_ failure: AuthEmailValidationFailure) -> String {
        switch failure {
        case .empty:
            return Strings.Auth.Validation.Email.empty
        case .invalidFormat:
            return Strings.Auth.Validation.Email.invalid
        }
    }

    static func localizedPasswordMessage(_ failure: AuthPasswordValidationFailure) -> String {
        switch failure {
        case .empty:
            return Strings.Auth.Validation.Password.empty
        case .tooShort(let minLength):
            return Strings.Auth.Validation.Password.tooShort(minLength)
        }
    }

    static func localizedConfirmPasswordMessage(_ failure: AuthConfirmPasswordValidationFailure) -> String {
        switch failure {
        case .empty:
            return Strings.Auth.Validation.ConfirmPassword.empty
        case .mismatch:
            return Strings.Auth.Validation.Password.mismatch
        }
    }
}
