import SwiftUI
#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

struct QuizPlayCardBackground: View {
    var cornerRadius: CGFloat = 20

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(QuizTheme.cardFill)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
    }
}

struct QuizPlayProgressHeader: View {
    let currentIndex: Int
    let total: Int
    var accent: Color = QuizTheme.publishedGlow
    var showsNumericLabel: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if showsNumericLabel {
                Text("\(currentIndex + 1) / \(max(total, 1))")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(accent.opacity(0.9))
            }

            GeometryReader { geometry in
                let progress = CGFloat(currentIndex + 1) / CGFloat(max(total, 1))
                ZStack(alignment: .leading) {
                    Capsule(style: .continuous)
                        .fill(Color.white.opacity(0.12))
                    Capsule(style: .continuous)
                        .fill(accent)
                        .frame(width: max(geometry.size.width * min(max(progress, 0), 1), 0))
                        .shadow(color: accent.opacity(0.45), radius: 4, x: 0, y: 0)
                }
            }
            .frame(height: 4)
        }
    }
}

struct QuizPlayOptionRow: View {
    let letter: String
    let text: String
    let isSelected: Bool
    var accent: Color = QuizTheme.publishedGlow
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(letter)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(isSelected ? accent : accent.opacity(0.9))
                    .frame(width: 28, height: 28)
                    .overlay(
                        Circle()
                            .stroke(
                                isSelected ? accent : accent.opacity(0.55),
                                lineWidth: 1.4
                            )
                    )

                Text(text)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(isSelected ? .white : QuizTheme.mutedText)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(accent)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.black.opacity(0.28))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(
                        isSelected ? accent : Color.white.opacity(0.1),
                        lineWidth: isSelected ? 1.6 : 1
                    )
            )
            .shadow(
                color: isSelected ? accent.opacity(0.45) : .clear,
                radius: 10,
                x: 0,
                y: 0
            )
        }
        .buttonStyle(.plain)
    }
}

enum QuizPlayOptionLetter {
    static func letter(at index: Int) -> String {
        let base = Int(UnicodeScalar("A").value)
        guard let scalar = UnicodeScalar(base + index) else { return "?" }
        return String(scalar)
    }
}

struct QuizCodeSnippetView: View {
    let code: String
    var showsCopyButton: Bool = true

    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            if showsCopyButton {
                Button(action: copyCode) {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(QuizTheme.mutedText)
                        .padding(8)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Copy code")
            }

            Text(code)
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundStyle(Color.white.opacity(0.9))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
        }
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.black.opacity(0.45))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private func copyCode() {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(code, forType: .string)
        #elseif os(iOS)
        UIPasteboard.general.string = code
        #endif
    }
}

#Preview("Quiz play components") {
    ZStack {
        Color.black
        VStack(spacing: 16) {
            QuizPlayProgressHeader(currentIndex: 3, total: 12)
            QuizPlayOptionRow(letter: "A", text: "Sample answer", isSelected: true, action: {})
            QuizCodeSnippetView(code: "let x = 1\nprint(x)")
        }
        .padding()
    }
}
