import Contacts
import FlutterMacOS

enum GetGroupImpl {
    static func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let groupId: String = call.arg("groupId")!
        let withContactCount = call.arg("withContactCount", default: false)
        let store = CNContactStore()

        HandlerHelpers.handleResult(result) {
            let allContainers = try store.containers(matching: nil)
            var foundGroup: CNGroup?
            var foundContainer: CNContainer?

            for container in allContainers {
                let containerGroups = try store.groups(matching: CNGroup.predicateForGroupsInContainer(withIdentifier: container.identifier))
                if let group = containerGroups.first(where: { $0.identifier == groupId }) {
                    foundGroup = group
                    foundContainer = container
                    break
                }
            }

            guard let group = foundGroup, let container = foundContainer else {
                return nil
            }

            let contactCount = withContactCount ? try? getContactCount(store: store, group: group) : nil
            let account = Account.fromContainer(container)
            return Group(id: group.identifier, name: group.name, account: account, contactCount: contactCount).toJson()
        }
    }

    private static func getContactCount(store: CNContactStore, group: CNGroup) throws -> Int {
        let predicate = CNContact.predicateForContactsInGroup(withIdentifier: group.identifier)
        let keys: [CNKeyDescriptor] = [CNContactIdentifierKey as CNKeyDescriptor]
        return try store.unifiedContacts(matching: predicate, keysToFetch: keys).count
    }
}
