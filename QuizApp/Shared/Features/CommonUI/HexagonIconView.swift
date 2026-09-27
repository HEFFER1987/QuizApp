import SwiftUI

struct HexagonShape: Shape {
    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        let insetX = width * 0.18

        var path = Path()
        path.move(to: CGPoint(x: width / 2, y: 0))
        path.addLine(to: CGPoint(x: width - insetX, y: height * 0.22))
        path.addLine(to: CGPoint(x: width - insetX, y: height * 0.78))
        path.addLine(to: CGPoint(x: width / 2, y: height))
        path.addLine(to: CGPoint(x: insetX, y: height * 0.78))
        path.addLine(to: CGPoint(x: insetX, y: height * 0.22))
        path.closeSubpath()
        return path
    }
}

struct HexagonIconView: View {
    let systemName: String
    let glowColor: Color
    var size: CGFloat = 44
    var iconSize: CGFloat = 18

    var body: some View {
        ZStack {
            HexagonShape()
                .fill(glowColor.opacity(0.14))
                .frame(width: size, height: size)

            HexagonShape()
                .stroke(glowColor.opacity(0.9), lineWidth: 1.4)
                .frame(width: size, height: size)
                .shadow(color: glowColor.opacity(0.55), radius: 8, x: 0, y: 0)

            Image(systemName: systemName)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundStyle(glowColor)
                .shadow(color: glowColor.opacity(0.55), radius: 4, x: 0, y: 0)
        }
        .frame(width: size, height: size)
    }
}
