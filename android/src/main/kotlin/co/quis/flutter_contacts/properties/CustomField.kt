package co.quis.flutter_contacts.properties


data class CustomField(
    var name: String,
    var label: String,
) {
    companion object {
        fun fromMap(m: Map<String, Any>): CustomField = CustomField(
            m["name"] as String,
            m["label"] as String,
        )
    }

    fun toMap(): Map<String, Any> = mapOf(
        "name" to name,
        "label" to label,
    )
}
