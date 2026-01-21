import Contacts
import Flutter

enum UpdateImpl {
    static func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let contactJson: Json = call.arg("contact")!
        let contact = Contact.fromJson(contactJson)
        guard let contactId = contact.id else {
            return result(HandlerHelpers.makeError("Contact ID is required for update"))
        }
        let enableIosNotes = call.arg("enableIosNotes", default: false)
        let store = CNContactStore()

        HandlerHelpers.handleResult(result) {
            var properties = try ContactValidator.validateHasProperties(contact)
            if !enableIosNotes {
                properties.remove("note")
            }
            let allProperties = ContactProperty.allRawValues(enableIosNotes: enableIosNotes)
            let keys = KeysBuilder.buildForUpdate(
                properties: properties == allProperties ? properties : allProperties,
                enableIosNotes: enableIosNotes
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
