import Contacts

@available(iOS 9.0, *)
struct SocialMedia {
    var userName: String
    // one of: aim, baiduTieba, discord, facebook, flickr, gaduGadu, gameCenter,
    // googleTalk, icq, instagram, jabber, line, linkedIn, medium, messenger, msn,
    // mySpace, netmeeting, pinterest, qqchat, qzone, reddit, sinaWeibo, skype,
    // snapchat, telegram, tencentWeibo, tikTok, tumblr, twitter, viber, wechat,
    // whatsapp, yahoo, yelp, youtube, zoom, other, custom
    var label: String = "other"
    var customLabel: String = ""

    init(fromMap m: [String: Any]) {
        userName = m["userName"] as! String
        label = m["label"] as! String
        customLabel = m["customLabel"] as! String
    }

    init(fromSocialProfile p: CNLabeledValue<CNSocialProfile>) {
        userName = p.value.username
        switch p.value.service {
        case CNSocialProfileServiceFacebook:
            label = "facebook"
        case CNSocialProfileServiceFlickr:
            label = "flickr"
        case CNSocialProfileServiceGameCenter:
            label = "gameCenter"
        case CNSocialProfileServiceLinkedIn:
            label = "linkedIn"
        case CNSocialProfileServiceMySpace:
            label = "mySpace"
        case CNSocialProfileServiceSinaWeibo:
            label = "sinaWeibo"
        case CNSocialProfileServiceTencentWeibo:
            label = "tencentWeibo"
        case CNSocialProfileServiceTwitter:
            label = "twitter"
        case CNSocialProfileServiceYelp:
            label = "yelp"
        default:
            label = "custom"
            customLabel = p.value.service
        }
    }

    init(fromInstantMessage im: CNLabeledValue<CNInstantMessageAddress>) {
        userName = im.value.username
        switch im.value.service {
        case CNInstantMessageServiceAIM:
            label = "aim"
        case CNInstantMessageServiceFacebook:
            label = "facebook"
        case CNInstantMessageServiceGaduGadu:
            label = "gaduGadu"
        case CNInstantMessageServiceGoogleTalk:
            label = "googleTalk"
        case CNInstantMessageServiceICQ:
            label = "icq"
        case CNInstantMessageServiceJabber:
            label = "jabber"
        case CNInstantMessageServiceMSN:
            label = "msn"
        case CNInstantMessageServiceQQ:
            label = "qqchat"
        case CNInstantMessageServiceSkype:
            label = "skype"
        case CNInstantMessageServiceYahoo:
            label = "yahoo"
        default:
            label = "custom"
            customLabel = im.value.service
        }
    }

    func toMap() -> [String: Any] { [
        "userName": userName,
        "label": label,
        "customLabel": customLabel,
    ]
    }

    func addTo(_ c: CNMutableContact) {
        var labelInv: String
        var isSocialProfile: Bool = false
        switch label {
        case "aim":
            labelInv = CNInstantMessageServiceAIM
        case "facebook":
            labelInv = CNSocialProfileServiceFacebook
            isSocialProfile = true
        case "flickr":
            labelInv = CNSocialProfileServiceFlickr
            isSocialProfile = true
        case "gaduGadu":
            labelInv = CNInstantMessageServiceGaduGadu
        case "gameCenter":
            labelInv = CNSocialProfileServiceGameCenter
            isSocialProfile = true
        case "googleTalk":
            labelInv = CNInstantMessageServiceGoogleTalk
        case "icq":
            labelInv = CNInstantMessageServiceICQ
        case "jabber":
            labelInv = CNInstantMessageServiceJabber
        case "linkedIn":
            labelInv = CNSocialProfileServiceLinkedIn
            isSocialProfile = true
        case "msn":
            labelInv = CNInstantMessageServiceMSN
        case "myspace":
            labelInv = CNSocialProfileServiceMySpace
            isSocialProfile = true
        case "qqchat":
            labelInv = CNInstantMessageServiceQQ
        case "sinaWeibo":
            labelInv = CNSocialProfileServiceSinaWeibo
            isSocialProfile = true
        case "skype":
            labelInv = CNInstantMessageServiceSkype
        case "tencentWeibo":
            labelInv = CNSocialProfileServiceTencentWeibo
            isSocialProfile = true
        case "twitter":
            labelInv = CNSocialProfileServiceTwitter
            isSocialProfile = true
        case "yahoo":
            labelInv = CNInstantMessageServiceYahoo
        case "yelp":
            labelInv = CNSocialProfileServiceYelp
            isSocialProfile = true
        case "custom":
            labelInv = customLabel
        default:
            labelInv = label
        }
        if isSocialProfile {
            c.socialProfiles.append(
                CNLabeledValue<CNSocialProfile>(
                    label: nil,
                    value: CNSocialProfile(
                        urlString: nil,
                        username: userName,
                        userIdentifier: nil,
                        service: labelInv
                    )
                )
            )
        } else {
            c.instantMessageAddresses.append(
                CNLabeledValue<CNInstantMessageAddress>(
                    label: nil,
                    value: CNInstantMessageAddress(
                        username: userName,
                        service: labelInv
                    )
                )
            )
        }
    }
}
