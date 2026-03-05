import Flutter
import UIKit

public class FlutterContactsPlugin: NSObject, FlutterPlugin {
    private lazy var handlers: [String: HandlerProtocol] = [
        "crud": CrudHandler(),
        "accounts": AccountsHandler(),
        "groups": GroupsHandler(),
        "permissions": PermissionsHandler(),
        "native": NativeHandler(),
    ]

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_contacts", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(FlutterContactsPlugin(), channel: channel)
        ListenerPlugin.register(with: registrar)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        DispatchQueue.global(qos: .userInitiated).async {
            let parts = call.method.split(separator: ".", maxSplits: 1)
            guard parts.count == 2,
                  let handler = self.handlers[String(parts[0])]
            else { return result(FlutterMethodNotImplemented) }
            handler.handle(
                FlutterMethodCall(methodName: String(parts[1]), arguments: call.arguments),
                result: result
            )
        }
    }
}

protocol HandlerProtocol {
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult)
}

typealias MethodHandler = (FlutterMethodCall, @escaping FlutterResult) -> Void

class MethodRouter: HandlerProtocol {
    private let handlers: [String: MethodHandler]

    init(_ handlers: [String: MethodHandler]) {
        self.handlers = handlers
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        handlers[call.method]?(call, result) ?? result(FlutterMethodNotImplemented)
    }
}
