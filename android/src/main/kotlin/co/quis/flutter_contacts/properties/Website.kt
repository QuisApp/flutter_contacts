package co.quis.flutter_contacts.properties

data class Website(
    var url: String,
    // one of: blog, ftp, home, homepage, profile, school, work, other, custom
    var label: String = "homepage",
    var customLabel: String = ""
) {
    companion object {
        fun fromMap(m: Map<String, Any>): Website = Website(
            m["url"] as String,
            m["label"] as String,
            m["customLabel"] as String
        )
    }

    fun toMap(): Map<String, Any> = mapOf(
        "url" to url,
        "label" to label,
        "customLabel" to customLabel
    )
}
