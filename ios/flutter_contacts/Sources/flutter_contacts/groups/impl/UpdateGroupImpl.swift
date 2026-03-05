import Contacts
import Flutter

enum UpdateGroupImpl {
    static func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let groupId: String = call.arg("groupId")!
        let name: String = call.arg("name")!
        let store = CNContactStore()

        HandlerHelpers.handleResult(result) {
            let predicate = CNGroup.predicateForGroups(withIdentifiers: [groupId])
            let groups = try store.groups(matching: predicate)
            guard let group = groups.first else {
                throw HandlerHelpers.nsError("Group not found")
            }
            let saveRequest = CNSaveRequest()
            let mutableGroup = group.mutableCopy() as! CNMutableGroup
            mutableGroup.name = name
            saveRequest.update(mutableGroup)
            try store.execute(saveRequest)
            return nil
        }
    }
}
