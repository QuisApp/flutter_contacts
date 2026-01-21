import Contacts
import FlutterMacOS

enum RequestPermissionImpl {
    static func handle(call _: FlutterMethodCall, result: @escaping FlutterResult) {
        let store = CNContactStore()
        let currentStatus = CNContactStore.authorizationStatus(for: .contacts)
        if currentStatus == .authorized { return result("granted") }

        store.requestAccess(for: .contacts) { _, _ in
            DispatchQueue.main.async {
                result(PermissionUtils.mapAuthorizationStatus(CNContactStore.authorizationStatus(for: .contacts)))
            }
        }
    }
}
