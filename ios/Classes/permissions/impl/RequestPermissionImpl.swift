import Contacts
import Flutter

enum RequestPermissionImpl {
    static func handle(call _: FlutterMethodCall, result: @escaping FlutterResult) {
        let store = CNContactStore()
        let currentStatus = CNContactStore.authorizationStatus(for: .contacts)
        if currentStatus == .authorized { return result("granted") }
        if #available(iOS 18.0, *), currentStatus == .limited { return result("limited") }

        store.requestAccess(for: .contacts) { _, _ in
            DispatchQueue.main.async {
                result(PermissionUtils.mapAuthorizationStatus(CNContactStore.authorizationStatus(for: .contacts)))
            }
        }
    }
}
