import Contacts

enum PredicateBuilder {
    static func build(filter: Json?, containerId: String?) -> NSPredicate? {
        var predicates: [NSPredicate] = []

        if let filter {
            if let ids = filter["id"] as? [String] {
                predicates.append(CNContact.predicateForContacts(withIdentifiers: ids))
            }
            if let name = filter["name"] as? String {
                predicates.append(CNContact.predicateForContacts(matchingName: name))
            }
            // `email` is matched in GetAllImpl: predicateForContacts(matchingEmailAddress:) only
            // matches whole addresses, but the filter is a substring match.
            if let phone = filter["phone"] as? String {
                predicates.append(CNContact.predicateForContacts(matching: CNPhoneNumber(stringValue: phone)))
            }
            if let groupId = filter["group"] as? String {
                predicates.append(CNContact.predicateForContactsInGroup(withIdentifier: groupId))
            }
        }

        if let containerId = containerId {
            predicates.append(CNContact.predicateForContactsInContainer(withIdentifier: containerId))
        }

        return predicates.isEmpty ? nil : (predicates.count == 1 ? predicates[0] : NSCompoundPredicate(andPredicateWithSubpredicates: predicates))
    }

    static func build(id: String, containerId: String?) -> NSPredicate {
        var predicates: [NSPredicate] = [CNContact.predicateForContacts(withIdentifiers: [id])]
        if let containerId = containerId {
            predicates.append(CNContact.predicateForContactsInContainer(withIdentifier: containerId))
        }
        return predicates.count == 1 ? predicates[0] : NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
}
