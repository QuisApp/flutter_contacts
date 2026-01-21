import Contacts
import Flutter

enum CreateGroupImpl {
    static func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let name: String = call.arg("name")!
        let accountJson: Json? = call.arg("account")
        let account = accountJson.map(Account.fromJson)
        let store = CNContactStore()

        HandlerHelpers.handleResult(result) {
            let container = try account.flatMap { AccountUtils.findContainer(account: $0, store: store) }
                ?? AccountUtils.getDefaultContainer(store: store)
            let saveRequest = CNSaveRequest()
            let mutableGroup = CNMutableGroup()
            mutableGroup.name = name
            saveRequest.add(mutableGroup, toContainerWithIdentifier: container?.identifier)
            try store.execute(saveRequest)
            let containerId = container?.identifier
            let predicate = containerId != nil ? CNGroup.predicateForGroupsInContainer(withIdentifier: containerId!) : nil
            let groups = try store.groups(matching: predicate)
            guard let group = groups.first(where: { $0.name == name }) else {
                throw HandlerHelpers.nsError("Failed to retrieve created group")
            }
            let createdGroup = Group(
                id: group.identifier,
                name: group.name,
                account: container.map(Account.fromContainer),
                contactCount: 0
            )
            return createdGroup.toJson()
        }
    }
}
