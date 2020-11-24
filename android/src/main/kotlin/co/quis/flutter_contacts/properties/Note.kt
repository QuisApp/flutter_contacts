package co.quis.flutter_contacts.properties

data class Note(
    var note: String
) {
    companion object {
        fun fromMap(m: Map<String, Any>): Note = Note(m["note"] as String)
    }

    fun toMap(): Map<String, Any> = mapOf("note" to note)
}
