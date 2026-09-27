import SwiftUI

struct MacSettingsView<ViewModel: SettingsViewModel>: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        TabView {
            generalTab
                .tabItem { Label("General", systemImage: "gearshape") }
            accountTab
                .tabItem { Label("Account", systemImage: "person.crop.circle") }
            quizTab
                .tabItem { Label("Quiz", systemImage: "list.bullet.rectangle") }
            privacyTab
                .tabItem { Label("Privacy", systemImage: "hand.raised") }
        }
        .padding(20)
        .frame(minWidth: 520, minHeight: 420)
        .onDisappear { viewModel.save() }
    }

    private var generalTab: some View {
        Form {
            Picker("Appearance", selection: $viewModel.snapshot.appearance) {
                ForEach(AppAppearance.allCases) { appearance in
                    Text(appearance.rawValue.capitalized).tag(appearance)
                }
            }
            Picker("Language", selection: $viewModel.snapshot.language) {
                ForEach(AppLanguage.allCases) { language in
                    Text(language.rawValue.capitalized).tag(language)
                }
            }
            Toggle("Notifications", isOn: $viewModel.snapshot.notificationsEnabled)
            Toggle("Sounds", isOn: $viewModel.snapshot.soundsEnabled)
            Toggle("Animation", isOn: $viewModel.snapshot.animationsEnabled)
        }
    }

    private var accountTab: some View {
        Form {
            Text("Avatar, username, email, and password settings")
            Button("Sign Out", role: .destructive, action: viewModel.signOut)
        }
    }

    private var quizTab: some View {
        Form {
            Picker("Default question type", selection: $viewModel.snapshot.defaultQuestionType) {
                ForEach(QuizBuilderQuestionType.allCases) { type in
                    Text(type.title).tag(type)
                }
            }
            Stepper("Default time limit: \(viewModel.snapshot.defaultTimeLimitMinutes) min",
                    value: $viewModel.snapshot.defaultTimeLimitMinutes, in: 0...180)
            TextField("Default difficulty", text: $viewModel.snapshot.defaultDifficulty)
            Stepper("Default passing score: \(viewModel.snapshot.defaultPassingScore)%",
                    value: $viewModel.snapshot.defaultPassingScore, in: 0...100)
        }
    }

    private var privacyTab: some View {
        Form {
            Toggle("Profile visibility", isOn: $viewModel.snapshot.profileVisibility)
            Toggle("Results visibility", isOn: $viewModel.snapshot.resultsVisibility)
            Toggle("Activity visibility", isOn: $viewModel.snapshot.activityVisibility)
        }
    }
}

#Preview {
    MacSettingsView(viewModel: SettingsViewModelImpl())
}
