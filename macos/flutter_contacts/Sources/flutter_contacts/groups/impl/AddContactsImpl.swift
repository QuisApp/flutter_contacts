import Contacts
import FlutterMacOS

enum AddContactsImpl {
    static func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let groupId: String = call.arg("groupId")!
        let contactIds: [String] = call.argList("contactIds")!
        let store = CNContactStore()

        HandlerHelpers.handleResult(result) {
            let groupPredicate = CNGroup.predicateForGroups(withIdentifiers: [groupId])
            let groups = try store.groups(matching: groupPredicate)
            guard let group = groups.first else {
                throw HandlerHelpers.nsError("Group not found")
            }
            let contactPredicate = CNContact.predicateForContacts(withIdentifiers: contactIds)
            let keys: [CNKeyDescriptor] = [CNContactIdentifierKey as CNKeyDescriptor]
            let contacts = try store.unifiedContacts(matching: contactPredicate, keysToFetch: keys)
            let saveRequest = CNSaveRequest()
            for contact in contacts {
                let mutableContact = contact.mutableCopy() as! CNMutableContact
                saveRequest.addMember(mutableContact, to: group)
            }
            try store.execute(saveRequest)
            return nil
        }
    }
}
