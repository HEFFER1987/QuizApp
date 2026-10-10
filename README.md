# QuizApp

Cross-platform SwiftUI quiz app for education and fun. Built with MVVM, coordinator-based navigation, Firebase Auth, and Google Sign-In.

**Platforms:** iOS (26+), macOS (14+), visionOS (1+)

## Features

- Auth (email/password, Google Sign-In) via Firebase
- Launch flow and app state management
- Quiz list and quiz builder
- In-app logs viewer
- Shared SwiftUI UI kit (`CommonUI`)

## Architecture

- **MVVM** — `View` ↔ `ViewModel` ↔ services, wired through protocols (DI)
- **Navigation** — [SUICoordinator](https://github.com/felilo/SUICoordinator); each feature owns a coordinator + route
- **Layout** — `QuizApp/Shared/Features/<Feature>/{View, ViewModel, Coordinator, Route}`
- **Concurrency** — `async/await`, `@MainActor` ViewModels

Contributor standards live in [`AGENT.md`](./AGENT.md).

## Requirements

- Xcode (matching deployment targets above)
- [Homebrew](https://brew.sh)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)
- [SwiftGen](https://github.com/SwiftGen/SwiftGen)
- [SwiftLint](https://github.com/realm/SwiftLint) (optional locally; runs as a pre-build script)

```bash
brew install xcodegen swiftgen swiftlint
```

## Getting started

1. Clone the repo and install the tools above.
2. Place Firebase config plists in `FirebaseConfigs/`:
   - `GoogleService-Info-Dev.plist` (Debug)
   - `GoogleService-Info-Prod.plist` (Release)
3. Generate the Xcode project (also runs SwiftGen):

```bash
./generate.sh
```

4. Open `QuizApp.xcodeproj` and run the `QuizApp-iOS` (or macOS) scheme.

Re-run `./generate.sh` after changing `project.yml` or assets that SwiftGen tracks.

## Mock build (no Firebase)

For local UI work without Firebase config or network auth, use the **Debug-Mock** configuration (`MOCK_DATA` compile flag):

1. Run `./generate.sh` after pulling changes to `project.yml`.
2. **VS Code / SweetPad:** in [`.vscode/settings.json`](.vscode/settings.json) set `"quizApp.buildProfile": "mock"` (profiles live in `quizApp.buildProfiles`). Build & Run or the debug launch configs sync scheme/configuration automatically.
3. **Xcode:** select **`QuizApp-iOS-Mock`** or **`QuizApp-macOS-Mock`**, then run — Firebase is not configured, quiz/profile data comes from `*RepositoryMock`, and auth uses `AuthManagerMock`.

On first launch without a saved session, the app auto-signs in as `mock-user`. **Sign Out** in Settings shows Login; email/password sign-in uses mock auth. Google/Apple sign-in is unavailable in this build.

Firebase plists under `FirebaseConfigs/` are **not** required for Mock schemes (the copy script is skipped).

## Project structure

```
QuizApp/
├── QuizApp/
│   ├── iOS/                 # iOS app entry
│   ├── macOS/               # macOS app entry
│   ├── Shared/
│   │   ├── Features/        # Auth, Launch, Logs, QuizList, QuizBuilder, CommonUI
│   │   ├── API/             # Auth managers & providers
│   │   ├── Core/            # App state, logger
│   │   └── Resources/
│   └── Swiftgen+Generated/  # Generated assets/strings
├── FirebaseConfigs/         # Dev/Prod GoogleService-Info plists
├── QuizAppTests/
├── QuizAppUITests/
├── project.yml              # XcodeGen project definition
├── swiftgen.yml
└── generate.sh
```

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| [SUICoordinator](https://github.com/felilo/SUICoordinator) | ≥ 1.0.0 | Coordinator navigation |
| [Firebase iOS SDK](https://github.com/firebase/firebase-ios-sdk) | ≥ 12.10.0 | Core + Auth |
| [Google Sign-In](https://github.com/google/GoogleSignIn-iOS) | ≥ 8.0.0 | Google authentication |

Declared in `project.yml` and resolved by SPM when the project is generated.

## Tooling

| Tool | Role |
|------|------|
| [XcodeGen](https://github.com/yonaskolb/XcodeGen) | Generates `.xcodeproj` from `project.yml` |
| [SwiftGen](https://github.com/SwiftGen/SwiftGen) | Type-safe access to assets/strings |
| [SwiftLint](https://github.com/realm/SwiftLint) | Lint on build |
| [xcdiff](https://github.com/bloomberg/xcdiff) | Diff Xcode project changes |

Build scripts (SwiftGen, SwiftLint, Firebase plist copy) are configured per target in `project.yml`. Debug builds copy `GoogleService-Info-Dev.plist`; Release copies the Prod variant.

## Testing

```bash
# From Xcode: Product → Test, or:
xcodebuild test -scheme QuizApp-iOS -destination 'platform=iOS Simulator,name=iPhone 16'
```

Unit tests live in `QuizAppTests/`; UI tests in `QuizAppUITests/`. Prefer mocking DI protocols rather than concrete services.

## License

Private / unlicensed unless otherwise specified.
