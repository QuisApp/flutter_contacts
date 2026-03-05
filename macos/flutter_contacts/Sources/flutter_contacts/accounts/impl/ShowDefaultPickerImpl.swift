import FlutterMacOS

enum ShowDefaultPickerImpl {
    static func handle(call _: FlutterMethodCall, result: @escaping FlutterResult) {
        result(HandlerHelpers.makeError("Account picker is not available on macOS"))
    }
}
