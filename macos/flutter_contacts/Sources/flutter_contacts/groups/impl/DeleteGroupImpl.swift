import Contacts
import FlutterMacOS

enum DeleteGroupImpl {
    static func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let groupId: String = call.arg("groupId")!
        let store = CNContactStore()

        HandlerHelpers.handleResult(result) {
            let predicate = CNGroup.predicateForGroups(withIdentifiers: [groupId])
            let groups = try store.groups(matching: predicate)
            guard let group = groups.first else {
                throw HandlerHelpers.nsError("Group not found")
            }
            let saveRequest = CNSaveRequest()
            let mutableGroup = group.mutableCopy() as! CNMutableGroup
            saveRequest.delete(mutableGroup)
            try store.execute(saveRequest)
            return nil
        }
    }
}
