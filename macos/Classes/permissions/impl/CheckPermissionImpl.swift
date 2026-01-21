import Contacts
import FlutterMacOS

enum CheckPermissionImpl {
    static func handle(call _: FlutterMethodCall, result: @escaping FlutterResult) {
        result(PermissionUtils.mapAuthorizationStatus(CNContactStore.authorizationStatus(for: .contacts)))
    }
}
