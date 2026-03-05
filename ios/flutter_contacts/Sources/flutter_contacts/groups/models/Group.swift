import Foundation

struct Group: Equatable, Hashable {
    let id: String?
    let name: String
    let account: Account?
    let contactCount: Int?

    init(id: String? = nil, name: String, account: Account? = nil, contactCount: Int? = nil) {
        self.id = id
        self.name = name
        self.account = account
        self.contactCount = contactCount
    }

    func toJson() -> Json {
        var json: Json = ["name": name]
        json.set("id", id)
        json.setJson("account", account) { $0.toJson() }
        json.set("contactCount", contactCount)
        return json
    }
}
