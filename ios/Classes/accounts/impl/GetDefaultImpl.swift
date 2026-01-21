import Contacts
import Flutter

enum GetDefaultImpl {
    static func handle(call _: FlutterMethodCall, result: @escaping FlutterResult) {
        HandlerHelpers.handleResult(result) {
            let store = CNContactStore()
            if let container = try AccountUtils.getDefaultContainer(store: store) {
                return Account.fromContainer(container).toJson()
            }
            return nil
        }
    }
}
