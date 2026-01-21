import Contacts
import Foundation

enum SocialMediaLabel: String, CaseIterable {
    case aim
    case facebook
    case flickr
    case gameCenter
    case gaduGadu
    case googleTalk
    case icq
    case jabber
    case linkedIn
    case msn
    case mySpace
    case netmeeting
    case qq
    case sinaWeibo
    case skype
    case tencentWeibo
    case twitter
    case yahoo
    case yelp
    case other
    case custom

    private static let instantMessageLabels: Set<SocialMediaLabel> = [
        .aim, .facebook, .gaduGadu, .googleTalk, .icq, .jabber, .msn, .qq, .skype, .yahoo,
    ]

    private static let serviceMap: [String: String] = [
        "aim": CNInstantMessageServiceAIM,
        "facebook": CNInstantMessageServiceFacebook,
        "flickr": CNSocialProfileServiceFlickr,
        "gameCenter": CNSocialProfileServiceGameCenter,
        "gaduGadu": CNInstantMessageServiceGaduGadu,
        "googleTalk": CNInstantMessageServiceGoogleTalk,
        "icq": CNInstantMessageServiceICQ,
        "jabber": CNInstantMessageServiceJabber,
        "linkedIn": CNSocialProfileServiceLinkedIn,
        "msn": CNInstantMessageServiceMSN,
        "mySpace": CNSocialProfileServiceMySpace,
        "qq": CNInstantMessageServiceQQ,
        "sinaWeibo": CNSocialProfileServiceSinaWeibo,
        "skype": CNInstantMessageServiceSkype,
        "tencentWeibo": CNSocialProfileServiceTencentWeibo,
        "twitter": CNSocialProfileServiceTwitter,
        "yahoo": CNInstantMessageServiceYahoo,
        "yelp": CNSocialProfileServiceYelp,
    ]

    static func fromService(_ service: String, customLabel: String?) -> Label<SocialMediaLabel> {
        for (key, value) in serviceMap where value == service {
            return Label(label: SocialMediaLabel(rawValue: key) ?? .other)
        }
        return Label(label: .custom, customLabel: customLabel ?? service)
    }

    func toService() -> String? {
        return Self.serviceMap[rawValue]
    }

    var isInstantMessage: Bool {
        return Self.instantMessageLabels.contains(self)
    }
}
