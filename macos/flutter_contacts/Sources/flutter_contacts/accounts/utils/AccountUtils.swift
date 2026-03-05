import Contacts

enum AccountUtils {
    static func findContainer(account: Account?, store: CNContactStore) -> CNContainer? {
        guard let account, let containers = try? store.containers(matching: nil) else { return nil }
        return containers.first { $0.name == account.name && toString($0.type) == account.type }
    }

    static func getDefaultContainer(store: CNContactStore) throws -> CNContainer? {
        let defaultContainerId = store.defaultContainerIdentifier()
        let predicate = CNContainer.predicateForContainers(withIdentifiers: [defaultContainerId])
        return try store.containers(matching: predicate).first
    }

    static func toString(_ type: CNContainerType) -> String {
        switch type {
        case .local: return "local"
        case .exchange: return "exchange"
        case .cardDAV: return "carddav"
        case .unassigned: return "unassigned"
        @unknown default: return "unknown"
        }
    }
}
