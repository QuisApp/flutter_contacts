import Contacts

enum ContactBuilder {
    static func toCNMutableContact(_ contact: Contact) -> CNMutableContact {
        let cnContact = CNMutableContact()

        Name.apply(contact.name, to: cnContact)
        Phone.apply(contact.phones, to: cnContact)
        Email.apply(contact.emails, to: cnContact)
        Address.apply(contact.addresses, to: cnContact)
        Organization.apply(contact.organizations.first, to: cnContact)
        Website.apply(contact.websites, to: cnContact)
        SocialMedia.apply(contact.socialMedias, to: cnContact)
        Event.apply(contact.events, to: cnContact)
        Relation.apply(contact.relations, to: cnContact)
        Note.apply(contact.notes.first?.note, to: cnContact)
        Photo.apply(contact.photo, to: cnContact)

        return cnContact
    }

    static func updateCNMutableContact(_ mutableContact: CNMutableContact, with contact: Contact, properties: Set<String>) {
        let updates: [String: () -> Void] = [
            "name": { Name.apply(contact.name, to: mutableContact) },
            "phone": { Phone.apply(contact.phones, to: mutableContact) },
            "email": { Email.apply(contact.emails, to: mutableContact) },
            "address": { Address.apply(contact.addresses, to: mutableContact) },
            "organization": { Organization.apply(contact.organizations.first, to: mutableContact) },
            "website": { Website.apply(contact.websites, to: mutableContact) },
            "socialMedia": { SocialMedia.apply(contact.socialMedias, to: mutableContact) },
            "event": { Event.apply(contact.events, to: mutableContact) },
            "relation": { Relation.apply(contact.relations, to: mutableContact) },
            "note": { Note.apply(contact.notes.first?.note, to: mutableContact) },
        ]
        properties.forEach { updates[$0]?() }

        if properties.contains("photoThumbnail") || properties.contains("photoFullRes") {
            Photo.apply(contact.photo, to: mutableContact)
        }
    }
}
