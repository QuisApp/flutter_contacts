import Contacts
import FlutterMacOS

enum UpdateImpl {
    static func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let contactJson: Json = call.arg("contact")!
        let contact = Contact.fromJson(contactJson)
        guard let contactId = contact.id else {
            return result(HandlerHelpers.makeError("Contact ID is required for update"))
        }
        let store = CNContactStore()

        HandlerHelpers.handleResult(result) {
            let properties = try ContactValidator.validateHasProperties(contact)
            let allProperties = ContactProperty.allRawValues()
            let keys = KeysBuilder.buildForUpdate(
                properties: properties == allProperties ? properties : allProperties
            )
            let existingContact = try store.unifiedContact(withIdentifier: contactId, keysToFetch: keys)
            let mutableContact = existingContact.mutableCopy() as! CNMutableContact
            ContactBuilder.updateCNMutableContact(mutableContact, with: contact, properties: properties)
            let saveRequest = CNSaveRequest()
            saveRequest.update(mutableContact)
            try store.execute(saveRequest)
            return nil
        }
    }
}
