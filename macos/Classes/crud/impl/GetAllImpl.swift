import Contacts
import FlutterMacOS

enum GetAllImpl {
    static func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let properties = Set(call.argList("properties") as [String]? ?? [])
        let filter: Json? = call.arg("filter")
        let accountJson: Json? = call.arg("account")
        let account = accountJson.map(Account.fromJson)
        let limit: Int? = call.arg("limit")
        let store = ContactStoreProvider.shared
        let containerId = AccountUtils.findContainer(account: account, store: store)?.identifier
        let predicate = PredicateBuilder.build(filter: filter, containerId: containerId)
        let keys = KeysBuilder.build(properties: properties)

        DispatchQueue.global(qos: .userInitiated).async {
            HandlerHelpers.handleResult(result) {
                let request = CNContactFetchRequest(keysToFetch: keys)
                request.predicate = predicate
                request.sortOrder = .givenName
                let options = ContactConverter.makeOptions(properties: properties)
                var contacts: [Json] = []
                if let limit = limit { contacts.reserveCapacity(limit) }
                try store.enumerateContacts(with: request) { contact, stop in
                    autoreleasepool {
                        contacts.append(ContactConverter.toJson(contact, options: options))
                    }
                    if let limit = limit, contacts.count >= limit {
                        stop.pointee = true
                    }
                }
                return contacts
            }
        }
    }
}
