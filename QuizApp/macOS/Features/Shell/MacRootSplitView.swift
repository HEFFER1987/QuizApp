import SwiftUI

struct MacRootSplitView: View {
    @ObservedObject var viewModel: MacRootViewModel

    var body: some View {
        NavigationSplitView {
            MacSidebarView(
                selectedItem: Binding(
                    get: { viewModel.selectedSidebarItem },
                    set: { viewModel.selectSidebar($0) }
                ),
                onSettingsTap: viewModel.openSettings
            )
            .navigationSplitViewColumnWidth(min: 210, ideal: 230, max: 260)
        } content: {
            contentColumn
                .navigationSplitViewColumnWidth(min: 480, ideal: 620, max: 900)
        } detail: {
            inspectorColumn
                .navigationSplitViewColumnWidth(min: 280, ideal: 320, max: 360)
        }
        .background(MacSpaceBackgroundView())
        .sheet(isPresented: $viewModel.showQuizDetailsPanel) {
            MacQuizDetailsPanel(viewModel: viewModel.quizBuilderViewModel)
        }
        .sheet(isPresented: $viewModel.showPublishPanel) {
            MacQuizPublishView(
                builderViewModel: viewModel.quizBuilderViewModel,
                publishViewModel: viewModel.quizPublishViewModel,
                onPublished: {
                    viewModel.contentDestination = .quizPublishedSuccess
                    viewModel.showPublishPanel = false
                }
            )
        }
        .sheet(isPresented: $viewModel.showPreviewWindow) {
            QuizBuilderPreviewView(viewModel: viewModel.quizBuilderViewModel)
                .frame(minWidth: 700, minHeight: 600)
        }
        .onChange(of: viewModel.selectedSidebarItem) { _, item in
            viewModel.contentDestination = .sidebar(item)
        }
    }

    @ViewBuilder
    private var contentColumn: some View {
        switch viewModel.contentDestination {
        case .sidebar(let item):
            sidebarContent(item)
        case .quizEditor:
            MacQuizEditorView(
                viewModel: viewModel.quizBuilderViewModel,
                publishViewModel: viewModel.quizPublishViewModel,
                onPreview: { viewModel.showPreviewWindow = true },
                onPublish: { viewModel.showPublishPanel = true },
                onDetails: { viewModel.showQuizDetailsPanel = true },
                onClose: {
                    Task { await viewModel.coordinator?.dismissEditor() }
                }
            )
        case .resultDetail(let id):
            MacResultDetailSplitView(viewModel: viewModel.makeResultDetailViewModel(resultID: id))
        case .quizPlay(let id):
            MacQuizPlayView(viewModel: viewModel.makeQuizPlayViewModel(quizID: id))
        case .publicQuizDetail(let id):
            MacPublicQuizDetailView(
                quizID: id,
                exploreViewModel: viewModel.exploreViewModel,
                onStart: {
                    Task { await viewModel.coordinator?.showQuizPlay(quizID: id) }
                }
            )
        case .achievements:
            MacAchievementsView(viewModel: viewModel.profileViewModel)
        case .quizPublishedSuccess:
            MacQuizPublishedSuccessView(
                publishViewModel: viewModel.quizPublishViewModel,
                onClose: {
                    viewModel.contentDestination = .sidebar(.myQuizzes)
                }
            )
        }
    }

    @ViewBuilder
    private func sidebarContent(_ item: MacSidebarItem) -> some View {
        switch item {
        case .myQuizzes:
            MacMyQuizzesContentView(
                viewModel: viewModel.quizListViewModel,
                isOffline: viewModel.isOffline
            )
        case .explore:
            MacExploreView(viewModel: viewModel.exploreViewModel)
        case .results:
            MacResultsView(viewModel: viewModel.resultsViewModel)
        case .profile:
            MacProfileView(viewModel: viewModel.profileViewModel)
        }
    }

    @ViewBuilder
    private var inspectorColumn: some View {
        switch viewModel.inspectorMode {
        case .profile:
            MacProfileInspectorView(viewModel: viewModel.profileViewModel)
        case .question:
            MacQuestionInspectorView(viewModel: viewModel.quizBuilderViewModel)
        }
    }
}

#Preview {
    MacRootSplitView(viewModel: MacRootViewModel(coordinator: nil))
        .frame(width: 1200, height: 760)
}
