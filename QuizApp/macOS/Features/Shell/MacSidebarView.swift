import SwiftUI

struct MacSidebarView: View {
    @Binding var selectedItem: MacSidebarItem
    let onSettingsTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: "sparkle")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(QuizTheme.publishedGlow)
                Text("QUIZ")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)
            .padding(.bottom, 24)

            ForEach(MacSidebarItem.allCases) { item in
                sidebarButton(item)
            }

            Spacer()

            Button(action: onSettingsTap) {
                Label("Settings", systemImage: "gearshape.fill")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(QuizTheme.mutedText)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 8)
            .padding(.bottom, 16)
        }
        .frame(minWidth: 210)
        .background(Color.black.opacity(0.25))
    }

    private func sidebarButton(_ item: MacSidebarItem) -> some View {
        let isSelected = selectedItem == item
        return Button {
            selectedItem = item
        } label: {
            HStack(spacing: 10) {
                Image(systemName: item.iconName)
                    .frame(width: 20)
                Text(item.title)
                    .font(.system(size: 14, weight: isSelected ? .semibold : .medium, design: .rounded))
                Spacer()
            }
            .foregroundStyle(isSelected ? QuizTheme.publishedGlow : QuizTheme.mutedText)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isSelected ? QuizTheme.publishedGlow.opacity(0.15) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(isSelected ? QuizTheme.publishedGlow.opacity(0.8) : Color.clear, lineWidth: 1.2)
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 10)
        .padding(.vertical, 2)
    }
}

#Preview {
    MacSidebarView(selectedItem: .constant(.myQuizzes), onSettingsTap: {})
        .frame(width: 220, height: 500)
        .background(Color.black)
}
