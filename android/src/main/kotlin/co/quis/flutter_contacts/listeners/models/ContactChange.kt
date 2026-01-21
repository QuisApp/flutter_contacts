package co.quis.flutter_contacts.listeners.models

import org.json.JSONObject

data class ContactChange(
    val type: ContactChangeType,
    val contactId: String,
) {
    fun toJson() =
        JSONObject().apply {
            put("type", type.value)
            put("contactId", contactId)
        }
}

enum class ContactChangeType(
    val value: String,
) {
    ADDED("added"),
    UPDATED("updated"),
    REMOVED("removed"),
}
