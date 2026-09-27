import SwiftUI

struct GoogleButton: View {
    // Customization parameters
    let title: String
    var height: CGFloat = 50
    var cornerRadius: CGFloat = 12
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Google logo
                Image(Asset.Login.loginGoogle.name) // Make sure the icon is added to Assets
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)

                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black.opacity(0.54))
            }
            .frame(maxWidth: .infinity) // Stretch to full width
            .frame(height: height)      // Custom height
            .background(Color.white)
            .cornerRadius(cornerRadius) // Custom corner radius
            // Add a subtle shadow and border, per Google styling
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.gray.opacity(0.35), lineWidth: 0.5)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
}
