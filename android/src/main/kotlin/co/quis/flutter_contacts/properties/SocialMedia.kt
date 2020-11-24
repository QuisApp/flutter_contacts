package co.quis.flutter_contacts.properties

data class SocialMedia(
    var userName: String,
    // one of: aim, baiduTieba, discord, facebook, flickr, gaduGadu, gameCenter,
    // googleTalk, icq, instagram, jabber, line, linkedIn, medium, messenger, msn,
    // mySpace, netmeeting, pinterest, qqchat, qzone, reddit, sinaWeibo, skype,
    // snapchat, telegram, tencentWeibo, tikTok, tumblr, twitter, viber, wechat,
    // whatsapp, yahoo, yelp, youtube, zoom, other, custom
    var label: String = "other",
    var customLabel: String = ""
) {
    companion object {
        fun fromMap(m: Map<String, Any>): SocialMedia = SocialMedia(
            m["userName"] as String,
            m["label"] as String,
            m["customLabel"] as String
        )
    }

    fun toMap(): Map<String, Any> = mapOf(
        "userName" to userName,
        "label" to label,
        "customLabel" to customLabel
    )
}
