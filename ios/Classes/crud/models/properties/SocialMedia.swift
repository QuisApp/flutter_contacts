import Contacts
import Foundation

struct SocialMedia: Equatable, Hashable {
    let username: String
    let label: Label<SocialMediaLabel>
    let metadata: PropertyMetadata?

    init(username: String, label: Label<SocialMediaLabel>? = nil, metadata: PropertyMetadata? = nil) {
        self.username = username
        self.label = label ?? Label(label: .other)
        self.metadata = metadata
    }

    init(fromSocialProfile profile: CNLabeledValue<CNSocialProfile>) {
        let label = SocialMediaLabel.fromService(profile.value.service, customLabel: profile.label)
        self.init(
            username: profile.value.username,
            label: label,
            metadata: PropertyMetadata(dataId: profile.identifier)
        )
    }

    init(fromInstantMessage im: CNLabeledValue<CNInstantMessageAddress>) {
        let label = SocialMediaLabel.fromService(im.value.service, customLabel: im.label)
        self.init(
            username: im.value.username,
            label: label,
            metadata: PropertyMetadata(dataId: im.identifier)
        )
    }

    func toJson() -> Json {
        var json: Json = ["username": username, "label": label.toJson()]
        json.setJson("metadata", metadata) { $0.toJson() }
        return json
    }

    static func fromJson(_ json: Json) -> SocialMedia {
        SocialMedia(
            username: json["username"] as! String,
            label: Label.fromJson(json["label"] as! Json, fromName: { SocialMediaLabel(rawValue: $0)! }),
            metadata: json.json("metadata", PropertyMetadata.fromJson)
        )
    }

    static func apply(_ socialMedias: [SocialMedia], to cnContact: CNMutableContact) {
        var socialProfiles: [CNLabeledValue<CNSocialProfile>] = []
        var instantMessages: [CNLabeledValue<CNInstantMessageAddress>] = []

        for socialMedia in socialMedias {
            let label = socialMedia.label.customLabel
            let serviceLabel = socialMedia.label.label

            if serviceLabel.isInstantMessage, let service = serviceLabel.toService() {
                let imAddress = CNInstantMessageAddress(username: socialMedia.username, service: service)
                instantMessages.append(CNLabeledValue(label: label, value: imAddress))
            } else {
                let service = serviceLabel.toService() ?? socialMedia.label.customLabel ?? serviceLabel.rawValue
                let profile = CNSocialProfile(urlString: nil, username: socialMedia.username, userIdentifier: nil, service: service)
                socialProfiles.append(CNLabeledValue(label: label, value: profile))
            }
        }

        cnContact.socialProfiles = socialProfiles
        cnContact.instantMessageAddresses = instantMessages
    }
}
