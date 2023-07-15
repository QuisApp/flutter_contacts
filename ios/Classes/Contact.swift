import Contacts

@available(iOS 9.0, *)
struct Contact {
    var id: String = ""
    var displayName: String = ""
    var isStarred: Bool = false
    var name = Name()
    var thumbnail: Data?
    var photo: Data?
    var phones: [Phone] = []
    var emails: [Email] = []
    var addresses: [Address] = []
    var organizations: [Organization] = []
    var websites: [Website] = []
    var socialMedias: [SocialMedia] = []
    var events: [Event] = []
    var notes: [Note] = []
    var accounts: [Account] = []
    var groups: [Group] = []

    init(fromMap m: [String: Any?]) {
        id = m["id"] as! String
        displayName = m["displayName"] as! String
        name = Name(fromMap: m["name"] as! [String: Any])
        thumbnail = m["thumbnail"] as? Data
        photo = m["photo"] as? Data
        phones = (m["phones"] as! [[String: Any]]).map { Phone(fromMap: $0) }
        emails = (m["emails"] as! [[String: Any]]).map { Email(fromMap: $0) }
        addresses = (m["addresses"] as! [[String: Any]]).map { Address(fromMap: $0) }
        organizations = (m["organizations"] as! [[String: Any]]).map {
            Organization(fromMap: $0)
        }
        websites = (m["websites"] as! [[String: Any]]).map { Website(fromMap: $0) }
        socialMedias = (m["socialMedias"] as! [[String: Any]]).map {
            SocialMedia(fromMap: $0)
        }
        events = (m["events"] as! [[String: Any?]]).map { Event(fromMap: $0) }
        notes = (m["notes"] as! [[String: Any]]).map { Note(fromMap: $0) }
        accounts = (m["accounts"] as! [[String: Any]]).map { Account(fromMap: $0) }
        groups = (m["groups"] as! [[String: Any]]).map { Group(fromMap: $0) }
    }

    init(fromContact c: CNContact) {
        id = c.identifier
        displayName = CNContactFormatter.string(
            from: c,
            style: CNContactFormatterStyle.fullName
        ) ?? ""

        // Hack/shortcut: if this key is available, all others are too. (We could have
        // CNContactGivenNameKey instead but it seems to be included by default along
        // with some others, so we're going with a more exotic one here.)
        if c.isKeyAvailable(CNContactPhoneticGivenNameKey) {
            name = Name(fromContact: c)
            phones = c.phoneNumbers.map { Phone(fromPhone: $0) }
            emails = c.emailAddresses.map { Email(fromEmail: $0) }
            addresses = c.postalAddresses.map { Address(fromAddress: $0) }
            if !c.organizationName.isEmpty
                || !c.jobTitle.isEmpty
                || !c.departmentName.isEmpty
            {
                organizations = [Organization(fromContact: c)]
            } else if #available(iOS 10, *), !c.phoneticOrganizationName.isEmpty {
                organizations = [Organization(fromContact: c)]
            }
            websites = c.urlAddresses.map { Website(fromWebsite: $0) }
            socialMedias = c.socialProfiles.map {
                SocialMedia(fromSocialProfile: $0)
            } + c.instantMessageAddresses.map {
                SocialMedia(fromInstantMessage: $0)
            }
            if c.birthday != nil {
                events = [Event(fromContact: c)]
            }
            events += c.dates.map { Event(fromDate: $0) }
            // Notes need entitlements to be accessed in iOS 13+.
            // https://stackoverflow.com/questions/57442114/ios-13-cncontacts-no-longer-working-to-retrieve-all-contacts
            if c.isKeyAvailable(CNContactNoteKey) {
                notes = [Note(fromContact: c)]
            }
        }
        if c.isKeyAvailable(CNContactThumbnailImageDataKey) {
            thumbnail = c.thumbnailImageData
        }
        if c.isKeyAvailable(CNContactImageDataKey) {
            photo = c.imageData
        }
    }

    func toMap() -> [String: Any?] { [
        "id": id,
        "displayName": displayName,
        "isStarred": isStarred,
        "name": name.toMap(),
        "thumbnail": thumbnail,
        "photo": photo,
        "phones": phones.map { $0.toMap() },
        "emails": emails.map { $0.toMap() },
        "addresses": addresses.map { $0.toMap() },
        "organizations": organizations.map { $0.toMap() },
        "websites": websites.map { $0.toMap() },
        "socialMedias": socialMedias.map { $0.toMap() },
        "events": events.map { $0.toMap() },
        "notes": notes.map { $0.toMap() },
        "accounts": accounts.map { $0.toMap() },
        "groups": groups.map { $0.toMap() },
    ]
    }
}
