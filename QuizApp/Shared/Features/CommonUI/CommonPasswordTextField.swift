import SwiftUI

struct CommonPasswordField: View {
    let placeholder: String
    @Binding var text: String
    @Binding var isVisible: Bool
    var submitLabel: SubmitLabel = .done
    var showsValidationError: Bool = false

    var body: some View {
        HStack(spacing: 10) {
            Group {
                if isVisible {
                    TextField(placeholder, text: $text)
                } else {
                    SecureField(placeholder, text: $text)
                }
            }
            .submitLabel(submitLabel)

            Button {
                isVisible.toggle()
            } label: {
                Image(systemName: isVisible ? "eye.slash" : "eye")
                    .foregroundStyle(.black.opacity(0.55))
                    .frame(width: 30, height: 30)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isVisible ? Text(Strings.Login.Password.hide) : Text(Strings.Login.Password.show))
        }
        .padding(.horizontal, 14)
        .frame(height: 52)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.white.opacity(0.92))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(
                    showsValidationError ? Color.red.opacity(0.75) : .black.opacity(0.06),
                    lineWidth: showsValidationError ? 1.5 : 1
                )
        )
        .shadow(color: .black.opacity(0.22), radius: 10, x: 0, y: 8)
    }
}
