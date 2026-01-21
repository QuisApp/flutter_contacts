import Contacts
import Flutter

enum UpdateAllImpl {
    static func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let contactsJson: JsonArray = call.arg("contacts")!
        guard !contactsJson.isEmpty else {
            return result(nil)
        }
        let enableIosNotes = call.arg("enableIosNotes", default: false)
        let store = CNContactStore()
        let contacts = contactsJson.map { Contact.fromJson($0) }
        let contactIds = contacts.compactMap { $0.id }
        guard !contactIds.isEmpty else {
            return result(nil)
        }

        HandlerHelpers.handleResult(result) {
            var properties = try ContactValidator.validateSameProperties(contacts)
            if !enableIosNotes {
                properties.remove("note")
            }
            let allProperties = ContactProperty.allRawValues(enableIosNotes: enableIosNotes)
            let keys = KeysBuilder.buildForUpdate(
                properties: properties == allProperties ? properties : allProperties,
                enableIosNotes: enableIosNotes
            )
            let predicate = CNContact.predicateForContacts(withIdentifiers: contactIds)
            let existingContacts = try store.unifiedContacts(matching: predicate, keysToFetch: keys)
            let existingContactsMap = Dictionary(uniqueKeysWithValues: existingContacts.map { ($0.identifier, $0) })
            let saveRequest = CNSaveRequest()
            for contact in contacts {
                guard let contactId = contact.id, let existingContact = existingContactsMap[contactId] else { continue }
                let mutableContact = existingContact.mutableCopy() as! CNMutableContact
                ContactBuilder.updateCNMutableContact(mutableContact, with: contact, properties: properties)
                saveRequest.update(mutableContact)
            }
            try store.execute(saveRequest)
            return nil
        }
    }
}
