import Contacts
import FlutterMacOS

enum GetAllAccountsImpl {
    static func handle(call _: FlutterMethodCall, result: @escaping FlutterResult) {
        HandlerHelpers.handleResult(result) {
            let containers = try CNContactStore().containers(matching: nil)
            let accounts = containers.map { Account.fromContainer($0) }
            return accounts.map { $0.toJson() }
        }
    }
}
