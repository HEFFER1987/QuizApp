import SwiftUI

enum MainTabItem: CaseIterable, Equatable {
    case quizzes
    case explore
    case results
    case profile

    var iconName: String {
        switch self {
        case .quizzes:
            return "folder.fill"
        case .explore:
            return "safari"
        case .results:
            return "chart.bar.fill"
        case .profile:
            return "person.fill"
        }
    }

    var title: String {
        switch self {
        case .quizzes:
            return Strings.MainTab.quizzes
        case .explore:
            return Strings.MainTab.explore
        case .results:
            return Strings.MainTab.results
        case .profile:
            return Strings.MainTab.profile
        }
    }
}

struct MainTabBar: View {
    @Binding var selectedTab: MainTabItem

    var body: some View {
        HStack {
            ForEach(MainTabItem.allCases, id: \.self) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(
            Color("tabBarFill")
                .ignoresSafeArea(edges: .bottom)
        )
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 1)
        }
    }

    private func tabButton(for tab: MainTabItem) -> some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.iconName)
                    .font(.system(size: 20, weight: .semibold))
                Text(tab.title)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
            }
            .foregroundStyle(selectedTab == tab ? QuizTheme.activeTab : QuizTheme.mutedText)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}
