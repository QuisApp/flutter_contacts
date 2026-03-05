import Contacts
import Flutter

enum GetImpl {
    static func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let id: String? = call.arg("id")
        let properties = Set(call.argList("properties") as [String]? ?? [])
        let enableIosNotes = call.arg("enableIosNotes", default: false)
        let accountJson: Json? = call.arg("account")
        let account = accountJson.map(Account.fromJson)
        let store = ContactStoreProvider.shared
        guard let id = id else { return result(nil) }
        let containerId = AccountUtils.findContainer(account: account, store: store)?.identifier
        let keys = KeysBuilder.build(properties: properties, enableIosNotes: enableIosNotes)

        DispatchQueue.global(qos: .userInitiated).async {
            HandlerHelpers.handleResult(result) {
                // Get contact by ID first
                let contact = try store.unifiedContact(withIdentifier: id, keysToFetch: keys)

                // If containerId is specified, verify the contact is in that container
                if let containerId = containerId {
                    let containerPredicate = CNContact.predicateForContactsInContainer(withIdentifier: containerId)
                    let identifierKeys: [CNKeyDescriptor] = [CNContactIdentifierKey as CNKeyDescriptor]
                    let containerContacts = try store.unifiedContacts(matching: containerPredicate, keysToFetch: identifierKeys)
                    guard containerContacts.contains(where: { $0.identifier == id }) else {
                        return nil
                    }
                }

                let options = ContactConverter.makeOptions(properties: properties, enableIosNotes: enableIosNotes)
                return ContactConverter.toJson(contact, options: options)
            }
        }
    }
}
