import Foundation

struct Contact: Equatable, Hashable {
    let id: String?
    let displayName: String?
    let photo: Photo?
    let name: Name?
    let phones: [Phone]
    let emails: [Email]
    let addresses: [Address]
    let organizations: [Organization]
    let websites: [Website]
    let socialMedias: [SocialMedia]
    let events: [Event]
    let relations: [Relation]
    let notes: [Note]
    let metadata: ContactMetadata?

    init(id: String? = nil, displayName: String? = nil, photo: Photo? = nil, name: Name? = nil, phones: [Phone] = [], emails: [Email] = [], addresses: [Address] = [], organizations: [Organization] = [], websites: [Website] = [], socialMedias: [SocialMedia] = [], events: [Event] = [], relations: [Relation] = [], notes: [Note] = [], metadata: ContactMetadata? = nil) {
        self.id = id
        self.displayName = displayName
        self.photo = photo
        self.name = name
        self.phones = phones
        self.emails = emails
        self.addresses = addresses
        self.organizations = organizations
        self.websites = websites
        self.socialMedias = socialMedias
        self.events = events
        self.relations = relations
        self.notes = notes
        self.metadata = metadata
    }

    func toJson() -> Json {
        var json: Json = [:]
        json.set("id", id)
        json.set("displayName", displayName)
        json.setJson("photo", photo) { $0.toJson() }
        json.setJson("name", name) { $0.toJson() }
        json.setList("phones", phones) { $0.toJson() }
        json.setList("emails", emails) { $0.toJson() }
        json.setList("addresses", addresses) { $0.toJson() }
        json.setList("organizations", organizations) { $0.toJson() }
        json.setList("websites", websites) { $0.toJson() }
        json.setList("socialMedias", socialMedias) { $0.toJson() }
        json.setList("events", events) { $0.toJson() }
        json.setList("relations", relations) { $0.toJson() }
        json.setList("notes", notes) { $0.toJson() }
        json.setJson("metadata", metadata) { $0.toJson() }
        return json
    }

    static func fromJson(_ json: Json) -> Contact {
        Contact(
            id: json.value("id"),
            displayName: json.value("displayName"),
            photo: json.json("photo", Photo.fromJson),
            name: json.json("name", Name.fromJson),
            phones: json.list("phones", Phone.fromJson),
            emails: json.list("emails", Email.fromJson),
            addresses: json.list("addresses", Address.fromJson),
            organizations: json.list("organizations", Organization.fromJson),
            websites: json.list("websites", Website.fromJson),
            socialMedias: json.list("socialMedias", SocialMedia.fromJson),
            events: json.list("events", Event.fromJson),
            relations: json.list("relations", Relation.fromJson),
            notes: json.list("notes", Note.fromJson),
            metadata: json.json("metadata", ContactMetadata.fromJson)
        )
    }
}
