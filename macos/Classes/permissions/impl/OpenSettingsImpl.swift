import AppKit
import FlutterMacOS

enum OpenSettingsImpl {
    static func handle(call _: FlutterMethodCall, result: @escaping FlutterResult) {
        // On macOS, open System Preferences > Security & Privacy > Privacy > Contacts
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Contacts") {
            NSWorkspace.shared.open(url)
            result(nil)
        } else {
            result(HandlerHelpers.makeError("Could not open system preferences"))
        }
    }
}
