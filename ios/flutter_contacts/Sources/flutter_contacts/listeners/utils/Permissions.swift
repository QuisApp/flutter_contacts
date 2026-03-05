import Contacts

enum Permissions {
    static func hasReadPermission() -> Bool {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        if #available(iOS 18.0, *) {
            return status == .authorized || status == .limited
        } else {
            return status == .authorized
        }
    }
}
