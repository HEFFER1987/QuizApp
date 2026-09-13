import SwiftUI

struct LaunchView: View {

    @StateObject private var viewModel: LaunchViewModelImpl
    @ObservedObject private var appState = AppStateManager.shared

    init(coordinator: LaunchCoordinator) {
        _viewModel = StateObject(wrappedValue: LaunchViewModelImpl(coordinator: coordinator))
    }

    var body: some View {
        #if os(macOS)
        macBody
        #else
        iosBody
        #endif
    }

    #if os(macOS)
    private var macBody: some View {
        Group {
            if viewModel.macLaunchContent == .splash {
                splashContent
            } else {
                Color.clear
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    #endif

    private var iosBody: some View {
        ZStack {
            CommonBackgroundView()

            ProgressView()
                .progressViewStyle(.circular)
                .tint(.white)
                .controlSize(.large)
                .scaleEffect(1.6)

            Color.clear
                .contentShape(Rectangle())
                .ignoresSafeArea()
                .onTapGesture(count: 3) {
                    Task {
                        await viewModel.trippleTap()
                    }
                }
                .onAppear {
                    Task {
                        await viewModel.startTimer()
                    }
                }
        }
        .ignoresSafeArea()
    }

    private var splashContent: some View {
        ZStack {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(.white)
                .controlSize(.large)
                .scaleEffect(1.6)

            Color.clear
                .contentShape(Rectangle())
                .ignoresSafeArea()
                .onTapGesture(count: 3) {
                    Task {
                        await viewModel.trippleTap()
                    }
                }
                .onAppear {
                    Task {
                        await viewModel.startTimer()
                    }
                }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    LaunchView(coordinator: LaunchCoordinatorImpl())
}
