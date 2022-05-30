import Contacts

@available(iOS 9.0, *)
struct Group {
    var id: String
    var name: String
    var accountId: String

    init(fromMap m: [String: Any]) {
        id = m["id"] as! String
        name = m["name"] as! String
        accountId = m["accountId"] as! String
    }

    init(fromGroup g: CNGroup, accountId: String) {
        id = g.identifier
        name = g.name
        self.accountId = accountId
    }

    func toMap() -> [String: Any] { [
        "id": id,
        "name": name,
        "accountId": accountId,
    ]
    }
}
