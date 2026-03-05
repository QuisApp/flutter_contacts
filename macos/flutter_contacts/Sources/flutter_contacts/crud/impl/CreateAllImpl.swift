import Contacts
import FlutterMacOS

enum CreateAllImpl {
    static func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let contactsJson: JsonArray = call.arg("contacts")!
        guard !contactsJson.isEmpty else {
            return result([])
        }
        let accountJson: Json? = call.arg("account")
        let account = accountJson.map(Account.fromJson)
        let store = CNContactStore()
        let containerId = AccountUtils.findContainer(account: account, store: store)

        HandlerHelpers.handleResult(result) {
            let contacts = contactsJson.map { Contact.fromJson($0) }
            let cnContacts = contacts.map { ContactBuilder.toCNMutableContact($0) }
            let saveRequest = CNSaveRequest()
            for cnContact in cnContacts {
                saveRequest.add(cnContact, toContainerWithIdentifier: containerId?.identifier)
            }
            try store.execute(saveRequest)
            return cnContacts.map { $0.identifier }
        }
    }
}
