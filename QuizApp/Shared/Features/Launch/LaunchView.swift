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

            CometSpinnerView()
                .frame(width: 134, height: 134)

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
            CometSpinnerView()
                .frame(width: 134, height: 134)

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
