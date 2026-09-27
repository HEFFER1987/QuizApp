import SwiftUI

struct CenterScrollView<Content: View>: View {

    let content: Content

    @State private var contentHeight: CGFloat = 0
    @State private var containerHeight: CGFloat = 0

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        NavigationStack {
            ZStack {
                CommonBackgroundView().onViewDidLoad()

                GeometryReader { proxy in
                    let availableHeight = proxy.size.height
                    let shouldScroll = contentHeight > (availableHeight + 1)

                    ScrollView {
                        VStack(spacing: 16) {
                            if !shouldScroll { Spacer(minLength: 0) }

                            content

                            if !shouldScroll { Spacer(minLength: 0) }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: availableHeight)
                        .background(
                            HeightReader()
                        )
                    }
                    .scrollDisabled(!shouldScroll)
                    .scrollIndicators(.hidden)
                    .onPreferenceChange(ViewHeightKey.self) { newValue in
                        contentHeight = newValue
                        containerHeight = availableHeight
                    }
                }
                #if os(iOS)
                .toolbar(.hidden, for: .navigationBar)
                #endif
            }
        }
    }
}

private struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private struct HeightReader: View {
    var body: some View {
        GeometryReader { proxy in
            Color.clear
                .preference(key: ViewHeightKey.self, value: proxy.size.height)
        }
    }
}
