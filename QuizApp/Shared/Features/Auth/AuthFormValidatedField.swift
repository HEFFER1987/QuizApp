import SwiftUI

struct AuthFormValidatedField<Content: View>: View {
    let validationMessage: String?
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            content()
            if let validationMessage {
                Text(validationMessage)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.red.opacity(0.95))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
