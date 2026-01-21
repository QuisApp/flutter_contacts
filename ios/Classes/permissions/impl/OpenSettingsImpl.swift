import Flutter
import UIKit

enum OpenSettingsImpl {
    static func handle(call _: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            result(HandlerHelpers.makeError("Could not create settings URL"))
            return
        }
        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            result(nil)
        } else {
            result(HandlerHelpers.makeError("Cannot open settings URL"))
        }
    }
}
