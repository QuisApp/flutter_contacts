import Contacts
import Flutter

enum DeleteAllImpl {
    static func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let ids: [String] = call.argList("ids")!
        guard !ids.isEmpty else {
            return result(nil)
        }
        let store = CNContactStore()
        let keys: [CNKeyDescriptor] = [CNContactIdentifierKey as CNKeyDescriptor]

        HandlerHelpers.handleResult(result) {
            let predicate = CNContact.predicateForContacts(withIdentifiers: ids)
            let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keys)
            guard !contacts.isEmpty else {
                return nil
            }
            let mutableContacts = contacts.map { $0.mutableCopy() as! CNMutableContact }
            let saveRequest = CNSaveRequest()
            for mutableContact in mutableContacts {
                saveRequest.delete(mutableContact)
            }
            try store.execute(saveRequest)
            return nil
        }
    }
}
