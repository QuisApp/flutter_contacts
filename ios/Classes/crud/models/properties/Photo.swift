import Contacts
import Foundation

struct Photo: Equatable, Hashable {
    let thumbnail: Data?
    let fullSize: Data?

    init(thumbnail: Data? = nil, fullSize: Data? = nil) {
        self.thumbnail = thumbnail
        self.fullSize = fullSize
    }

    init(fromContact contact: CNContact, wantsThumbnail: Bool, wantsFullRes: Bool) {
        var thumbnail: Data? = nil
        var fullSize: Data? = nil

        if contact.imageDataAvailable {
            if wantsThumbnail {
                thumbnail = contact.thumbnailImageData
            }
            if wantsFullRes {
                fullSize = contact.imageData
            }
        }

        self.thumbnail = thumbnail
        self.fullSize = fullSize
    }

    func toJson() -> Json {
        var json: Json = [:]
        json.set("thumbnail", thumbnail?.base64EncodedString())
        json.set("fullSize", fullSize?.base64EncodedString())
        return json
    }

    static func fromJson(_ json: Json) -> Photo {
        Photo(
            thumbnail: (json["thumbnail"] as? String).flatMap { Data(base64Encoded: $0) },
            fullSize: (json["fullSize"] as? String).flatMap { Data(base64Encoded: $0) }
        )
    }

    var isEmpty: Bool { thumbnail == nil && fullSize == nil }

    static func apply(_ photo: Photo?, to cnContact: CNMutableContact) {
        cnContact.imageData = photo?.fullSize ?? photo?.thumbnail
    }
}
