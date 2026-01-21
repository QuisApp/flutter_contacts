import Contacts
import FlutterMacOS

enum GetAllGroupsImpl {
    static func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let accountsList = (call.args?["accounts"] as? JsonArray)?.map(Account.fromJson)
        let withContactCount = call.arg("withContactCount", default: false)
        let store = CNContactStore()

        HandlerHelpers.handleResult(result) {
            let targetContainers: [CNContainer]
            if let accounts = accountsList, !accounts.isEmpty {
                targetContainers = accounts.compactMap { account in
                    AccountUtils.findContainer(account: account, store: store)
                }
            } else {
                let allContainers = try store.containers(matching: nil)
                targetContainers = allContainers
            }
            let groups = try targetContainers.flatMap { container -> [Group] in
                try store.groups(matching: CNGroup.predicateForGroupsInContainer(withIdentifier: container.identifier))
                    .map { group in
                        let contactCount = withContactCount ? try? getContactCount(store: store, group: group) : nil
                        return Group(id: group.identifier, name: group.name, account: Account.fromContainer(container), contactCount: contactCount)
                    }
            }
            return groups.sorted { $0.name < $1.name }.map { $0.toJson() }
        }
    }

    private static func getContactCount(store: CNContactStore, group: CNGroup) throws -> Int {
        let predicate = CNContact.predicateForContactsInGroup(withIdentifier: group.identifier)
        let keys: [CNKeyDescriptor] = [CNContactIdentifierKey as CNKeyDescriptor]
        return try store.unifiedContacts(matching: predicate, keysToFetch: keys).count
    }
}
