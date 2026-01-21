import Contacts
import Flutter

enum DeleteImpl {
    static func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let id: String? = call.arg("id")
        let store = CNContactStore()
        let keys: [CNKeyDescriptor] = [CNContactIdentifierKey as CNKeyDescriptor]

        HandlerHelpers.handleResult(result) {
            guard let id = id else { return nil }
            let contact = try store.unifiedContact(withIdentifier: id, keysToFetch: keys)
            let mutableContact = contact.mutableCopy() as! CNMutableContact
            let saveRequest = CNSaveRequest()
            saveRequest.delete(mutableContact)
            try store.execute(saveRequest)
            return nil
        }
    }
}
