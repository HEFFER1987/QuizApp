import SwiftUI

struct ProfileContentTabs: View {
    @Binding var selectedTab: ProfileContentTab

    var body: some View {
        HStack(spacing: 18) {
            ForEach(ProfileContentTab.allCases, id: \.self) { tab in
                tabButton(for: tab)
            }
            Spacer(minLength: 0)
        }
    }

    private func tabButton(for tab: ProfileContentTab) -> some View {
        let isSelected = selectedTab == tab

        return Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 8) {
                Text(title(for: tab))
                    .font(.system(size: 13, weight: isSelected ? .bold : .medium, design: .rounded))
                    .foregroundStyle(isSelected ? QuizTheme.activeTab : QuizTheme.mutedText)

                Capsule()
                    .fill(isSelected ? QuizTheme.activeTab : Color.clear)
                    .frame(height: 3)
                    .shadow(color: isSelected ? QuizTheme.activeTab.opacity(0.6) : .clear, radius: 4)
            }
        }
        .buttonStyle(.plain)
    }

    private func title(for tab: ProfileContentTab) -> String {
        switch tab {
        case .myQuizzes:
            return Strings.Profile.Tab.myQuizzes
        case .favorites:
            return Strings.Profile.Tab.favorites
        case .history:
            return Strings.Profile.Tab.history
        }
    }
}
