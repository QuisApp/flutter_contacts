import Contacts
import FlutterMacOS

enum GetOfImpl {
    static func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let contactId: String = call.arg("contactId")!
        let store = CNContactStore()

        HandlerHelpers.handleResult(result) {
            let allGroups = try store.groups(matching: nil)
            let allContainers = try store.containers(matching: nil)
            let keys: [CNKeyDescriptor] = [CNContactIdentifierKey as CNKeyDescriptor]
            var groupToContainer: [String: CNContainer] = [:]
            for container in allContainers {
                let containerGroups = try store.groups(matching: CNGroup.predicateForGroupsInContainer(withIdentifier: container.identifier))
                for group in containerGroups {
                    groupToContainer[group.identifier] = container
                }
            }
            let contactGroups = try allGroups.compactMap { group -> Group? in
                // Avoid compound predicates with unifiedContacts - check group membership separately
                let groupPredicate = CNContact.predicateForContactsInGroup(withIdentifier: group.identifier)
                let groupContacts = try store.unifiedContacts(matching: groupPredicate, keysToFetch: keys)
                guard groupContacts.contains(where: { $0.identifier == contactId }) else { return nil }
                guard let container = groupToContainer[group.identifier] else { return nil }
                return Group(id: group.identifier, name: group.name, account: Account.fromContainer(container), contactCount: nil)
            }
            return contactGroups.sorted { $0.name < $1.name }.map { $0.toJson() }
        }
    }
}
