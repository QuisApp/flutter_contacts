package co.quis.flutter_contacts.crud.models.contact

import co.quis.flutter_contacts.crud.models.JsonHelpers

data class AndroidIdentifiers(
    val lookupKey: String? = null,
    val rawContacts: List<RawContactInfo> = emptyList(),
) {
    companion object {
        fun fromJson(json: Map<String, Any?>?) = json?.let {
            AndroidIdentifiers(
                lookupKey = JsonHelpers.decodeOptional(it, "lookupKey"),
                rawContacts = JsonHelpers.decodeList(it, "rawContacts") { RawContactInfo.fromJson(it) }
                    .filterNotNull(),
            )
        }
    }

    fun toJson() = buildMap<String, Any?> {
        JsonHelpers.encodeOptional(this, "lookupKey", lookupKey)
        JsonHelpers.encodeList(this, "rawContacts", rawContacts) { it.toJson() }
    }

    fun isNotEmpty() = lookupKey != null || rawContacts.isNotEmpty()
}
