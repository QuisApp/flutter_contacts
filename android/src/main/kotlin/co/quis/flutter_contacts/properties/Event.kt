package co.quis.flutter_contacts.properties

data class Event(
    var year: Int?,
    var month: Int,
    var day: Int,
    // one of: anniversary, birthday, other, custom
    var label: String = "birthday",
    var customLabel: String = ""
) {
    companion object {
        fun fromMap(m: Map<String, Any?>): Event = Event(
            m["year"] as Int?,
            m["month"] as Int,
            m["day"] as Int,
            m["label"] as String,
            m["customLabel"] as String
        )
    }

    fun toMap(): Map<String, Any?> = mapOf(
        "year" to year,
        "month" to month,
        "day" to day,
        "label" to label,
        "customLabel" to customLabel
    )
}
