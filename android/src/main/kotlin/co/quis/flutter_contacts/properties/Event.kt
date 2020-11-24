package co.quis.flutter_contacts.properties

data class Event(
    var date: String,
    // one of: anniversary, birthday, other, custom
    var label: String = "birthday",
    var customLabel: String = "",
    var noYear: Boolean = false
) {
    companion object {
        fun fromMap(m: Map<String, Any>): Event = Event(
            m["date"] as String,
            m["label"] as String,
            m["customLabel"] as String,
            m["noYear"] as Boolean
        )
    }

    fun toMap(): Map<String, Any> = mapOf(
        "date" to date,
        "label" to label,
        "customLabel" to customLabel,
        "noYear" to noYear
    )
}
