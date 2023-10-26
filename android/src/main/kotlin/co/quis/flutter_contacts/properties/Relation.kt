package co.quis.flutter_contacts.properties

data class Relation(
    var name: String,
    // one of: assistant, brother, child, daughter, domestic-partner, father, friend, manager,
    // mother, other, parent, partner, referred-by, relative, sister, son, spouse, custom
    var label: String = "relative",
    var customLabel: String = ""
) {
    companion object {
        fun fromMap(m: Map<String, Any>): Relation = Relation(
            m["name"] as String,
            m["label"] as String,
            m["customLabel"] as String
        )
    }

    fun toMap(): Map<String, Any> = mapOf(
        "name" to name,
        "label" to label,
        "customLabel" to customLabel
    )
}
