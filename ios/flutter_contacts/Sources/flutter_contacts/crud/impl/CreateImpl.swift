import Contacts
import Flutter

enum CreateImpl {
    static func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let contactJson: Json = call.arg("contact")!
        let enableIosNotes = call.arg("enableIosNotes", default: false)
        let accountJson: Json? = call.arg("account")
        let account = accountJson.map(Account.fromJson)
        let store = CNContactStore()
        let containerId = AccountUtils.findContainer(account: account, store: store)

        HandlerHelpers.handleResult(result) {
            let contact = Contact.fromJson(contactJson)
            let cnContact = ContactBuilder.toCNMutableContact(contact, enableIosNotes: enableIosNotes)
            let saveRequest = CNSaveRequest()
            saveRequest.add(cnContact, toContainerWithIdentifier: containerId?.identifier)
            try store.execute(saveRequest)
            return cnContact.identifier
        }
    }
}
