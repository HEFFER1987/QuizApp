import SwiftUI

struct CommonBackgroundView: View {
    var body: some View {
        GeometryReader { geometry in
            Image(asset: Asset.background)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .background(Color.white)
    }
}
