import FlutterMacOS

final class GroupsHandler: MethodRouter {
    init() {
        super.init([
            "get": GetGroupImpl.handle,
            "getAll": GetAllGroupsImpl.handle,
            "getOf": GetOfImpl.handle,
            "create": CreateGroupImpl.handle,
            "update": UpdateGroupImpl.handle,
            "delete": DeleteGroupImpl.handle,
            "addContacts": AddContactsImpl.handle,
            "removeContacts": RemoveContactsImpl.handle,
        ])
    }
}
