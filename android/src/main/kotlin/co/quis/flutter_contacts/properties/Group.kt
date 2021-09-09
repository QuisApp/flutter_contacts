package co.quis.flutter_contacts.properties

data class Group(
    var id: String,
    var name: String
) {

    companion object {
        fun fromMap(m: Map<String, Any>): Group = Group(
            m["id"] as String,
            m["name"] as String
        )
    }

    fun toMap(): Map<String, Any> = mapOf(
        "id" to id,
        "name" to name
    )
}
