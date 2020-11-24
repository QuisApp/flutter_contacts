package co.quis.flutter_contacts.properties

data class Email(
    var address: String,
    // one of: home, iCloud, mobile, school, work, other, custom
    var label: String = "home",
    var customLabel: String = "",
    var isPrimary: Boolean = false
) {
    companion object {
        fun fromMap(m: Map<String, Any>): Email = Email(
            m["address"] as String,
            m["label"] as String,
            m["customLabel"] as String,
            m["isPrimary"] as Boolean
        )
    }

    fun toMap(): Map<String, Any> = mapOf(
        "address" to address,
        "label" to label,
        "customLabel" to customLabel,
        "isPrimary" to isPrimary
    )
}
