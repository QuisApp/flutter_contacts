package co.quis.flutter_contacts.crud.models.contact

import co.quis.flutter_contacts.crud.models.JsonHelpers

data class AndroidData(
    val isFavorite: Boolean? = null,
    val customRingtone: String? = null,
    val sendToVoicemail: Boolean? = null,
    val lastUpdatedTimestamp: Long? = null,
    val identifiers: AndroidIdentifiers? = null,
    val debugData: Map<String, Any?>? = null,
) {
    companion object {
        fun fromJson(json: Map<String, Any?>?) = json?.let {
            AndroidData(
                isFavorite = JsonHelpers.decodeOptional(it, "isFavorite"),
                customRingtone = JsonHelpers.decodeOptional(it, "customRingtone"),
                sendToVoicemail = JsonHelpers.decodeOptional(it, "sendToVoicemail"),
                lastUpdatedTimestamp = JsonHelpers.decodeOptionalTimestamp(it, "lastUpdatedTimestamp"),
                identifiers = JsonHelpers.decodeOptionalObject(it, "identifiers") { AndroidIdentifiers.fromJson(it) },
                debugData = JsonHelpers.decodeOptional(it, "debugData"),
            )
        }
    }

    fun toJson() = buildMap<String, Any?> {
        JsonHelpers.encodeOptional(this, "isFavorite", isFavorite)
        JsonHelpers.encodeOptional(this, "customRingtone", customRingtone)
        JsonHelpers.encodeOptional(this, "sendToVoicemail", sendToVoicemail)
        JsonHelpers.encodeOptional(this, "lastUpdatedTimestamp", lastUpdatedTimestamp)
        JsonHelpers.encodeOptionalObject(this, "identifiers", identifiers) { it.toJson() }
        JsonHelpers.encodeOptional(this, "debugData", debugData)
    }

    fun isNotEmpty() =
        isFavorite != null || customRingtone != null || sendToVoicemail != null ||
            lastUpdatedTimestamp != null || identifiers?.isNotEmpty() == true || debugData != null
}
