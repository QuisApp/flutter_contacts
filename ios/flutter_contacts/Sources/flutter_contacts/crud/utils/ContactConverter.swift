import Contacts

enum ContactConverter {
    struct Options {
        let hasName: Bool
        let hasPhone: Bool
        let hasEmail: Bool
        let hasAddress: Bool
        let hasOrganization: Bool
        let hasWebsite: Bool
        let hasSocialMedia: Bool
        let hasEvent: Bool
        let hasRelation: Bool
        let wantsNotes: Bool
        let wantsThumbnail: Bool
        let wantsFullRes: Bool
        let metadataJson: Json
    }

    static func makeOptions(properties: Set<String>, enableIosNotes: Bool) -> Options {
        let has = properties.contains
        let wantsThumbnail = has("photoThumbnail")
        let wantsFullRes = has("photoFullRes")
        let wantsNotes = has("note") && enableIosNotes
        let metadata = ContactMetadata(properties: Set(properties.compactMap(ContactProperty.init)), accounts: [])

        return Options(
            hasName: has("name"),
            hasPhone: has("phone"),
            hasEmail: has("email"),
            hasAddress: has("address"),
            hasOrganization: has("organization"),
            hasWebsite: has("website"),
            hasSocialMedia: has("socialMedia"),
            hasEvent: has("event"),
            hasRelation: has("relation"),
            wantsNotes: wantsNotes,
            wantsThumbnail: wantsThumbnail,
            wantsFullRes: wantsFullRes,
            metadataJson: metadata.toJson()
        )
    }

    static func toJson(_ cnContact: CNContact, options: Options) -> Json {
        var json: Json = [:]
        json.set("id", cnContact.identifier)
        json.set("displayName", CNContactFormatter.string(from: cnContact, style: .fullName))

        if options.wantsThumbnail || options.wantsFullRes {
            let photo = Photo(fromContact: cnContact, wantsThumbnail: options.wantsThumbnail, wantsFullRes: options.wantsFullRes)
            if !photo.isEmpty {
                json.setJson("photo", photo) { $0.toJson() }
            }
        }

        if options.hasName {
            let name = Name(fromContact: cnContact)
            json.setJson("name", name) { $0.toJson() }
        }

        if options.hasPhone {
            json.setList("phones", cnContact.phoneNumbers.map { Phone(fromPhone: $0) }) { $0.toJson() }
        }

        if options.hasEmail {
            json.setList("emails", cnContact.emailAddresses.map { Email(fromEmail: $0) }) { $0.toJson() }
        }

        if options.hasAddress {
            json.setList("addresses", cnContact.postalAddresses.map { Address(fromAddress: $0) }) { $0.toJson() }
        }

        if options.hasOrganization {
            let organizations = [Organization(fromContact: cnContact)].filter { !$0.isEmpty }
            json.setList("organizations", organizations) { $0.toJson() }
        }

        if options.hasWebsite {
            json.setList("websites", cnContact.urlAddresses.map { Website(fromURL: $0) }) { $0.toJson() }
        }

        if options.hasSocialMedia {
            let socialMedias = cnContact.socialProfiles.map { SocialMedia(fromSocialProfile: $0) }
                + cnContact.instantMessageAddresses.map { SocialMedia(fromInstantMessage: $0) }
            json.setList("socialMedias", socialMedias) { $0.toJson() }
        }

        if options.hasEvent {
            json.setList("events", buildEvents(from: cnContact)) { $0.toJson() }
        }

        if options.hasRelation {
            json.setList("relations", cnContact.contactRelations.map { Relation(fromRelation: $0) }) { $0.toJson() }
        }

        if options.wantsNotes, !cnContact.note.isEmpty {
            json.setList("notes", [Note(note: cnContact.note)]) { $0.toJson() }
        }

        json["metadata"] = options.metadataJson
        return json
    }

    static func toContact(_ cnContact: CNContact, properties: Set<String>, enableIosNotes: Bool) -> Contact {
        let has = properties.contains
        let name = has("name") ? Name(fromContact: cnContact) : nil
        let wantsThumbnail = has("photoThumbnail")
        let wantsFullRes = has("photoFullRes")
        let photo = (wantsThumbnail || wantsFullRes)
            ? Photo(fromContact: cnContact, wantsThumbnail: wantsThumbnail, wantsFullRes: wantsFullRes)
            : nil
        let cleanPhoto = (photo?.isEmpty ?? true) ? nil : photo

        let organizations = has("organization") ? [Organization(fromContact: cnContact)].filter { !$0.isEmpty } : []

        let socialMedias = has("socialMedia")
            ? cnContact.socialProfiles.map { SocialMedia(fromSocialProfile: $0) }
            + cnContact.instantMessageAddresses.map { SocialMedia(fromInstantMessage: $0) }
            : []

        let metadata = ContactMetadata(properties: Set(properties.compactMap(ContactProperty.init)), accounts: [])

        return Contact(
            id: cnContact.identifier,
            displayName: CNContactFormatter.string(from: cnContact, style: .fullName),
            photo: cleanPhoto,
            name: name,
            phones: has("phone") ? cnContact.phoneNumbers.map { Phone(fromPhone: $0) } : [],
            emails: has("email") ? cnContact.emailAddresses.map { Email(fromEmail: $0) } : [],
            addresses: has("address") ? cnContact.postalAddresses.map { Address(fromAddress: $0) } : [],
            organizations: organizations,
            websites: has("website") ? cnContact.urlAddresses.map { Website(fromURL: $0) } : [],
            socialMedias: socialMedias,
            events: has("event") ? buildEvents(from: cnContact) : [],
            relations: has("relation") ? cnContact.contactRelations.map { Relation(fromRelation: $0) } : [],
            notes: has("note") && enableIosNotes && !cnContact.note.isEmpty ? [Note(note: cnContact.note)] : [],
            metadata: metadata
        )
    }

    private static func buildEvents(from contact: CNContact) -> [Event] {
        var events: [Event] = []
        if let birthday = contact.birthday, let month = birthday.month, let day = birthday.day {
            events.append(Event(year: birthday.year, month: month, day: day, label: Label(label: .birthday)))
        }
        for date in contact.dates {
            guard let dateComponents = date.value as DateComponents?,
                  let month = dateComponents.month, let day = dateComponents.day
            else { continue }
            let label = EventLabel.fromCN(date.label)
            events.append(Event(
                year: dateComponents.year,
                month: month,
                day: day,
                label: label,
                metadata: PropertyMetadata(dataId: date.identifier)
            ))
        }
        return events
    }
}
