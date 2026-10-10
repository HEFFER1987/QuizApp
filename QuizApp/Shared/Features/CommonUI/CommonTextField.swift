import SwiftUI

struct CommonTextField: View {
    let placeholder: String
    @Binding var text: String
    var submitLabel: SubmitLabel = .done
    var showsValidationError: Bool = false

    var body: some View {
        TextField(placeholder, text: $text)
            .submitLabel(submitLabel)
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
