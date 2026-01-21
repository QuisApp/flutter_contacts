import Foundation

struct ContactChange {
    let type: ContactChangeType
    let contactId: String

    func toJson() -> Json {
        ["type": type.rawValue, "contactId": contactId]
    }
}

enum ContactChangeType: String {
    case added
    case updated
    case removed
}
