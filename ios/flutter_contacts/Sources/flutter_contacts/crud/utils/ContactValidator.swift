import Foundation

enum ContactValidator {
    static func validateHasProperties(_ contact: Contact) throws -> Set<String> {
        guard let metadata = contact.metadata else {
            throw NSError(domain: "FlutterContacts", code: 1, userInfo: [NSLocalizedDescriptionKey: "Contact must have metadata. Contact must be fetched using getContact() or getAllContacts() before updating."])
        }

        let properties = Set(metadata.properties.map(\.rawValue))
        guard !properties.isEmpty else {
            throw NSError(domain: "FlutterContacts", code: 2, userInfo: [NSLocalizedDescriptionKey: "Contact metadata contains no properties. Contact must be fetched with at least one property before updating."])
        }
        return properties
    }

    static func validateSameProperties(_ contacts: [Contact]) throws -> Set<String> {
        guard let first = contacts.first else { return [] }
        let firstProperties = try validateHasProperties(first)
        for contact in contacts.dropFirst() where try validateHasProperties(contact) != firstProperties {
            throw NSError(domain: "FlutterContacts", code: 2, userInfo: [NSLocalizedDescriptionKey: "All contacts must have the same set of properties in metadata. All contacts must be fetched with the same properties parameter."])
        }
        return firstProperties
    }
}
