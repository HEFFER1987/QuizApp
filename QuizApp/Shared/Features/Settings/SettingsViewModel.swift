import Foundation

enum AppAppearance: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }
}

enum AppLanguage: String, CaseIterable, Identifiable {
    case english
    case ukrainian
    case russian

    var id: String { rawValue }
}

struct SettingsSnapshot: Equatable {
    var appearance: AppAppearance
    var language: AppLanguage
    var notificationsEnabled: Bool
    var soundsEnabled: Bool
    var animationsEnabled: Bool
    var defaultQuestionType: QuizBuilderQuestionType
    var defaultTimeLimitMinutes: Int
    var defaultDifficulty: String
    var defaultPassingScore: Int
    var profileVisibility: Bool
    var resultsVisibility: Bool
    var activityVisibility: Bool
}

protocol SettingsRepository {
    func load() -> SettingsSnapshot
    func save(_ snapshot: SettingsSnapshot)
}

struct SettingsRepositoryUserDefaults: SettingsRepository {
    private let defaults: UserDefaults
    private let key = "settings.snapshot"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> SettingsSnapshot {
        guard
            let data = defaults.data(forKey: key),
            let snapshot = try? JSONDecoder().decode(SettingsSnapshot.self, from: data)
        else {
            return SettingsSnapshot(
                appearance: .system,
                language: .english,
                notificationsEnabled: true,
                soundsEnabled: true,
                animationsEnabled: true,
                defaultQuestionType: .singleChoice,
                defaultTimeLimitMinutes: 0,
                defaultDifficulty: "Medium",
                defaultPassingScore: 70,
                profileVisibility: true,
                resultsVisibility: true,
                activityVisibility: true
            )
        }
        return snapshot
    }

    func save(_ snapshot: SettingsSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults.set(data, forKey: key)
    }
}

extension SettingsSnapshot: Codable {}
extension AppAppearance: Codable {}
extension AppLanguage: Codable {}

struct SettingsRepositoryLive: SettingsRepository {
    private let storage = SettingsRepositoryUserDefaults()

    func load() -> SettingsSnapshot { storage.load() }
    func save(_ snapshot: SettingsSnapshot) { storage.save(snapshot) }
}

@MainActor
protocol SettingsViewModel: ObservableObject {
    var snapshot: SettingsSnapshot { get set }

    func save()
    func signOut()
}

@MainActor
final class SettingsViewModelImpl: SettingsViewModel {
    private let repository: SettingsRepository

    @Published var snapshot: SettingsSnapshot

    init(repository: SettingsRepository = SettingsRepositoryUserDefaults()) {
        self.repository = repository
        self.snapshot = repository.load()
    }

    func save() {
        repository.save(snapshot)
    }

    func signOut() {
        AppStateManager.shared.setUnauthorized(reason: .signedOut)
    }
}
