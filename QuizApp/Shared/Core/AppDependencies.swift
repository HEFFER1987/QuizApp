import Foundation

enum AppDependencies {
    static let mockUserId = "mock-user"

    static func makeAuthManager() -> AuthManager {
        #if MOCK_DATA
        AuthManagerMock()
        #else
        AuthManagerImp()
        #endif
    }

    static func makeGoogleSignInProvider() -> GoogleSignInProviding {
        #if MOCK_DATA
        UnavailableGoogleSignInProvider()
        #else
        GoogleSignInProvider()
        #endif
    }

    static func makeQuizRepository() -> QuizRepository {
        QuizRepositoryMock()
    }

    static func makeProfileRepository() -> ProfileRepository {
        ProfileRepositoryMock()
    }

    static func makeResultsRepository() -> ResultsRepository {
        ResultsRepositoryMock()
    }

    static func makeExploreRepository() -> ExploreRepository {
        ExploreRepositoryMock()
    }

    static func makeQuizPlayRepository() -> QuizPlayRepository {
        QuizPlayRepositoryMock()
    }
}

struct UnavailableGoogleSignInProvider: GoogleSignInProviding {
    func signIn() async throws -> GoogleSignInTokens {
        throw GoogleSignInError.configurationMissing
    }
}
