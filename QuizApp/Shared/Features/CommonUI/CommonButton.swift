import SwiftUI

struct CommonButton: View {
    let title: String
    let background: Color
    let foreground: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(foreground)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(background)
                )
        }
        .buttonStyle(.plain)
        .shadow(color: .black.opacity(0.18), radius: 12, x: 0, y: 10)
    }
}