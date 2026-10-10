import Testing
@testable import QuizApp_iOS

struct AuthCredentialsValidatorTests {

    @Test func normalizedEmailTrimsWhitespace() {
        #expect(AuthCredentialsValidator.normalizedEmail("  user@example.com  ") == "user@example.com")
    }

    @Test func acceptsValidEmails() {
        #expect(AuthCredentialsValidator.validateEmail("user@example.com") == nil)
        #expect(AuthCredentialsValidator.validateEmail("name.last+tag@mail.co.uk") == nil)
    }

    @Test func rejectsInvalidEmails() {
        #expect(AuthCredentialsValidator.validateEmail("") == .empty)
        #expect(AuthCredentialsValidator.validateEmail("   ") == .empty)
        #expect(AuthCredentialsValidator.validateEmail("not-an-email") == .invalidFormat)
        #expect(AuthCredentialsValidator.validateEmail("missing@domain") == .invalidFormat)
    }

    @Test func signUpPasswordRequiresMinimumLength() {
        #expect(AuthCredentialsValidator.validatePasswordForSignUp("12345") == .tooShort(minLength: 6))
        #expect(AuthCredentialsValidator.validatePasswordForSignUp("123456") == nil)
    }

    @Test func confirmPasswordMustMatch() {
        #expect(
            AuthCredentialsValidator.validateConfirmPassword("secret1", confirmPassword: "secret2")
            == .mismatch
        )
        #expect(
            AuthCredentialsValidator.validateConfirmPassword("secret1", confirmPassword: "secret1")
            == nil
        )
    }
}
