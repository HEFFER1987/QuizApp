import UIKit

protocol PresentingViewControllerProviding {
    var topViewController: UIViewController? { get }
}

final class UIApplicationTopViewControllerProvider: PresentingViewControllerProviding {
    var topViewController: UIViewController? {
        let scenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }

        let window = scenes
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })

        guard var top = window?.rootViewController else { return nil }
        while let presented = top.presentedViewController {
            top = presented
        }
        return top
    }
}
