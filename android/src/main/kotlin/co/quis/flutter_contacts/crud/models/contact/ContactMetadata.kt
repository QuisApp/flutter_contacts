package co.quis.flutter_contacts.crud.models.contact

data class ContactMetadata(
    val properties: Set<String>,
    val accounts: List<Map<String, String>> = emptyList(),
    val lastUpdatedTimestamp: Long? = null,
) {
    companion object {
        fun fromJson(json: Map<String, Any?>): ContactMetadata {
            val propertiesList = json["properties"] as? List<*> ?: emptyList<Any>()
            val properties = propertiesList.map { it as String }.toSet()
            val accountsList = json["accounts"] as? List<*> ?: emptyList<Any>()
            val accounts =
                accountsList.mapNotNull { account ->
                    (account as? Map<*, *>)?.let { map ->
                        val name = map["name"] as? String
                        val type = map["type"] as? String
                        if (name != null && type != null) {
                            mapOf("name" to name, "type" to type)
                        } else {
                            null
                        }
                    }
                }
            val lastUpdatedTimestamp = (json["lastUpdatedTimestamp"] as? Number)?.toLong()
            return ContactMetadata(properties = properties, accounts = accounts, lastUpdatedTimestamp = lastUpdatedTimestamp)
        }

        fun fromPropertiesSet(
            properties: Set<String>,
            accounts: List<Map<String, String>> = emptyList(),
            lastUpdatedTimestamp: Long? = null,
        ): ContactMetadata = ContactMetadata(properties = properties, accounts = accounts, lastUpdatedTimestamp = lastUpdatedTimestamp)
    }

    fun toJson(): Map<String, Any?> {
        val result =
            mutableMapOf<String, Any?>(
                "properties" to properties.sorted().toList(),
                "accounts" to accounts,
            )
        lastUpdatedTimestamp?.let { result["lastUpdatedTimestamp"] = it }
        return result
    }
}
