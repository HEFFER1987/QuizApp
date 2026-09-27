# Development Standards

Concise rules for AI agents and contributors working on QuizApp. Keep this file short — file-type-specific detail lives in `.cursor/rules/`.

## 1. Stack & Architecture
- Swift (latest), strict Swift Concurrency. SwiftUI over UIKit — only `import UIKit` when a task genuinely can't be done in SwiftUI (e.g. presenting a view controller for Sign in with Google/Apple).
- MVVM: `View` <-> `ViewModel` <-> services, wired through protocols (DI).
- Navigation uses the `SUICoordinator` package: each feature has a `<Name>Coordinator` protocol + `<Name>CoordinatorImpl : Coordinator<Route>` that builds its `View`/`ViewModel` and drives flow (see `SignUpCoordinator`). Don't introduce raw `NavigationStack`/`NavigationPath` navigation in coordinator-owned flows.
- Folder layout: cross-platform logic in `Shared/Features/<Feature>/` (`<Name>ViewModel`, coordinator protocols, repositories, shared UI). Platform-specific screens live in `QuizApp/iOS/Features/...` and `QuizApp/macOS/Features/...` (e.g. `LoginView` vs `MacLoginView`).
- No dead code: no unused imports, variables, functions, or types. Anything not used outside its file must be `private`/`fileprivate`. Code should stay clean under Periphery-style analysis.

## 2. Naming
- Types: `CamelCase`. Variables/functions: `lowerCamelCase`.
- View: `<Name>View`. ViewModel: `<Name>ViewModel` protocol + `<Name>ViewModelImpl` class. Coordinator: `<Name>Coordinator` protocol + `<Name>CoordinatorImpl` class.
- Errors: a dedicated `enum <Name>Error: Error` per feature/ViewModel, with one case per failure mode (see `SignUpError`).

## 3. Views
- Extract subviews as `private var subview: some View` or separate structs; keep `body` a thin composition — no business logic or heavy computation in it.
- Scope property wrappers to their real lifetime: `@State` (local), `@StateObject` (view-owned observable), `@ObservedObject` (injected observable), `@EnvironmentObject` (app-wide).
- Add a `#Preview` for new views.

## 4. ViewModels
- `final class`, `@MainActor`, conforms to `ObservableObject`; expose state via `@Published`. (This codebase uses `ObservableObject`, not the `@Observable` macro — stay consistent.)
- Depend on services/coordinators only through protocols, injected via the initializer — never instantiate concrete services inline. This is what makes mocking in tests possible.
- Mutate UI state only on the main thread.
- Use `guard` for early exits/validation instead of nested `if`.

## 5. Concurrency
- Use `async/await`, `Task`, `TaskGroup`, `Actor` — no completion-handler-based APIs.
- Check cancellation in long-running or loop-based work (`Task.isCancelled`, `try Task.checkCancellation()`).
- Capture `self` directly in a `Task` created and awaited in the same scope; use `[weak self]` only when the task can outlive its owner.
- Hop to `@MainActor` explicitly (`Task { @MainActor in ... }` or `await MainActor.run { ... }`) when mutating UI state from a non-isolated context.

## 6. Do
- Cover non-trivial business logic with unit tests using mock services (mock the DI protocols, not concrete types).
- Keep modules structured so they could be extracted into SPM packages later.

## 7. Don't
- No `fatalError()` or force unwraps (`!`, `as!`, `try!`) in production code.
- No `import UIKit` unless unavoidable.
- No unused declarations, parameters, or types left behind.
