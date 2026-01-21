import Contacts

enum Permissions {
    static func hasReadPermission() -> Bool {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        return status == .authorized
    }
}
