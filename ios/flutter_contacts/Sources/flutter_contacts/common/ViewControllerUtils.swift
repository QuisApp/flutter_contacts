import UIKit

enum ViewControllerUtils {
    static func rootViewController() -> UIViewController? {
        let scene = UIApplication.shared.connectedScenes.first { $0 is UIWindowScene } as? UIWindowScene
        return scene?.windows.first { $0.isKeyWindow }?.rootViewController
    }
}
