import Foundation

struct ContactMetadata: Equatable, Hashable {
    let properties: Set<ContactProperty>
    let accounts: [Account]

    func toJson() -> Json {
        [
            "properties": [String](properties.map { $0.rawValue }.sorted()),
            "accounts": accounts.map { $0.toJson() },
        ]
    }

    static func fromJson(_ json: Json) -> ContactMetadata {
        let properties = Set((json["properties"] as? [String] ?? []).compactMap(ContactProperty.init))
        let accounts = (json["accounts"] as? JsonArray ?? []).map(Account.fromJson)
        return ContactMetadata(properties: properties, accounts: accounts)
    }
}
